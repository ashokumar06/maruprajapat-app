import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }

  static String get firebaseDatabaseUrl =>
      dotenv.env['FIREBASE_DATABASE_URL'] ?? '';

  static String get cfR2AccessKeyId => dotenv.env['CF_R2_ACCESS_KEY_ID'] ?? '';

  static String get cfR2SecretAccessKey =>
      dotenv.env['CF_R2_SECRET_ACCESS_KEY'] ?? '';

  static String get cfR2Endpoint => dotenv.env['CF_R2_ENDPOINT'] ?? '';

  static String get cfR2Token => dotenv.env['CF_R2_TOKEN'] ?? '';

  static String get cfR2BucketName => dotenv.env['CF_R2_BUCKET_NAME'] ?? '';

  static String get cfR2PublicUrl => dotenv.env['CF_R2_PUBLIC_URL'] ?? '';

  static String get apiUrl => dotenv.env['API_URL'] ?? 'http://127.0.0.1:8000/api/v1';
}
