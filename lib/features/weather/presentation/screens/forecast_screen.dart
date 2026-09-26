import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../providers/weather_providers.dart';

class ForecastScreen extends ConsumerWidget {
  final String city;

  const ForecastScreen({super.key, required this.city});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastAsync = ref.watch(forecastProvider);
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat(
      'EEE dd/MM à HH:mm',
      Localizations.localeOf(context).languageCode == 'en' ? 'en_US' : 'fr_FR',
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.forecastTitle(city))),
      body: forecastAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  error.readableMessage(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (forecasts) {
          if (forecasts.isEmpty) {
            return Center(child: Text(l10n.noForecastAvailable));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: forecasts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final f = forecasts[index];
              String label;
              try {
                label = dateFormat.format(f.dateTime);
              } catch (_) {
                label = f.dateTime.toString();
              }
              final description =
                  f.description.isEmpty
                      ? f.description
                      : f.description[0].toUpperCase() +
                          f.description.substring(1);
              return ListTile(
                leading: Semantics(
                  label: l10n.semWeatherIcon,
                  image: true,
                  child: Image.network(
                    f.iconUrl,
                    width: 40,
                    height: 40,
                    cacheWidth: 80,
                    errorBuilder: (_, __, ___) => const Icon(Icons.cloud),
                  ),
                ),
                title: Text(label),
                subtitle: Text(description),
                trailing: Text(
                  '${f.temperature.round()}°C',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
