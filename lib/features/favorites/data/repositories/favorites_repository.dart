import 'package:hive/hive.dart';
import '../models/favorite_city_model.dart';

/// Repository des villes favorites. Volontairement simple (pas de use cases
/// séparés) : c'est une fonctionnalité de confort au-dessus du module Weather,
/// pas une exigence du cahier des charges.
class FavoritesRepository {
  final Box<FavoriteCityModel> box;

  FavoritesRepository(this.box);

  List<String> getFavorites() {
    final values = box.values.toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return values.map((v) => v.cityName).toList();
  }

  bool isFavorite(String city) => box.containsKey(_key(city));

  Future<void> toggleFavorite(String city) async {
    final key = _key(city);
    if (box.containsKey(key)) {
      await box.delete(key);
    } else {
      await box.put(
        key,
        FavoriteCityModel(cityName: city, addedAt: DateTime.now()),
      );
    }
  }

  String _key(String city) => city.trim().toLowerCase();
}
