import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_tcg/model/pokemon_card.dart';
import 'package:pokedex_tcg/viewmodels/app_settings_viewmodel.dart';
import 'package:pokedex_tcg/viewmodels/explore_viewmodel.dart';
import 'package:pokedex_tcg/views/detail_page.dart';
import 'package:pokedex_tcg/widgets/app_drawer.dart';
import 'package:pokedex_tcg/widgets/card_grid_item.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<AppSettingsViewModel>().languageCode;

    return ChangeNotifierProvider(
      key: ValueKey(languageCode),
      create: (_) =>
          ExploreViewModel(languageCode: languageCode)..loadInitial(),
      child: const _ExploreScaffold(),
    );
  }
}

class _ExploreScaffold extends StatefulWidget {
  const _ExploreScaffold();

  @override
  State<_ExploreScaffold> createState() => _ExploreScaffoldState();
}

class _ExploreScaffoldState extends State<_ExploreScaffold> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final viewModel = context.read<ExploreViewModel>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      viewModel.loadNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Cards'),
      ),
      drawer: const AppDrawer(),
      body: Consumer<ExploreViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.cards.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null && viewModel.cards.isEmpty) {
            return Center(
              child: Text(
                viewModel.errorMessage!,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'First 20 cards from the API, with infinite scroll.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: viewModel.loadInitial,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _ExploreGrid(
                  cards: viewModel.cards,
                  controller: _scrollController,
                ),
              ),
              if (viewModel.isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: CircularProgressIndicator(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ExploreGrid extends StatelessWidget {
  final List<PokemonCard> cards;
  final ScrollController controller;

  const _ExploreGrid({
    required this.cards,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 800
            ? 4
            : width >= 560
                ? 3
                : 2;

        return GridView.builder(
          controller: controller,
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
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
      },
    );
  }
}
