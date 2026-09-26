import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../providers/weather_providers.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesListProvider);
    final cachedAsync = ref.watch(cachedWeatherListProvider);
    final l10n = AppLocalizations.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(title: Text(l10n.savedTitle), floating: true),
        if (favorites.isNotEmpty) ...[
          _SectionHeader(title: l10n.favoritesSection, icon: Icons.star),
          SliverList.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final city = favorites[index];
              return ListTile(
                leading: const Icon(Icons.location_city),
                title: Text(city),
                trailing: Semantics(
                  label: l10n.semFavoriteToggle,
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.star, color: Colors.amber),
                    onPressed: () => ref
                        .read(favoritesControllerProvider.notifier)
                        .toggle(city),
                  ),
                ),
                onTap: () =>
                    ref.read(selectedCityProvider.notifier).state = city,
              );
            },
          ),
        ],
        _SectionHeader(
          title: l10n.offlineAvailableSection,
          icon: Icons.cloud_off,
        ),
        cachedAsync.when(
          loading: () => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.cacheLoadError),
            ),
          ),
          data: (list) {
            if (list.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.noCacheYet,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }
            return SliverList.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final weather = list[index];
                return ListTile(
                  leading: Semantics(
                    label: l10n.semWeatherIcon,
                    image: true,
                    child: Image.network(
                      weather.iconUrl,
                      width: 36,
                      height: 36,
                      cacheWidth: 72,
                      errorBuilder: (_, __, ___) => const Icon(Icons.cloud),
                    ),
                  ),
                  title: Text(weather.cityName),
                  subtitle: Text(
                    '${weather.temperature.round()}°C — ${weather.description}',
                  ),
                  onTap: () => ref.read(selectedCityProvider.notifier).state =
                      weather.cityName,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}
