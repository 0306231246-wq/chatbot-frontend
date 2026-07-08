import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionService {
  AuthSessionService._();

  static final AuthSessionService instance = AuthSessionService._();

  static const String _sessionPrefsKey = 'active_session_id';
  static const String _collection = 'active_sessions';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;
  bool _isSigningOutBecauseKicked = false;

  Future<void> registerActiveSession(User user) async {
    final sessionId = _createSessionId();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionPrefsKey, sessionId);

    await _sessionDoc(user.uid).set({
      'sessionId': sessionId,
      'updatedAt': FieldValue.serverTimestamp(),
      'email': user.email,
      'platform': _platformLabel,
    });
  }

  Future<void> startWatching({
    required User user,
    required VoidCallback onKicked,
  }) async {
    await stopWatching();
    final prefs = await SharedPreferences.getInstance();
    var localSessionId = prefs.getString(_sessionPrefsKey);
    if (localSessionId == null || localSessionId.isEmpty) {
      await registerActiveSession(user);
      localSessionId = prefs.getString(_sessionPrefsKey);
      if (localSessionId == null || localSessionId.isEmpty) return;
    }

    _subscription = _sessionDoc(user.uid).snapshots().listen((snapshot) async {
      if (_isSigningOutBecauseKicked || _auth.currentUser?.uid != user.uid) {
        return;
      }

      final remoteSessionId = snapshot.data()?['sessionId']?.toString();
      if (remoteSessionId == null || remoteSessionId == localSessionId) {
        return;
      }

      try {
        _isSigningOutBecauseKicked = true;
        await prefs.remove(_sessionPrefsKey);
        await stopWatching();
        await _auth.signOut();
        onKicked();
      } finally {
        _isSigningOutBecauseKicked = false;
      }
    });
  }

  Future<void> stopWatching() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> signOutCurrentSession() async {
    final user = _auth.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final localSessionId = prefs.getString(_sessionPrefsKey);

    await stopWatching();

    if (user != null && localSessionId != null) {
      final doc = await _sessionDoc(user.uid).get();
      final remoteSessionId = doc.data()?['sessionId']?.toString();
      if (remoteSessionId == localSessionId) {
        await _sessionDoc(user.uid).delete();
      }
    }

    await prefs.remove(_sessionPrefsKey);
  }

  DocumentReference<Map<String, dynamic>> _sessionDoc(String uid) {
    return _firestore.collection(_collection).doc(uid);
  }

  String _createSessionId() {
    final random = Random.secure();
    final bytes = List<int>.generate(24, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String get _platformLabel {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform.name;
  }
}
