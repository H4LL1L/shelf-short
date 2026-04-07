# Project Rules

## 1. Product Identity
- Build an original mobile shelf-sorting puzzle inspired by the goods match genre.
- Do not copy brand names, packaging, character art, screenshots, or level layouts from benchmark apps.
- Keep the interaction familiar, but keep every shipped visual asset original.

## 2. Platform Rule
- The gameplay codebase must stay Flutter-first so the same feature set ships to iOS and Android.
- Platform-specific work should stay limited to packaging, signing, and native integration details.

## 3. Engineering Principles
- Keep game rules independent from Flutter UI so they remain testable.
- Prefer small focused widgets over large monolithic screens.
- Keep rendering data-driven: product shape, size, and color live in catalog metadata rather than scattered widget logic.
- Preserve deterministic behavior for seeded levels.

## 4. Gameplay Rules
- Every product type appears in multiples of 3.
- Any visible product in an open compartment may move.
- A destination is valid only if it is not full and is either empty or topped by the same product type.
- A compartment closes only when all visible products inside it are identical and the count is 3 or 4.
- Win when all products are cleared.
- Lose when no legal move remains.

## 5. UI Rules
- The board must read as a cabinet wall with visible shelf depth.
- Products must be drawn as original SKU silhouettes, never emoji placeholders in release UI.
- Product size should be proportion-driven so short cans and tall bottles feel different.
- Critical controls must stay visible during play: pause, restart, undo, shuffle.

## 6. Quality Rules
- Keep files focused and avoid duplicating palette or geometry constants.
- Add comments only where geometry or rendering logic would otherwise be hard to follow.
- Update markdown docs whenever gameplay or visual direction changes materially.

## 7. Performance Rules
- Avoid expensive per-frame work during drag interactions.
- Keep custom painting lightweight and deterministic.
- Limit rebuild scope to active gameplay widgets when possible.

## 8. Delivery Rules
- Every milestone must remain playable on phone-sized layouts.
- `flutter analyze` and `flutter test` must pass before a milestone is considered complete.
- No dead controls or placeholder presentation should remain on the main gameplay path.
