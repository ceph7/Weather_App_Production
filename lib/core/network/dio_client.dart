import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Fournit une instance Dio configurée pour l'API OpenWeatherMap.
/// L'intercepteur d'auth (token injection + refresh) est ajouté séparément
/// via [AuthInterceptor] pour respecter la séparation des responsabilités
/// (voir auth_interceptor.dart).
class DioClient {
  static Dio createWeatherClient() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.weatherBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        queryParameters: {
          'appid': AppConstants.owmApiKey,
          'units': 'metric',
          'lang': 'fr',
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (_) {}, // silencieux en prod ; activer pour debug local
      ),
    );

    return dio;
  }
}
