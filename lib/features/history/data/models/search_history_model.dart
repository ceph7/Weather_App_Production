import 'package:hive/hive.dart';

part 'search_history_model.g.dart';

@HiveType(typeId: 3)
class SearchHistoryModel extends HiveObject {
  @HiveField(0)
  final String cityName;

  @HiveField(1)
  final DateTime searchedAt;

  SearchHistoryModel({required this.cityName, required this.searchedAt});
}
