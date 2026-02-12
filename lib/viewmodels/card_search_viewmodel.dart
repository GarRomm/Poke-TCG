import 'package:flutter/foundation.dart';
import 'package:pokedex_tcg/model/pokemon_card.dart';
import 'package:pokedex_tcg/services/pokemon_tcg_service.dart';

class CardSearchViewModel extends ChangeNotifier {
  final PokemonTcgService _service;

  CardSearchViewModel({String languageCode = 'fr'})
      : _service = PokemonTcgService(languageCode: languageCode);

  String _query = '';
  bool _isLoading = false;
  String? _errorMessage;
  List<PokemonCard> _results = const [];
  bool _hasSearched = false;

  String get query => _query;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PokemonCard> get results => _results;
  bool get hasResults => _results.isNotEmpty;
  bool get hasSearched => _hasSearched;

  void updateQuery(String query) {
    _query = query;
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

  Future<void> searchCards() async {
    final trimmed = _query.trim();
    if (trimmed.isEmpty) {
      _errorMessage = 'Saisis un nom de carte pour lancer la recherche.';
      _results = const [];
      _hasSearched = true;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _hasSearched = true;
    notifyListeners();

    try {
      final cards = await _service.searchCardsByName(trimmed);
      _results = cards;
      if (cards.isEmpty) {
        _errorMessage = 'Aucune carte trouvée pour "$trimmed".';
      }
    } catch (error) {
      _errorMessage = _toUserMessage(error);
      _results = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
