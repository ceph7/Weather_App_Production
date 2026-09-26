import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.watch(favoritesBoxProvider));
});

/// Liste réactive des favoris — se recalcule via `ref.invalidate` après toggle.
final favoritesListProvider = Provider.autoDispose<List<String>>((ref) {
  return ref.watch(favoritesRepositoryProvider).getFavorites();
});

/// True si [city] fait partie des favoris — dérivé de [favoritesListProvider]
/// pour permettre un `select` fin (rebuild uniquement quand ce booléen change).
final isFavoriteProvider =
    Provider.autoDispose.family<bool, String>((ref, city) {
  final key = city.trim().toLowerCase();
  return ref
      .watch(favoritesListProvider)
      .any((favorite) => favorite.trim().toLowerCase() == key);
});

class FavoritesController extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggle(String city) async {
    await ref.read(favoritesRepositoryProvider).toggleFavorite(city);
    ref.invalidate(favoritesListProvider);
  }

  bool isFavorite(String city) {
    return ref.read(favoritesRepositoryProvider).isFavorite(city);
  }
}

final favoritesControllerProvider =
    NotifierProvider<FavoritesController, void>(FavoritesController.new);
