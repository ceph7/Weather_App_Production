import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../../../history/presentation/providers/history_providers.dart';
import '../providers/weather_providers.dart';
import '../widgets/offline_banner.dart';
import '../widgets/weather_card.dart';
import 'forecast_screen.dart';
import 'search_screen.dart';
import 'saved_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;

  // Instances construites une seule fois : évite de reconstruire les 3
  // écrans à chaque changement d'onglet (IndexedStack les garde en vie).
  static const _screens = [
    _WeatherHomeTab(),
    SearchScreen(),
    SavedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: IndexedStack(index: _tabIndex, children: _screens),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.wb_sunny_outlined),
            selectedIcon: const Icon(Icons.wb_sunny),
            label: l10n.navWeather,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search),
            label: l10n.navSearch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_outline),
            selectedIcon: const Icon(Icons.bookmark),
            label: l10n.navSaved,
          ),
        ],
      ),
    );
  }
}

class _WeatherHomeTab extends ConsumerWidget {
  const _WeatherHomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentWeatherProvider);
    final city = ref.watch(selectedCityProvider);
    final user = ref.watch(authControllerProvider).valueOrNull;
    final l10n = AppLocalizations.of(context);
    final isFavorite = ref.watch(isFavoriteProvider(city));

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text(user != null ? l10n.greeting(user.name) : l10n.weather),
          actions: [
            Semantics(
              label: l10n.semLogoutButton,
              button: true,
              child: IconButton(
                icon: const Icon(Icons.logout),
                tooltip: l10n.logout,
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(currentWeatherProvider);
              await ref.read(currentWeatherProvider.future).catchError((_) {});
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: weatherAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => _ErrorState(
                  message: error.readableMessage(context),
                  onRetry: () => ref.invalidate(currentWeatherProvider),
                ),
                data: (weather) {
                  // Effet de bord (enregistrement dans l'historique) sorti du
                  // build via un post-frame callback pour ne jamais modifier
                  // un provider pendant la construction du widget.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(historyControllerProvider.notifier).record(city);
                  });
                  return Column(
                    children: [
                      WeatherCard(weather: weather),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ForecastScreen(city: city),
                                ),
                              ),
                              icon: const Icon(Icons.calendar_today_outlined),
                              label: Text(l10n.forecast5Days),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Semantics(
                            label: l10n.semFavoriteToggle,
                            button: true,
                            child: FilledButton.tonalIcon(
                              onPressed: () => ref
                                  .read(favoritesControllerProvider.notifier)
                                  .toggle(city),
                              icon: Icon(
                                isFavorite ? Icons.star : Icons.star_border,
                              ),
                              label: Text(l10n.favorite),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
