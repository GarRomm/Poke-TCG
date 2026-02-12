import 'package:flutter/foundation.dart';

class AppSettingsViewModel extends ChangeNotifier {
  static const Map<String, String> supportedLanguages = {
    'fr': 'Français',
    'en': 'English',
    'de': 'Deutsch',
    'es': 'Español',
    'it': 'Italiano',
    'pt': 'Português',
  };

  String _languageCode = 'fr';

  String get languageCode => _languageCode;

  void setLanguageCode(String code) {
    if (!supportedLanguages.containsKey(code)) return;
    if (_languageCode == code) return;
    _languageCode = code;
    notifyListeners();
  }
}
