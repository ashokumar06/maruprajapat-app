import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/env_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    final String baseUrl = EnvConfig.apiUrl;

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user.getIdToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
        } catch (e) {
          // Ignore auth errors during request interception
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        final maintenanceException = DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: 'सर्वर रखरखाव के अधीन है, इसे जल्द ही अपडेट किया जाएगा।',
          message: 'सर्वर रखरखाव के अधीन है, इसे जल्द ही अपडेट किया जाएगा।',
        );
        return handler.next(maintenanceException);
      },
    ));

    // Print all API requests and responses to terminal
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print(obj.toString()),
    ));
  }
}
