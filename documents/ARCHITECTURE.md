# Architecture Blueprint

## 1. Layer Model
- core
  - shared theme, constants, helpers.
- features/game/domain
  - entities, value objects, rule services.
- features/game/application
  - use cases and controller/state orchestration.
- features/game/presentation
  - screens and reusable widgets.

## 2. Dependency Direction
- presentation -> application -> domain
- presentation -> core
- application -> domain
- domain has no dependency on Flutter UI.

## 3. Main Components
- `GameConfig` (core): tuning values and level scaling.
- `ItemKind` (domain): item identity/type.
- `TileModel` (domain): board tile state.
- `TrayModel` (domain): selected items and match resolution.
- `BoardGenerator` (domain service): creates valid board sets.
- `MatchResolver` (domain service): resolves triples and score events.
- `GameSession` (domain): immutable gameplay snapshot.
- `GameController` (application): single source of truth for runtime state.
- `RunSessionRepository` (data): persist/restore active gameplay session.
- `GameHubController` (application): orchestrates gameplay + progression + active-run persistence.
- Presentation widgets read controller and dispatch intents.

## 4. State Strategy
- Use immutable state snapshots for game session.
- Controller methods perform intent-driven transitions:
  - startLevel
  - tapTile
  - undo
  - shuffleRemaining
  - restart
- Hub restores paused run on app launch when available.
- Keep random operations seedable for reproducibility.

## 5. Error and Edge-Case Strategy
- Reject tile taps when game is over.
- Ignore taps on already collected tiles.
- Guard undo stack size.
- Keep tray capacity invariant.

## 6. Testability Plan
- Unit tests target domain services and level generation.
- Widget tests verify tray, board, and end-state overlays.
- Golden tests can be added for key screens after styling stabilizes.

## 7. Extensibility Hooks
- Add boosters as application use cases without altering core rules.
- Add progression/meta systems as separate feature modules.
- Add ad/analytics adapters only in data/infrastructure layer.
