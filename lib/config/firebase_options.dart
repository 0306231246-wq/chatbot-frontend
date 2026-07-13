import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static const _fallbackStorageBucket = 'chat-bot-ea051.firebasestorage.app';

  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    return android;
  }

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? 'YOUR_API_KEY',
        appId: dotenv.env['FIREBASE_APP_ID'] ?? 'YOUR_APP_ID',
        messagingSenderId:
            dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? 'YOUR_SENDER_ID',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? 'YOUR_PROJECT_ID',
        authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? 'YOUR_AUTH_DOMAIN',
        storageBucket:
            dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? _fallbackStorageBucket,
        measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'],
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? 'YOUR_API_KEY',
        appId: dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? 'YOUR_APP_ID',
        messagingSenderId:
            dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? 'YOUR_SENDER_ID',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? 'YOUR_PROJECT_ID',
        storageBucket:
            dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? _fallbackStorageBucket,
      );
}
