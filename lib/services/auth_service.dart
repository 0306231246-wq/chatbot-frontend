import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_session_service.dart';

class AuthResult {
  final User? user;
  final String? errorMessage;
  final bool success;

  AuthResult.success(this.user)
      : success = true,
        errorMessage = null;
  AuthResult.error(this.errorMessage)
      : success = false,
        user = null;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    _googleSignIn = GoogleSignIn(
      clientId: kIsWeb ? dotenv.env['GOOGLE_WEB_CLIENT_ID'] : null,
      scopes: ['email'],
    );
  }

  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult.success(cred.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e));
    } catch (_) {
      return AuthResult.error('Đã có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  Future<AuthResult> signUpWithEmail(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.sendEmailVerification();
      return AuthResult.success(cred.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e));
    } catch (_) {
      return AuthResult.error('Đã có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final cred = await _auth.signInWithPopup(GoogleAuthProvider());
        return AuthResult.success(cred.user);
      }

      final account = await _googleSignIn.signIn();
      if (account == null) {
        return AuthResult.error('Đăng nhập bị hủy.');
      }

      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      return AuthResult.success(cred.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e));
    } catch (_) {
      return AuthResult.error('Đăng nhập thất bại. Vui lòng thử lại.');
    }
  }

  Future<void> signOut() async {
    try {
      await AuthSessionService.instance.signOutCurrentSession();
    } catch (_) {}
    await _auth.signOut();
    try {
      if (await _googleSignIn.isSignedIn() == false) {
        await _googleSignIn.signInSilently();
      }
      await _googleSignIn.disconnect();
    } catch (_) {}
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e));
    } catch (_) {
      return AuthResult.error('Đã có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  Future<AuthResult> updateProfile({
    required String displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.error('Bạn cần đăng nhập để cập nhật hồ sơ.');
      }

      await user.updateDisplayName(displayName.trim());

      final cleanPhotoUrl = photoUrl?.trim();
      if (cleanPhotoUrl != null && cleanPhotoUrl.isNotEmpty) {
        if (cleanPhotoUrl.startsWith('data:image')) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'photoBase64': cleanPhotoUrl,
          }, SetOptions(merge: true));
          clearAvatarCache(user.uid);
          await user.updatePhotoURL('firestore_base64');
        } else {
          await user.updatePhotoURL(cleanPhotoUrl);
        }
      } else if (photoUrl != null) {
        await user.updatePhotoURL(null);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'photoBase64': FieldValue.delete(),
        }, SetOptions(merge: true));
        clearAvatarCache(user.uid);
      }

      await user.reload();
      return AuthResult.success(_auth.currentUser);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e));
    } catch (_) {
      return AuthResult.error('Cập nhật hồ sơ thất bại. Vui lòng thử lại.');
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác.';
      case 'email-already-in-use':
        return 'Email này đã được đăng ký.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Cần ít nhất 6 ký tự.';
      case 'invalid-email':
        return 'Định dạng email không hợp lệ.';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không chính xác.';
      case 'too-many-requests':
        return 'Bạn thử quá nhiều lần. Vui lòng đợi một lát rồi thử lại.';
      case 'network-request-failed':
        return 'Không có kết nối mạng. Vui lòng kiểm tra lại.';
      default:
        return 'Lỗi xác thực. Vui lòng thử lại.';
    }
  }

  static final Map<String, String> _avatarCache = {};

  static Future<String?> getProfileAvatar(String uid) async {
    if (_avatarCache.containsKey(uid)) return _avatarCache[uid];
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final base64 = doc.data()?['photoBase64'] as String?;
      if (base64 != null) _avatarCache[uid] = base64;
      return base64;
    } catch (_) {
      return null;
    }
  }

  static void clearAvatarCache(String uid) {
    _avatarCache.remove(uid);
  }
}
