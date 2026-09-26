import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../history/presentation/providers/history_providers.dart';
import '../providers/weather_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String city) {
    if (city.trim().isEmpty) return;
    ref.read(selectedCityProvider.notifier).state = city.trim();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(searchHistoryProvider);
    final l10n = AppLocalizations.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(l10n.searchTitle),
          floating: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Semantics(
              label: l10n.semSearchField,
              textField: true,
              child: TextField(
                key: const Key('city_search_field'),
                controller: _controller,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => _search(_controller.text),
                  ),
                ),
                onSubmitted: _search,
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
        ),
        if (history.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.recentSearches,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Semantics(
                    label: l10n.semClearHistory,
                    button: true,
                    child: TextButton(
                      onPressed: () => ref
                          .read(historyControllerProvider.notifier)
                          .clear(),
                      child: Text(l10n.clear),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(entry.cityName),
                onTap: () => _search(entry.cityName),
              );
            },
          ),
        ] else
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.searchEmptyState,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
