# AI PC Builder Frontend

Ứng dụng Flutter cho hệ thống tư vấn linh kiện và cấu hình PC. Ứng dụng hỗ trợ đăng nhập Firebase, trò chuyện với Chatbot API, xem linh kiện và lưu cấu hình người dùng.

## Yêu cầu

- Flutter SDK tương thích Dart `>=3.1.3 <4.0.0`
- Chatbot API đang hoạt động
- Firebase Authentication và Firestore đã được cấu hình

## Cấu hình Firebase

Tạo `.env` trong thư mục này:

```env
FIREBASE_API_KEY=
FIREBASE_APP_ID=
FIREBASE_ANDROID_API_KEY=
FIREBASE_ANDROID_APP_ID=
FIREBASE_MESSAGING_SENDER_ID=
FIREBASE_PROJECT_ID=
FIREBASE_AUTH_DOMAIN=
FIREBASE_STORAGE_BUCKET=
FIREBASE_MEASUREMENT_ID=
GOOGLE_WEB_CLIENT_ID=
```

Không đặt khóa quản trị Firebase, mật khẩu cơ sở dữ liệu hoặc khóa API phía server trong frontend.

## Backend

Địa chỉ API được chọn qua `ApiService.baseUrl` trong `lib/services/api_service.dart`:

- `http://127.0.0.1:8000`: chạy cùng máy
- `http://10.0.2.2:8000`: Android Emulator
- URL HTTPS công khai: thiết bị thật

## Chạy

```powershell
flutter pub get
flutter run
```

Chạy trên web:

```powershell
flutter run -d web-server --web-port 8080
```

Backend phải cho phép origin của frontend trong cấu hình CORS.
