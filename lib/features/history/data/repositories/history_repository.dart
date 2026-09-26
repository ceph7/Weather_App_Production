import 'package:hive/hive.dart';
import '../models/search_history_model.dart';

class HistoryRepository {
  final Box<SearchHistoryModel> box;
  static const int maxEntries = 20;

  HistoryRepository(this.box);

  List<SearchHistoryModel> getHistory() {
    final values = box.values.toList()
      ..sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
    return values;
  }

  Future<void> addSearch(String city) async {
    final key = city.trim().toLowerCase();
    await box.put(key, SearchHistoryModel(cityName: city, searchedAt: DateTime.now()));

    if (box.length > maxEntries) {
      final sorted = box.values.toList()
        ..sort((a, b) => a.searchedAt.compareTo(b.searchedAt));
      final toRemove = sorted.take(box.length - maxEntries);
      for (final entry in toRemove) {
        await entry.delete();
      }
    }
  }

  Future<void> clearHistory() async {
    await box.clear();
  }
}
