import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/core_providers.dart';

/// Bannière discrète affichée en haut de l'écran quand il n'y a pas de
/// connexion réseau. Écoute [connectivityStreamProvider] en direct.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityStreamProvider);
    final l10n = AppLocalizations.of(context);

    return connectivity.when(
      data: (isConnected) {
        if (isConnected) return const SizedBox.shrink();
        return Semantics(
          liveRegion: true,
          label: l10n.semOfflineIndicator,
          child: Container(
            width: double.infinity,
            color: Colors.orange.shade700,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  l10n.offlineBanner,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
