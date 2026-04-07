# Game Design Document (GDD)

## 1. Game Pillars
- Simple to learn in under 10 seconds.
- Strategic tray management over random tapping.
- Short, satisfying level sessions (45s to 180s).

## 2. Core Loop
1. Player enters level.
2. Player taps visible item tiles.
3. Picked item goes to tray.
4. Matching triple in tray clears automatically.
5. Player uses optional actions (undo/shuffle).
6. Reach win or lose state.
7. Show result panel and next action.
8. If player exits mid-run, session is paused and can be resumed from home.

## 3. Rules and Win/Lose Conditions
- Any visible product on an open shelf can be dragged.
- Shelf match: 3 or 4 of the same item in one shelf eye closes that eye.
- Win: no uncollected tiles remain.
- Lose: no legal shelf transfer remains.

## 4. Level Structure
- Level has:
  - tileCount (multiple of 3)
  - itemVariety count
  - optional seed
- Difficulty increases by:
  - more tiles
  - higher variety
  - lower triple predictability

## 5. Scoring
- Base score per cleared triple.
- Combo bonus when multiple triples clear in short sequence.
- Streak bonus for consecutive scoring moves.
- End overlay shows score, triples cleared, and best combo.

## 5.1 Level Objectives and Stars
- Each level generates 2 active objectives:
  - target score
  - target best combo
- Star rules:
  - 1 star: level win
  - 2 stars: win + score objective
  - 3 stars: win + score objective + combo objective
- Highest star result per level is persisted in player profile.

## 6. Controls and Buttons
- Board drag:
  - input: drag any visible product to another shelf
  - feedback: lifted product and highlighted target shelf
- Undo button:
  - action: revert latest valid pick
  - cooldown: none for MVP
- Shuffle button:
  - action: reshuffle remaining board tiles only
  - cost: 1 charge per level in MVP
- Booster button:
  - action: buy +1 shuffle charge
  - cost: coins from progression economy
- Claim All missions button:
  - action: collect all completed daily mission rewards in one tap
- Restart button:
  - action: restart current level with same seed
- Pause button:
  - action: open pause overlay

## 7. Screen Flow
- Splash -> Home Dashboard -> Level Start/Resume -> Gameplay -> Result -> Next/Retry.

## 8. UX Feedback
- Sound placeholders for tap/match/win/lose.
- Clear text for status and objective.
- End-state overlay blocks board input.
- Haptic feedback is configurable in settings.

## 9. Accessibility and Usability
- Minimum tap target 44x44 dp.
- Avoid low-contrast text.
- Keep primary actions reachable with thumb zone.

## 10. Meta Progression
- Persistent player profile (coins, wins, best score, streak).
- Daily missions with claimable coin rewards.
- Achievement badges with one-time unlock rewards.
