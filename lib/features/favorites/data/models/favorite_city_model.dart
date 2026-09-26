import 'package:hive/hive.dart';

part 'favorite_city_model.g.dart';

@HiveType(typeId: 2)
class FavoriteCityModel extends HiveObject {
  @HiveField(0)
  final String cityName;

  @HiveField(1)
  final DateTime addedAt;

  FavoriteCityModel({required this.cityName, required this.addedAt});
}
