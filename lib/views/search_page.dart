import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_tcg/model/pokemon_card.dart';
import 'package:pokedex_tcg/viewmodels/app_settings_viewmodel.dart';
import 'package:pokedex_tcg/viewmodels/card_search_viewmodel.dart';
import 'package:pokedex_tcg/views/detail_page.dart';
import 'package:pokedex_tcg/widgets/app_drawer.dart';
import 'package:pokedex_tcg/widgets/card_grid_item.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<AppSettingsViewModel>().languageCode;

    return ChangeNotifierProvider(
      key: ValueKey(languageCode),
      create: (_) => CardSearchViewModel(languageCode: languageCode),
      child: const _SearchScaffold(),
    );
  }
}

class _SearchScaffold extends StatelessWidget {
  const _SearchScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Cards'),
      ),
      drawer: const AppDrawer(),
      body: const _SearchBody(),
    );
  }
}

class _SearchBody extends StatefulWidget {
  const _SearchBody();

  @override
  State<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CardSearchViewModel>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Look for any Pokemon card by name.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Try "Pikachu" or "Charizard"',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (value) {
                    context.read<CardSearchViewModel>().updateQuery(value);
                  },
                  onSubmitted: (_) {
                    context.read<CardSearchViewModel>().searchCards();
                  },
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  context.read<CardSearchViewModel>().searchCards();
                },
                child: const Text('Search'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _SearchResults(viewModel: viewModel),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final CardSearchViewModel viewModel;

  const _SearchResults({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Text(
          viewModel.errorMessage!,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Theme.of(context).colorScheme.error),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (!viewModel.hasSearched) {
      return Center(
        child: Text(
          'Start a search to see cards here.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    if (!viewModel.hasResults) {
      return Center(
        child: Text(
          'No cards found. Try another search.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return _CardGrid(cards: viewModel.results);
  }
}

class _CardGrid extends StatelessWidget {
  final List<PokemonCard> cards;

  const _CardGrid({required this.cards});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.716,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return CardGridItem(
          card: card,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(card: card),
              ),
            );
          },
        );
      },
    );
  }
}
