import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String localIpUrl = 'http://127.0.0.1:8000';
  static const String emulatorUrl = 'http://10.0.2.2:8000';
  static const String ngrokUrl =
      'https://customer-outskirts-blubber.ngrok-free.dev';
  static const String ngrokUrl1 =
      'https://container-frisk-plunder.ngrok-free.dev';

  static String get baseUrl {
    // WARNING (Security): Cleartext HTTP (like 127.0.0.1) is blocked on Android 9+ release builds.
    // Ensure you only use HTTPS in production.
    if (kReleaseMode) {
      return ngrokUrl; // Enforce HTTPS for production
    }
    return ngrokUrl; // Can be changed to emulatorUrl or localIpUrl for debug
  }

  static String currentSessionId = 'session_gaming_pc';
  static Future<void> _requestQueue = Future.value();
  static Future<String>? _healthCheckInFlight;

  // ponytail: one global backend lane; split by endpoint if backend handles parallel calls safely.
  static Future<T> _runExclusive<T>(Future<T> Function() request) {
    final run = _requestQueue.catchError((_) {}).then((_) => request());
    _requestQueue = run.then<void>((_) {}, onError: (_, __) {});
    return run;
  }

  static Future<Map<String, dynamic>> sendMessageToChatbot(
      String message) async {
    return _runExclusive(() async {
      final user = FirebaseAuth.instance.currentUser;
      final sessionId = user != null ? 'session_${user.uid}' : currentSessionId;
      final url = Uri.parse('$baseUrl/chat');

      try {
        final idToken = await user?.getIdToken();
        final response = await http
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                if (idToken != null) 'Authorization': 'Bearer $idToken',
              },
              body: jsonEncode({
                'user_message': message,
                'session_id': sessionId,
              }),
            )
            .timeout(const Duration(seconds: 60));

        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes))
              as Map<String, dynamic>;
          return {
            'text': data['chatbot_reply'] ??
                data['text'] ??
                'Đã nhận yêu cầu tư vấn.',
            'has_card': data['has_card'] ?? false,
            'build_data': data['build_data'],
            'success': true,
          };
        }

        return _error(_messageForStatus(response.statusCode));
      } on TimeoutException {
        return _error('Hệ thống phản hồi chậm. Vui lòng thử lại sau.');
      } catch (_) {
        return _error('Không thể kết nối hệ thống. Vui lòng kiểm tra mạng.');
      }
    });
  }

  static Map<String, dynamic> _error(String text) {
    return {
      'text': text,
      'has_card': false,
      'success': false,
    };
  }

  static String _messageForStatus(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Nội dung gửi chưa hợp lệ. Vui lòng kiểm tra lại.';
      case 401:
      case 403:
        return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
      case 500:
        return 'Hệ thống đang gặp sự cố. Vui lòng thử lại sau.';
      case 504:
        return 'Hệ thống cần thêm thời gian xử lý. Vui lòng thử lại sau.';
      default:
        return 'Hệ thống đang bận. Vui lòng thử lại sau.';
    }
  }

  static Future<String> getHealthStatus() {
    return _healthCheckInFlight ??= _runExclusive(_fetchHealthStatus).whenComplete(
      () => _healthCheckInFlight = null,
    );
  }

  static Future<String> _fetchHealthStatus() async {
    final url = Uri.parse('$baseUrl/health');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final decoded =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return decoded['status'] ?? 'error';
      }
      return 'error';
    } catch (_) {
      return 'error';
    }
  }

  static Future<bool> deleteSession() {
    return _runExclusive(() async {
      final user = FirebaseAuth.instance.currentUser;
      final sessionId = user != null ? 'session_${user.uid}' : currentSessionId;
      final url = Uri.parse('$baseUrl/sessions/$sessionId');
      try {
        final idToken = await user?.getIdToken();
        final response = await http
            .delete(
              url,
              headers: {
                if (idToken != null) 'Authorization': 'Bearer $idToken',
              },
            )
            .timeout(const Duration(seconds: 10));
        return response.statusCode == 200 || response.statusCode == 204;
      } catch (_) {
        return false;
      }
    });
  }
}
