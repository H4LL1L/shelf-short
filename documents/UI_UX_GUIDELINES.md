# UI and UX Guidelines

## 1. Visual Direction
- Bright market shelf theme.
- Warm neutral background with colorful item cards.
- Rounded corners and soft shadows for tactile feel.
- Wooden compartment look for board cells (toy-store shelf feeling).
- Saturated product-card accents per item (readable even at small sizes).
- Prefer playful polish over minimal flat UI.

## 2. Layout Composition
- Top HUD:
  - level label
  - score
  - combo and coin stats
  - pause and restart controls
- Objective strip:
  - score target progress
  - combo target progress
  - live star indicator (0-3)
- Center board:
  - stacked shelf rows (drag-drop between shelves)
- Action row:
  - undo and shuffle actions
  - booster purchase action (+1 shuffle)
- Home dashboard:
  - quick start
  - resume active run CTA
  - progression cards (missions + achievements)
  - level map with stars and last-played highlight

## 3. Typography
- Use a friendly geometric sans font.
- High readability for score and action labels.
- Keep hierarchy clear with 3 text scales.

## 4. Motion
- Tile press: 120ms scale down/up.
- Drag start: active item lifts slightly.
- Shelf close: shelf row locks with closed overlay after 3/4 same items.
- Screen transitions: subtle slide/fade.
- App lifecycle: auto-pause active run when app goes background.

## 5. Color Tokens
- `bgPrimary`, `bgAccent`, `surface`, `surfaceAlt`.
- `textPrimary`, `textMuted`.
- `success`, `danger`, `warning`.

## 6. Component Behaviors
- Tile:
  - products are moved shelf-to-shelf with drag-drop.
  - only top product in each shelf stack is draggable.
  - disabled style after collected.
- Shelf row:
  - accepts only valid drops (empty row slot or same-top product).
  - closes when all visible products on that shelf are same and count is 3 or 4.
  - closed shelf must look locked and not accept input.
- Buttons:
  - distinct primary vs secondary styles.
  - visible pressed state.
  - if haptic setting is enabled, interactions trigger subtle haptic.
  - missions section should provide `Claim All` when multiple rewards are ready.

## 7. Empty/Error States
- If generation fails, show fallback level error card with retry.
- If no shuffle charge, disable button with clear reason.
- If active run exists, show resume action and replacement confirmation on new run.
- End overlay must always show earned stars and objective target values.
- If no valid shelf transfer remains, run ends as loss state.

## 8. Reference Assets
- Reference manifest path: [documents/reference_images/REFERENCE_MANIFEST.md](documents/reference_images/REFERENCE_MANIFEST.md)
- Keep implementation inspired by style and mood; avoid cloning any third-party art assets one-to-one.
