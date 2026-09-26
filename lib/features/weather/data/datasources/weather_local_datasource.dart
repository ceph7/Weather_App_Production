import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/weather_api_model.dart';
import '../models/weather_cache_model.dart';

abstract class WeatherLocalDatasource {
  Future<void> cacheWeather(String city, WeatherApiModel weather);
  WeatherCacheModel? getCachedWeather(String city);
  List<WeatherCacheModel> getAllCached();
}

class WeatherLocalDatasourceImpl implements WeatherLocalDatasource {
  final Box<WeatherCacheModel> box;

  WeatherLocalDatasourceImpl(this.box);

  @override
  Future<void> cacheWeather(String city, WeatherApiModel weather) async {
    try {
      final model = WeatherCacheModel.fromApiModel(weather);
      await box.put(_normalizeKey(city), model);
    } catch (_) {
      throw const CacheException('Impossible de sauvegarder en cache.');
    }
  }

  @override
  WeatherCacheModel? getCachedWeather(String city) {
    return box.get(_normalizeKey(city));
  }

  @override
  List<WeatherCacheModel> getAllCached() {
    return box.values.toList()
      ..sort((a, b) => b.fetchedAt.compareTo(a.fetchedAt));
  }

  String _normalizeKey(String city) => city.trim().toLowerCase();
}
