# Shelf Rush

Shelf Rush is a Flutter mobile puzzle game in the goods-sort triple-match genre.
The project is built with a feature-first architecture and SOLID design goals.

## Core Features

- Triple-match shelf gameplay loop.
- 7-slot tray pressure mechanic.
- Active run pause/resume persistence.
- Level objectives with 1-3 star ratings.
- Undo and shuffle controls.
- Purchasable extra-shuffle booster.
- Combo streak scoring with run summary overlay.
- Event-driven audio mixer (UI/gameplay/meta cues).
- Local telemetry event pipeline for funnel and economy analysis.
- Persistent profile and economy.
- Daily missions and achievement badges.
- Settings toggles (sound, haptic, reduced motion).

## Architecture

- `lib/core`: shared constants and theming.
- `lib/features/game/domain`: pure gameplay entities and services.
- `lib/features/game/application`: gameplay controllers and hub orchestration.
- `lib/features/game/presentation`: UI screens and widgets.
- `lib/features/meta`: persistence, progression, missions, achievements.

## Local Development

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Build Commands

```bash
flutter build apk --release
flutter build appbundle --release
```

## Quality Gates

- Static analysis must pass with zero issues.
- Tests must pass before every release build.
- CI workflow in `.github/workflows/flutter_ci.yml` enforces analyze/test/build.

## Product Docs

- `documents/PROJECT_RULES.md`
- `documents/ARCHITECTURE.md`
- `documents/COMPETITIVE_AUDIT.md`
- `documents/EXECUTION_TODO.md`
- `documents/GAME_DESIGN.md`
- `documents/UI_UX_GUIDELINES.md`
- `documents/MARKET_BENCHMARK_NOTES.md`
- `documents/DEPLOY_CHECKLIST.md`
- `documents/LIVEOPS_PLAN.md`
