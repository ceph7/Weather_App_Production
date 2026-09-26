# Changelog

Toutes les modifications notables de ce projet sont documentées dans ce
fichier.

Le format s'inspire de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/)
et ce projet suit le [Semantic Versioning](https://semver.org/lang/fr/).

## [1.2.0] — Production-ready

### Ajouté
- Internationalisation complète FR/EN (`AppLocalizations`), avec bascule
  automatique selon la langue du système et fallback français.
- Accessibilité : `Semantics`/`semanticLabel` sur tous les éléments
  interactifs (boutons, icônes, champ de recherche, bannière hors-ligne).
- Suite de tests complète : tests unitaires (repositories Hive, use cases,
  validation JWT), tests de widgets (formulaires, cartes météo, bannière
  hors-ligne) et tests d'intégration bout-en-bout (inscription/connexion,
  navigation + favoris).
- Pipeline CI/CD GitHub Actions : formatage, analyse statique, tests avec
  couverture, tests d'intégration, build APK de démonstration.
- `CHANGELOG.md` et README enrichi (architecture, setup, CI, captures).

### Modifié
- `HomeScreen` utilise désormais `IndexedStack` au lieu de reconstruire les
  écrans à chaque changement d'onglet (réduction des rebuilds inutiles).
- Les icônes météo sont désormais décodées à une résolution réduite
  (`cacheWidth`/`cacheHeight`) plutôt qu'à leur taille native, pour limiter
  le coût mémoire/CPU du décodage d'image.
- L'enregistrement d'une recherche dans l'historique est désormais différé
  via `addPostFrameCallback` pour ne plus modifier l'état pendant la
  construction du widget (évite un warning Riverpod et un rebuild superflu).
- `isFavoriteProvider` (nouveau, dérivé et `select`-able) remplace un calcul
  inline recalculé à chaque `build` de l'écran d'accueil.

### Corrigé
- Le dossier `assets/` déclaré dans `pubspec.yaml` mais absent du dépôt a été
  recréé (empêchait `flutter pub get` / le build de fonctionner à froid).

## [1.1.0] — Favoris & historique

### Ajouté
- Écran "Enregistrés" listant les villes favorites et les données
  disponibles hors-ligne (cache Hive).
- Gestion des favoris (ajout/retrait) persistée localement avec Hive.
- Historique des recherches (20 dernières entrées maximum, purge
  automatique des plus anciennes) avec possibilité de tout effacer.

### Modifié
- L'écran d'accueil affiche désormais un bouton "Favori" à bascule au lieu
  d'un simple indicateur statique.

## [1.0.0] — Version initiale

### Ajouté
- Authentification (inscription/connexion/déconnexion) avec JWT signés et
  vérifiés localement (`dart_jsonwebtoken`), mots de passe hachés
  (SHA-256 + sel) et stockage sécurisé des tokens
  (`flutter_secure_storage`).
- Écran d'accueil affichant la météo actuelle d'une ville (OpenWeatherMap).
- Écran de recherche libre de ville.
- Écran de prévisions à 5 jours / 3h.
- Cache local (Hive) de chaque météo consultée et mode hors-ligne avec
  bannière de statut et fallback automatique sur les dernières données
  connues.
- Gestion d'erreurs réseau avec messages utilisateur clairs (ville
  introuvable, pas de connexion, erreur serveur).
- Architecture Clean, feature-first (`domain` / `data` / `presentation`),
  gestion d'état avec Riverpod.
- Premiers tests unitaires (repository d'authentification, use cases,
  repository météo).
