import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/models/search_history_model.dart';
import '../../data/repositories/history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(ref.watch(historyBoxProvider));
});

final searchHistoryProvider =
    Provider.autoDispose<List<SearchHistoryModel>>((ref) {
  return ref.watch(historyRepositoryProvider).getHistory();
});

class HistoryController extends Notifier<void> {
  @override
  void build() {}

  Future<void> record(String city) async {
    await ref.read(historyRepositoryProvider).addSearch(city);
    ref.invalidate(searchHistoryProvider);
  }

  Future<void> clear() async {
    await ref.read(historyRepositoryProvider).clearHistory();
    ref.invalidate(searchHistoryProvider);
  }
}

final historyControllerProvider =
    NotifierProvider<HistoryController, void>(HistoryController.new);
