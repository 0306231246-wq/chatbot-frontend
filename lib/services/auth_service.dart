import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
          email: email, password: password);
      return AuthResult.success(cred.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Đã có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  Future<AuthResult> signUpWithEmail(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // Gửi email xác thực đóng vai trò như một Welcome Email
      await cred.user?.sendEmailVerification();
      return AuthResult.success(cred.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Đã có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final cred = await _auth.signInWithPopup(googleProvider);
        return AuthResult.success(cred.user);
      } else {
        final GoogleSignInAccount? account = await _googleSignIn.signIn();
        if (account != null) {
          final GoogleSignInAuthentication auth = await account.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: auth.accessToken,
            idToken: auth.idToken,
          );
          final cred = await _auth.signInWithCredential(credential);
          return AuthResult.success(cred.user);
        }
        return AuthResult.error('Đăng nhập bị hủy.');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.error(
          'Đăng nhập thất bại. Lỗi: $e');
    }
  }

  Future<void> signOut() async {
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
    } catch (e) {
      return AuthResult.error('Đã có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với Email này.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác.';
      case 'email-already-in-use':
        return 'Email này đã được đăng ký.';
      case 'weak-password':
        return 'Mật khẩu quá yếu (cần ít nhất 6 ký tự).';
      case 'invalid-email':
        return 'Định dạng Email không hợp lệ.';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không chính xác.';
      default:
        return 'Lỗi xác thực: ${e.message}';
    }
  }
}
