import 'package:flutter/foundation.dart';
import 'package:pokedex_tcg/model/pokemon_card.dart';
import 'package:pokedex_tcg/services/pokemon_tcg_service.dart';

class ExploreViewModel extends ChangeNotifier {
  final PokemonTcgService _service;

  ExploreViewModel({String languageCode = 'fr'})
      : _service = PokemonTcgService(languageCode: languageCode);

  List<PokemonCard> _cards = const [];
  bool _isLoading = false;
  String? _errorMessage;
  int _page = 1;
  bool _hasMore = true;
  bool _isDisposed = false;

  List<PokemonCard> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> loadInitial() async {
    _cards = const [];
    _page = 1;
    _hasMore = true;
    _errorMessage = null;
    await _loadPage();
  }

  Future<void> loadNext() async {
    if (_isLoading || !_hasMore) return;
    await _loadPage();
  }

  String _toUserMessage(Object error) {
    if (error is PokemonTcgNetworkException) {
      return 'Impossible de contacter le service TCGdex. Vérifie ta connexion puis réessaie.';
    }
    if (error is PokemonTcgApiException) {
      if (error.statusCode == 504) {
        return 'Le service TCGdex a expiré (504). Réessaie dans un instant.';
      }
      if (error.statusCode >= 500) {
        return 'Le service TCGdex est temporairement indisponible. Réessaie plus tard.';
      }
      if (error.statusCode == 429) {
        return 'Trop de requêtes en ce moment. Patiente un peu puis réessaie.';
      }
      return 'La requête a échoué (HTTP ${error.statusCode}).';
    }
    return 'Impossible de charger les cartes pour le moment.';
  }

  Future<void> _loadPage() async {
    _isLoading = true;
    _safeNotifyListeners();

    try {
      final cards = await _service.fetchCards(page: _page);
      if (_isDisposed) return;
      if (cards.isEmpty) {
        _hasMore = false;
      } else {
        _cards = [..._cards, ...cards];
        _page += 1;
      }
    } catch (error) {
      _errorMessage = _toUserMessage(error);
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
