import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pc_build.dart';

class ApiService {
  // Danh sách 3 Base URL hỗ trợ chuyển đổi nhanh:
  // 1. Local IP mạng LAN (dành cho điện thoại thật hoặc máy ảo tuỳ ý)
  static const String localIpUrl = 'http://127.0.0.1:8000';
  // 2. Android Emulator mặc định
  static const String emulatorUrl = 'http://10.0.2.2:8000';
  // 3. Ngrok Public URL (Dành cho truy cập qua Internet)
  static const String ngrokUrl =
      'https://customer-outskirts-blubber.ngrok-free.dev';

  static const String ngrokUrl1 =
      'https://container-frisk-plunder.ngrok-free.dev';

  // Biến cấu hình baseUrl hiện tại (đổi sang localIpUrl, emulatorUrl hoặc ngrokUrl tuỳ môi trường)
  static String baseUrl = ngrokUrl;

  // Session ID mặc định cho phiên tư vấn
  static String currentSessionId = 'session_gaming_pc';

  /// Gửi câu hỏi của người dùng tới Backend FastAPI Chatbot và nhận phản hồi
  static Future<Map<String, dynamic>> sendMessageToChatbot(
      String message) async {
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

      // 201 Created: Thành công theo đúng đặc tả API mới
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        final String replyText = responseData['chatbot_reply'] ??
            responseData['text'] ??
            'Đã nhận yêu cầu tư vấn.';

        return {
          'text': replyText,
          'has_card': responseData['has_card'] ?? false,
          'build_data': responseData['build_data'],
          'success': true,
        };
      } else if (response.statusCode == 400) {
        return {
          'text':
              'Lỗi xác thực dữ liệu (400). Vui lòng kiểm tra lại nội dung câu hỏi!',
          'has_card': false,
          'success': false,
        };
      } else if (response.statusCode == 500) {
        return {
          'text': 'Hệ thống đang gặp sự cố. Vui lòng thử lại sau!',
          'has_card': false,
          'success': false,
        };
      } else if (response.statusCode == 504) {
        return {
          'text': 'Hệ thống cần thêm thời gian để xử lý. Vui lòng thử lại sau!',
          'has_card': false,
          'success': false,
        };
      } else {
        return {
          'text': 'Hệ thống đang bận. Vui lòng thử lại sau giây lát!',
          'has_card': false,
          'success': false,
        };
      }
    } on TimeoutException catch (_) {
      return {
        'text':
            'Mạng không ổn định hoặc hệ thống đang quá tải. Vui lòng thử lại!',
        'has_card': false,
        'success': false,
      };
    } catch (e) {
      // ignore: avoid_print
      print('API Error: $e');
      return {
        'text':
            'Không thể kết nối đến hệ thống. Vui lòng kiểm tra lại đường truyền mạng!',
        'has_card': false,
        'success': false,
      };
    }
  }

  /// Xóa sạch bộ nhớ đệm và lịch sử phiên hội thoại trên cả UI và Server
  static Future<bool> deleteSession() async {
    final user = FirebaseAuth.instance.currentUser;
    final sessionId = user != null ? 'session_${user.uid}' : currentSessionId;
    final url = Uri.parse('$baseUrl/sessions/$sessionId');
    try {
      final idToken = await user?.getIdToken();
      final response = await http.delete(
        url,
        headers: {
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false; // Trả về false nếu backend chưa bật hoặc lỗi kết nối
    }
  }
}
