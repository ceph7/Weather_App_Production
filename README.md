# 🌦️ Weather App — Projet Flutter Production-Ready

![CI](https://github.com/<ton-user>/<ton-repo>/actions/workflows/ci.yml/badge.svg)
![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A5%203.24-02569B?logo=flutter&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

Application météo Flutter connectée à l'API **OpenWeatherMap**, avec
authentification JWT, cache local (Hive), mode hors-ligne, internationalisation
FR/EN, accessibilité et une suite de tests complète (unitaires, widgets,
intégration) exécutée en continu via GitHub Actions.

> Projet réalisé dans le cadre d'une certification Flutter — jalon final :
> *"Construire, tester et préparer une app Flutter pour la production."*

---

## 📱 Fonctionnalités

- **Authentification JWT** : inscription, connexion, déconnexion. Les JWT
  sont réellement générés, signés et vérifiés (voir
  [Authentification — pourquoi un mock ?](#-authentification--pourquoi-un-mock)).
- **5 écrans** :
  1. **Connexion** / **Inscription**
  2. **Accueil** — météo actuelle de la ville sélectionnée
  3. **Recherche** — recherche libre + historique des recherches
  4. **Prévisions** — prévisions à 5 jours / 3h
  5. **Enregistrés** — favoris + villes disponibles hors-ligne
- **Cache local** avec Hive : chaque météo consultée est mise en cache
  automatiquement.
- **Mode hors-ligne** : si le réseau est indisponible, l'app sert
  automatiquement les dernières données en cache (bannière visuelle
  "Hors ligne").
- **Gestion d'erreurs réseau** : messages utilisateur clairs (ville
  introuvable, pas de connexion, erreur serveur...) au lieu de crasher ou
  d'afficher une erreur technique.
- **Internationalisation** : français (par défaut) et anglais, bascule
  automatique selon la langue du système.
- **Accessibilité** : labels sémantiques (`Semantics`) sur tous les éléments
  interactifs — boutons, icônes, champs de recherche, bannière hors-ligne
  annoncée comme zone live pour les lecteurs d'écran.

---

## 🏗️ Architecture

Le projet suit une **Clean Architecture en Feature-First**, avec 3 couches
par fonctionnalité :

```
lib/
├── core/                          # Code transverse, partagé par toutes les features
│   ├── constants/                   # Constantes (URLs API, clés Hive...)
│   ├── error/                       # Failures (domain) & Exceptions (data)
│   ├── l10n/                        # AppLocalizations + dictionnaires FR/EN
│   ├── network/                     # Client Dio, intercepteur JWT, connectivité
│   ├── storage/                     # Stockage sécurisé des tokens
│   └── providers/                   # Providers Riverpod transverses (Hive boxes, locale...)
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/         # MockAuthDatasource (génère/valide les JWT)
│   │   │   ├── models/              # UserModel (Hive)
│   │   │   └── repositories/        # AuthRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/            # UserEntity, AuthSession (purs, sans dépendance Flutter)
│   │   │   ├── repositories/        # AuthRepository (interface/contrat)
│   │   │   └── usecases/            # LoginUseCase, RegisterUseCase...
│   │   └── presentation/
│   │       ├── providers/           # Providers Riverpod (AuthController)
│   │       └── screens/             # LoginScreen, RegisterScreen
│   │
│   ├── weather/                    # Même structure : data / domain / presentation
│   ├── favorites/                  # Idem (plus simple, pas de couche remote)
│   └── history/                    # Idem
│
└── main.dart                       # Init Hive/i18n, injection de dépendances, routing

test/
├── core/                            # Tests unitaires core (JwtValidator...)
├── features/                        # Tests unitaires par feature (miroir de lib/)
├── widgets/                         # Tests de widgets (formulaires, cartes, bannières)
└── helpers/                         # Helpers de test (Hive en tmpdir, wrapper MaterialApp)

integration_test/                    # Tests d'intégration bout-en-bout
test_driver/                         # Driver flutter drive pour l'exécution sur device
```

### Pourquoi cette architecture ?

- **`domain/`** ne dépend de rien (ni Flutter, ni Hive, ni Dio) — ce sont des
  règles métier pures, faciles à tester.
- **`data/`** implémente les contrats du domain et gère les détails
  techniques (API, cache, stockage).
- **`presentation/`** ne connaît que les abstractions du domain (jamais une
  implémentation concrète) — inversion de dépendance via les providers
  Riverpod.
- Chaque **feature** est autonome : `weather`, `favorites`, `history`,
  `auth`. Le seul couplage inter-features assumé est `weather` → `auth`
  (pour l'injection du token JWT dans les requêtes) et tout le reste →
  `core`.

### Authentification — pourquoi un mock ?

Le sujet demande des données réelles issues d'une API (ici OpenWeatherMap).
L'authentification, elle, n'a pas besoin d'un serveur dédié pour valider les
exigences : le flux JWT complet est **réellement exercé** (génération,
signature, vérification locale, stockage sécurisé, rafraîchissement,
intercepteur Dio, retry sur 401) — seul l'émetteur des tokens est local
(`MockAuthDatasource`), pas la mécanique JWT elle-même.

Pour brancher un vrai backend plus tard (ex. Laravel Sanctum) : remplacer
`MockAuthDatasource` par un `RemoteAuthDatasource` qui appelle
`/api/login`, `/api/register`, `/api/refresh` via Dio. L'interface
(`AuthRepository`) et tout le reste de l'app ne bougent pas.

---

## 🌍 Internationalisation

- Implémentation maison (`lib/core/l10n/`) : pas de génération de code via
  `flutter gen-l10n`, juste deux dictionnaires `l10n_fr.dart` / `l10n_en.dart`
  chargés par `AppLocalizations`. Simple, testable, sans étape de build
  supplémentaire.
- Langue suivie automatiquement depuis le système (`locale: null` par
  défaut) via `localeControllerProvider`, avec repli sur le français si la
  langue du système n'est ni FR ni EN.
- Utilisation dans le code : `AppLocalizations.of(context).loginTitle`.
- Pour ajouter une langue : créer `l10n_xx.dart`, l'ajouter dans
  `AppLocalizations` (constructeur + `supportedLocales`) et dans
  `_AppLocalizationsDelegate.isSupported`.

## ♿ Accessibilité

- Tous les boutons icône (déconnexion, favori, effacer l'historique,
  afficher/masquer le mot de passe) portent un `Semantics(label: ..., button: true)`.
- Les icônes météo sont annoncées comme `image` avec un label descriptif.
- La bannière hors-ligne utilise `liveRegion: true` pour être annoncée
  automatiquement par les lecteurs d'écran lors d'un changement de
  connectivité.
- Les statistiques secondaires de la carte météo (ressenti, humidité, vent)
  sont regroupées sous un unique `Semantics` lisible ("Ressenti : 31°C")
  plutôt que fragmentées en plusieurs `Text` isolés.

## ⚡ Performance

- `HomeScreen` utilise `IndexedStack` pour ses 3 onglets : les écrans ne
  sont construits qu'une fois et conservent leur état, au lieu d'être
  reconstruits à chaque tap sur la barre de navigation.
- Les images réseau (`Image.network`) sont décodées via `cacheWidth` /
  `cacheHeight` à la taille réellement affichée plutôt qu'à leur résolution
  native — réduit le coût mémoire/CPU du décodage.
- L'enregistrement d'une recherche dans l'historique est différé via
  `addPostFrameCallback` : plus aucune mutation de provider pendant la
  phase de `build`.
- `isFavoriteProvider` (dérivé, `family`) permet de ne reconstruire que le
  bouton favori concerné plutôt que tout l'écran d'accueil.
- Usage systématique de `const` sur les widgets statiques (`flutter_lints` +
  règle `prefer_const_constructors` activée dans `analysis_options.yaml`).

---

## ⚙️ Configuration & lancement

### 1. Prérequis

- Flutter SDK ≥ 3.24 (channel stable)
- Une clé API gratuite [OpenWeatherMap](https://openweathermap.org/api)
  (inscription gratuite, clé active sous quelques minutes à quelques heures)

### 2. Installation

```bash
git clone <url-du-repo>
cd weather_app
flutter pub get
```

### 3. Génération des adaptateurs Hive

Les fichiers `*.g.dart` sont déjà inclus dans le repo, mais si tu modifies
un modèle `@HiveType`, régénère-les avec :

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Lancer l'application

La clé API OpenWeatherMap est injectée via `--dart-define` (jamais
committée en dur) :

```bash
flutter run --dart-define=OWM_API_KEY=ta_clé_api_ici
```

Pour un build de production :

```bash
flutter build apk --release --dart-define=OWM_API_KEY=ta_clé_api_ici
```

> 💡 Astuce : pour éviter de retaper la clé à chaque fois, crée un fichier
> `env.sh` (déjà exclu par `.gitignore`) :
> ```bash
> #!/bin/bash
> flutter run --dart-define=OWM_API_KEY=ta_clé_api_ici
> ```

### 5. Qualité de code

```bash
dart format --output=none --set-exit-if-changed lib test   # formatage
flutter analyze --fatal-infos                                # analyse statique, 0 warning attendu
```

### 6. Lancer les tests

```bash
flutter test                    # tests unitaires + widgets
flutter test --coverage         # avec rapport de couverture

flutter test integration_test   # tests d'intégration (mode headless)
# ou, sur un device/émulateur connecté :
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/auth_flow_test.dart
```

**Couverture de la suite de tests :**

| Type | Où | Exemples |
|---|---|---|
| Unitaires (32+) | `test/features/**`, `test/core/` | Repositories Hive (favoris, historique), use cases (login, register, météo), validation JWT, repository auth/météo avec mocks `mocktail` |
| Widgets (12) | `test/widgets/` | `WeatherCard` (rendu, badge cache), `LoginScreen` (validation, visibilité mot de passe, navigation), `OfflineBanner` (bascule connecté/déconnecté) |
| Intégration (2) | `integration_test/` | Inscription → accueil → déconnexion → reconnexion (bout-en-bout, vraies box Hive) ; navigation entre onglets + recherche + ajout aux favoris |

---

## 🔄 Intégration continue

Le workflow [`.github/workflows/ci.yml`](.github/workflows/ci.yml)
s'exécute sur chaque push et pull request vers `main` :

1. **Lint** : `dart format --set-exit-if-changed`
2. **Analyse statique** : `flutter analyze --fatal-infos` (0 warning toléré)
3. **Tests** : unitaires + widgets avec rapport de couverture, puis tests
   d'intégration
4. **Build APK de démonstration** (uniquement sur `main`) : publié comme
   artefact téléchargeable depuis l'onglet *Actions* du dépôt

Pour que le job de build fonctionne avec une vraie clé API, ajoute un
secret de dépôt nommé `OWM_API_KEY` (*Settings → Secrets and variables →
Actions*).

---

## 📦 Dépendances principales

| Package | Rôle |
|---|---|
| `flutter_riverpod` | State management & injection de dépendances |
| `dio` | Client HTTP + intercepteurs |
| `hive` / `hive_flutter` | Cache local structuré (NoSQL) |
| `flutter_secure_storage` | Stockage chiffré des tokens JWT |
| `dart_jsonwebtoken` | Génération/vérification de JWT réels |
| `connectivity_plus` | Détection de l'état réseau |
| `fpdart` | Type `Either` pour la gestion d'erreurs fonctionnelle |
| `flutter_localizations` / `intl` | Internationalisation FR/EN et formats de date |
| `mocktail` | Mocking pour les tests unitaires |
| `integration_test` | Tests d'intégration bout-en-bout |

---

## 📸 Captures d'écran

> À compléter avec des captures réelles une fois l'app lancée localement —
> par exemple dans un dossier `docs/screenshots/` référencé ci-dessous.

| Connexion | Accueil | Prévisions | Enregistrés |
|---|---|---|---|
| _(à ajouter)_ | _(à ajouter)_ | _(à ajouter)_ | _(à ajouter)_ |

---

## 🗺️ Pistes d'amélioration

- Remplacer `MockAuthDatasource` par un vrai backend (Laravel Sanctum,
  Firebase Auth...).
- Ajouter la géolocalisation pour la météo de la position actuelle.
- Pagination / recherche multi-résultats via l'API de géocodage
  OpenWeatherMap.
- Golden tests sur les écrans principaux pour figer le rendu visuel.
- Sélecteur de langue manuel dans un écran de réglages (le
  `localeControllerProvider` existe déjà et n'attend qu'une UI).
