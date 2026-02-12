import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex_tcg/model/pokemon_card.dart';

class DetailPage extends StatelessWidget {
  final PokemonCard card;

  const DetailPage({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(card.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Hero(
                    tag: 'card-${card.id}',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: card.images.large.isNotEmpty
                              ? card.images.large
                              : card.images.small,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Container(
                            height: 320,
                            alignment: Alignment.center,
                            color: colorScheme.surfaceContainerHighest,
                            child:
                                const CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) {
                            return Container(
                              height: 320,
                              alignment: Alignment.center,
                              color: colorScheme.surfaceContainerHighest,
                              child: const Text('Image unavailable'),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _InfoChip(label: 'Category', value: card.category),
                  _InfoChip(label: 'HP', value: card.hp ?? 'Unknown'),
                  _InfoChip(
                    label: 'Rarity',
                    value: card.rarity ?? 'Unknown',
                  ),
                  if ((card.trainerType ?? '').isNotEmpty)
                    _InfoChip(label: 'Trainer', value: card.trainerType!),
                  if ((card.energyType ?? '').isNotEmpty)
                    _InfoChip(label: 'Energy', value: card.energyType!),
                  _InfoChip(label: 'Set', value: card.setInfo.name),
                  if (card.setInfo.series.isNotEmpty)
                    _InfoChip(label: 'Series', value: card.setInfo.series),
                ],
              ),
              if (card.types.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Types',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: card.types
                      .map((type) => Chip(label: Text(type)))
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  card.attacks.isNotEmpty ? 'Attacks' : 'Card Text',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              if (card.attacks.isEmpty)
                Text(
                  (card.effect ?? '').isNotEmpty
                      ? card.effect!
                      : 'No additional text for this card.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                )
              else
                Column(
                  children: card.attacks
                      .map(
                        (attack) => Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      attack.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    attack.damage.isEmpty
                                        ? '--'
                                        : attack.damage,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                              if (attack.text.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  attack.text,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
