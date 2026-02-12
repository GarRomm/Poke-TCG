# Pokedex TCG

Flutter app that explores Pokemon cards using the TCGdex API.

## Features

- Home page with navigation drawer
- Search cards by name (grid results, loading/error/empty states)
- Explore the first 20 cards with infinite scroll
- Detail page with high-res image, stats, and attacks

## Architecture (MVVM)

```
lib/
├── main.dart
├── model/
│   └── pokemon_card.dart
├── services/
│   └── pokemon_tcg_service.dart
├── viewmodels/
│   ├── card_search_viewmodel.dart
│   ├── explore_viewmodel.dart
│   └── home_viewmodel.dart
├── views/
│   ├── detail_page.dart
│   ├── explore_page.dart
│   ├── home_page.dart
│   └── search_page.dart
└── widgets/
    ├── app_drawer.dart
    └── card_grid_item.dart
```

## Setup

1. Run:

```
flutter pub get
```

2. Start the app:

```
flutter run
```

## Language configuration

- The API language is configurable at runtime from the app drawer (`Langue des données TCGdex`).
- The app queries `https://api.tcgdex.net/v2/{lang}/...` using the selected language.
- Current supported languages: `fr`, `en`, `de`, `es`, `it`, `pt`.

## API

- Documentation: https://tcgdex.dev/rest/cards
- Card schema reference: https://tcgdex.dev/reference/card
- Card assets (image quality/format): https://tcgdex.dev/assets

## Notes on TCGdex data

- `GET /v2/en/cards` returns `CardBrief` items (id, name, localId, image).
- Full fields (`hp`, `types`, `attacks`, `effect`, etc.) come from detailed card payloads.
- Card image URLs are asset bases and are resolved as:
    - `.../low.webp` for list thumbnails
    - `.../high.webp` for detail views
- Some fields are optional in TCGdex and may be absent for specific cards.
- When `rarity` or image is missing in the selected language, the app falls back to `en` for those fields only.

## Security / audit

- Sensitive and local files are ignored via `.gitignore` (`.env*`, keystores, certs, Firebase config, local build artifacts).
- Use `.env.example` as template and keep real values in local `.env` only.
- Before sharing or opening a PR, run:

```
git status --short
git check-ignore -v .env android/local.properties ios/Pods/ build/
```
