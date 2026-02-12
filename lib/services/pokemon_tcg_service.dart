import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedex_tcg/model/pokemon_card.dart';

class PokemonTcgApiException implements Exception {
  final int statusCode;
  final String body;

  const PokemonTcgApiException({required this.statusCode, required this.body});

  @override
  String toString() => 'PokemonTcgApiException(statusCode: $statusCode)';
}

class PokemonTcgNetworkException implements Exception {
  final String message;

  const PokemonTcgNetworkException(this.message);

  @override
  String toString() => 'PokemonTcgNetworkException(message: $message)';
}

class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  _CacheEntry(this.data) : timestamp = DateTime.now();

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }
}

class PokemonTcgService {
  static const String _baseHost = 'api.tcgdex.net';
  static const String _fallbackLanguage = 'en';
  static const Duration _cacheTtl = Duration(minutes: 10);

  final String _languageCode;
  final Map<String, _CacheEntry> _cache = {};

  PokemonTcgService({String languageCode = 'fr'})
      : _languageCode = languageCode;

  Uri _buildUri(
    String path, {
    Map<String, String>? query,
    String? languageCode,
  }) {
    final language = languageCode ?? _languageCode;
    return Uri.https(_baseHost, '/v2/$language$path', query);
  }

  Future<http.Response> _get(
    String path, {
    Map<String, String>? query,
    String? languageCode,
  }) async {
    try {
      return await http.get(
        _buildUri(path, query: query, languageCode: languageCode),
      );
    } catch (_) {
      throw const PokemonTcgNetworkException(
        'Network error while contacting TCGdex API.',
      );
    }
  }

  void _throwIfResponseError(http.Response response) {
    if (response.statusCode == 200) return;
    throw PokemonTcgApiException(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  bool _isBlank(String? value) => value == null || value.trim().isEmpty;

  PokemonCard _mergeWithFallback(PokemonCard primary, PokemonCard fallback) {
    final images = CardImages(
      small: primary.images.small.isNotEmpty
          ? primary.images.small
          : fallback.images.small,
      large: primary.images.large.isNotEmpty
          ? primary.images.large
          : fallback.images.large,
    );

    return primary.copyWith(
      hp: _isBlank(primary.hp) ? fallback.hp : primary.hp,
      rarity: _isBlank(primary.rarity) ? fallback.rarity : primary.rarity,
      effect: _isBlank(primary.effect) ? fallback.effect : primary.effect,
      trainerType: _isBlank(primary.trainerType)
          ? fallback.trainerType
          : primary.trainerType,
      energyType: _isBlank(primary.energyType)
          ? fallback.energyType
          : primary.energyType,
      types: primary.types.isEmpty ? fallback.types : primary.types,
      attacks: primary.attacks.isEmpty ? fallback.attacks : primary.attacks,
      images: images,
    );
  }

  Future<PokemonCard> _fetchCardDetail(
    String id, {
    String? briefImage,
  }) async {
    final response = await _get('/cards/$id');
    _throwIfResponseError(response);

    final jsonBody = json.decode(response.body) as Map<String, dynamic>;
    final localizedCard = PokemonCard.fromJson({
      ...jsonBody,
      'image': jsonBody['image'] ?? briefImage,
    });

    if (_languageCode == _fallbackLanguage) {
      return localizedCard;
    }

    final shouldFallback = _isBlank(localizedCard.rarity) ||
        localizedCard.images.small.isEmpty ||
        localizedCard.images.large.isEmpty;

    if (!shouldFallback) {
      return localizedCard;
    }

    final fallbackResponse = await _get(
      '/cards/$id',
      languageCode: _fallbackLanguage,
    );
    _throwIfResponseError(fallbackResponse);

    final fallbackJson =
        json.decode(fallbackResponse.body) as Map<String, dynamic>;
    final fallbackCard = PokemonCard.fromJson({
      ...fallbackJson,
      'image': fallbackJson['image'] ?? briefImage,
    });

    return _mergeWithFallback(localizedCard, fallbackCard);
  }

  Future<List<PokemonCard>> _fetchCardDetailsByBriefs(
    List<Map<String, dynamic>> briefs,
  ) async {
    final futures = briefs.map((brief) async {
      final id = brief['id']?.toString() ?? '';
      if (id.isEmpty) {
        throw const PokemonTcgApiException(
          statusCode: 500,
          body: 'Missing card id in CardBrief response.',
        );
      }
      return _fetchCardDetail(
        id,
        briefImage: brief['image']?.toString(),
      );
    }).toList();

    return Future.wait(futures);
  }

  String _cacheKey(String method, Map<String, dynamic> params) {
    final sortedParams = params.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final paramString =
        sortedParams.map((e) => '${e.key}=${e.value}').join('&');
    return '$method?$paramString';
  }

  Future<List<PokemonCard>> searchCardsByName(
    String name, {
    int page = 1,
    int pageSize = 24,
  }) async {
    if (name.trim().isEmpty) return const [];

    final key = _cacheKey('searchCardsByName', {
      'name': name.trim(),
      'page': page,
      'pageSize': pageSize,
      'lang': _languageCode,
    });

    final cached = _cache[key];
    if (cached != null && !cached.isExpired(_cacheTtl)) {
      return cached.data as List<PokemonCard>;
    }

    final response = await _get('/cards', query: {
      'name': name.trim(),
      'pagination:page': page.toString(),
      'pagination:itemsPerPage': pageSize.toString(),
    });
    _throwIfResponseError(response);

    final items = json.decode(response.body) as List<dynamic>;
    final briefs = items
        .map((item) => item as Map<String, dynamic>)
        .where((item) => (item['id']?.toString() ?? '').isNotEmpty)
        .toList();

    final result = await _fetchCardDetailsByBriefs(briefs);

    _cache[key] = _CacheEntry(result);

    return result;
  }

  Future<List<PokemonCard>> fetchCards({
    int page = 1,
    int pageSize = 20,
  }) async {
    final key = _cacheKey('fetchCards', {
      'page': page,
      'pageSize': pageSize,
      'lang': _languageCode,
    });

    final cached = _cache[key];
    if (cached != null && !cached.isExpired(_cacheTtl)) {
      return cached.data as List<PokemonCard>;
    }

    final response = await _get('/cards', query: {
      'pagination:page': page.toString(),
      'pagination:itemsPerPage': pageSize.toString(),
      'sort:field': 'name',
      'sort:order': 'ASC',
    });
    _throwIfResponseError(response);

    final items = json.decode(response.body) as List<dynamic>;
    final briefs = items
        .map((item) => item as Map<String, dynamic>)
        .where((item) => (item['id']?.toString() ?? '').isNotEmpty)
        .toList();

    final result = await _fetchCardDetailsByBriefs(briefs);

    _cache[key] = _CacheEntry(result);

    return result;
  }
}
