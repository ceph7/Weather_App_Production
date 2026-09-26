import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/weather_entity.dart';

class WeatherCard extends StatelessWidget {
  final WeatherEntity weather;

  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final description = weather.description.isEmpty
        ? weather.description
        : weather.description[0].toUpperCase() +
            weather.description.substring(1);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${weather.cityName}, ${weather.country}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (weather.isFromCache)
                  Chip(
                    label: Text(l10n.cacheLabel, style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                    avatar: const Icon(Icons.cloud_off, size: 14),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Semantics(
              label: l10n.semWeatherIcon,
              image: true,
              child: Image.network(
                weather.iconUrl,
                width: 100,
                height: 100,
                // Décode l'image à la taille d'affichage réelle (x2 pour les
                // écrans à forte densité) plutôt qu'à sa résolution native :
                // réduit fortement le coût mémoire/CPU de décodage.
                cacheWidth: 200,
                cacheHeight: 200,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.wb_cloudy_outlined, size: 80),
              ),
            ),
            Text(
              '${weather.temperature.round()}°C',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: Icons.thermostat,
                  label: l10n.feelsLike,
                  value: '${weather.feelsLike.round()}°C',
                ),
                _StatItem(
                  icon: Icons.water_drop_outlined,
                  label: l10n.humidity,
                  value: '${weather.humidity}%',
                ),
                _StatItem(
                  icon: Icons.air,
                  label: l10n.wind,
                  value: '${weather.windSpeed.round()} m/s',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label : $value',
      child: ExcludeSemantics(
        child: Column(
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
