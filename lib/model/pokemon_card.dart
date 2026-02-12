class PokemonCard {
  final String id;
  final String name;
  final String category;
  final String? hp;
  final List<String> types;
  final String? rarity;
  final String? effect;
  final String? trainerType;
  final String? energyType;
  final CardImages images;
  final List<CardAttack> attacks;
  final CardSetInfo setInfo;

  PokemonCard({
    required this.id,
    required this.name,
    required this.category,
    required this.images,
    required this.setInfo,
    this.hp,
    this.types = const [],
    this.rarity,
    this.effect,
    this.trainerType,
    this.energyType,
    this.attacks = const [],
  });

  PokemonCard copyWith({
    String? id,
    String? name,
    String? category,
    String? hp,
    List<String>? types,
    String? rarity,
    String? effect,
    String? trainerType,
    String? energyType,
    CardImages? images,
    List<CardAttack>? attacks,
    CardSetInfo? setInfo,
  }) {
    return PokemonCard(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      hp: hp ?? this.hp,
      types: types ?? this.types,
      rarity: rarity ?? this.rarity,
      effect: effect ?? this.effect,
      trainerType: trainerType ?? this.trainerType,
      energyType: energyType ?? this.energyType,
      images: images ?? this.images,
      attacks: attacks ?? this.attacks,
      setInfo: setInfo ?? this.setInfo,
    );
  }

  factory PokemonCard.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'] as Map<String, dynamic>?;
    final setJson = json['set'] as Map<String, dynamic>?;
    final attacksJson = json['attacks'] as List<dynamic>?;
    final hpValue = json['hp'];

    return PokemonCard(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Unknown',
      hp: hpValue?.toString(),
      types: (json['types'] as List<dynamic>?)
              ?.map((type) => type.toString())
              .toList() ??
          const [],
      rarity: json['rarity']?.toString(),
      effect: json['effect']?.toString(),
      trainerType: json['trainerType']?.toString(),
      energyType: json['energyType']?.toString(),
      images: CardImages.fromJson({
        ...?imagesJson,
        'image': json['image'],
      }),
      setInfo: CardSetInfo.fromJson(setJson ?? const {}),
      attacks:
          attacksJson?.map((attack) => CardAttack.fromJson(attack)).toList() ??
              const [],
    );
  }
}

class CardImages {
  final String small;
  final String large;

  const CardImages({
    required this.small,
    required this.large,
  });

  static bool _hasImageExtension(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.webp') ||
        lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg');
  }

  static String _buildTcgdexCardAssetUrl(
    String baseUrl, {
    required String quality,
  }) {
    final trimmed = baseUrl.trim();
    if (trimmed.isEmpty) return '';

    if (_hasImageExtension(trimmed)) {
      return trimmed;
    }

    final normalized = trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;

    return '$normalized/$quality.webp';
  }

  factory CardImages.fromJson(Map<String, dynamic> json) {
    final image = json['image']?.toString() ?? '';
    final smallRaw = json['small']?.toString() ?? '';
    final largeRaw = json['large']?.toString() ?? '';

    final small = smallRaw.isNotEmpty
        ? _buildTcgdexCardAssetUrl(smallRaw, quality: 'low')
        : _buildTcgdexCardAssetUrl(image, quality: 'low');

    final large = largeRaw.isNotEmpty
        ? _buildTcgdexCardAssetUrl(largeRaw, quality: 'high')
        : _buildTcgdexCardAssetUrl(image, quality: 'high');

    return CardImages(
      small: small,
      large: large,
    );
  }
}

class CardAttack {
  final String name;
  final String damage;
  final String text;

  CardAttack({
    required this.name,
    required this.damage,
    required this.text,
  });

  factory CardAttack.fromJson(Map<String, dynamic> json) {
    return CardAttack(
      name: json['name']?.toString() ?? '',
      damage: json['damage']?.toString() ?? '',
      text: (json['text'] ?? json['effect'])?.toString() ?? '',
    );
  }
}

class CardSetInfo {
  final String name;
  final String series;

  const CardSetInfo({
    required this.name,
    required this.series,
  });

  factory CardSetInfo.fromJson(Map<String, dynamic> json) {
    final serieJson = json['serie'] as Map<String, dynamic>?;
    final seriesJson = json['series'] as Map<String, dynamic>?;

    return CardSetInfo(
      name: json['name']?.toString() ?? '',
      series: (json['series'] ?? seriesJson?['name'] ?? serieJson?['name'])
              ?.toString() ??
          '',
    );
  }
}
