import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/weather_api_model.dart';

abstract class WeatherRemoteDatasource {
  Future<WeatherApiModel> getCurrentWeather(String city);
  Future<List<ForecastApiModel>> getForecast(String city);
}

class WeatherRemoteDatasourceImpl implements WeatherRemoteDatasource {
  final Dio dio;

  WeatherRemoteDatasourceImpl(this.dio);

  @override
  Future<WeatherApiModel> getCurrentWeather(String city) async {
    try {
      final response = await dio.get('/weather', queryParameters: {'q': city});
      return WeatherApiModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<List<ForecastApiModel>> getForecast(String city) async {
    try {
      final response = await dio.get('/forecast', queryParameters: {'q': city});
      final list = (response.data as Map<String, dynamic>)['list'] as List;
      return list
          .map((e) => ForecastApiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Exception _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException();
    }
    if (e.response?.statusCode == 404) {
      return const ServerException('Ville introuvable.');
    }
    if (e.response?.statusCode == 401) {
      return const ServerException(
        'Clé API OpenWeatherMap invalide ou manquante.',
      );
    }
    return const ServerException();
  }
}
