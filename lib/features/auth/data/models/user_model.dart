import 'package:hive/hive.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

/// Modèle Hive représentant un compte stocké localement.
///
/// NOTE PÉDAGOGIQUE : ce projet n'a pas de vrai backend d'authentification.
/// Le "serveur d'auth" est simulé localement (voir `mock_auth_datasource.dart`) :
/// - le mot de passe est haché (SHA-256 + salt) avant stockage, jamais en clair
/// - un JWT est signé localement avec `dart_jsonwebtoken`
/// Voir le README, section "Architecture", pour le détail de ce choix et
/// comment brancher un vrai backend (ex: Laravel Sanctum, Firebase Auth...).
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String passwordHash;

  @HiveField(4)
  final String passwordSalt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.passwordHash,
    required this.passwordSalt,
  });

  UserEntity toEntity() => UserEntity(id: id, email: email, name: name);
}
