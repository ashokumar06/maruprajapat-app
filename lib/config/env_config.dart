import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("Warning: Could not load .env file: $e");
    }
  }

  static String get firebaseDatabaseUrl =>
      dotenv.env['FIREBASE_DATABASE_URL'] ??
      const String.fromEnvironment('FIREBASE_DATABASE_URL',
          defaultValue: 'https://maru-prajapat-89e33-default-rtdb.asia-southeast1.firebasedatabase.app/');

  static String get cfR2AccessKeyId =>
      dotenv.env['CF_R2_ACCESS_KEY_ID'] ??
      const String.fromEnvironment('CF_R2_ACCESS_KEY_ID');

  static String get cfR2SecretAccessKey =>
      dotenv.env['CF_R2_SECRET_ACCESS_KEY'] ??
      const String.fromEnvironment('CF_R2_SECRET_ACCESS_KEY');

  static String get cfR2Endpoint =>
      dotenv.env['CF_R2_ENDPOINT'] ??
      const String.fromEnvironment('CF_R2_ENDPOINT');

  static String get cfR2Token =>
      dotenv.env['CF_R2_TOKEN'] ??
      const String.fromEnvironment('CF_R2_TOKEN');

  static String get cfR2BucketName =>
      dotenv.env['CF_R2_BUCKET_NAME'] ??
      const String.fromEnvironment('CF_R2_BUCKET_NAME', defaultValue: 'maruprajapat');

  static String get cfR2PublicUrl =>
      dotenv.env['CF_R2_PUBLIC_URL'] ??
      const String.fromEnvironment('CF_R2_PUBLIC_URL');

  static String get apiUrl {
    // 1. Try to read from dotenv
    final envUrl = dotenv.env['API_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    // 2. Try to read from dart-define (compile-time)
    const dartDefineUrl = String.fromEnvironment('API_URL');
    if (dartDefineUrl.isNotEmpty) {
      return dartDefineUrl;
    }
    // 3. Fallback based on build mode
    if (kReleaseMode) {
      return 'https://api.maruprajapat.in';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }
}

