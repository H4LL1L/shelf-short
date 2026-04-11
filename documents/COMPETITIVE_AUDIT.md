# Competitive Audit

Date: 2026-04-11

## Scope
- Goal: align Shelf Rush with successful mobile goods-sorting / shelf-match titles without cloning third-party assets or monetization mistakes.
- Current build reviewed from local codebase on 2026-04-11.
- Market references checked from live store listings on 2026-04-11.

## Source References
- Google Play: Shelf Sort Puzzle Game
  - https://play.google.com/store/apps/details?id=com.goods.triple.match.puzzle
- Google Play: Goods Sort - Sorting Games
  - https://play.google.com/store/apps/details?id=closet.match.pair.matching.games
- App Store: Match Goods: Triple Sort Game
  - https://apps.apple.com/us/app/match-goods-triple-sort-game/id6462400215

## What The Market Consistently Does
- Bright, dense shelf scenes with immediate product readability.
- Short controls: single-finger drag/tap, almost no onboarding friction.
- Booster layer is not optional. Players expect shuffle, hints, extra time, slot relief, and obstacle unlocks.
- Levels are paced by either strict timers or timer-like pressure.
- Meta layer is deeper than pure level select: events, themed content, unlock cadence, and recurring rewards.
- Updates are frequent. Top Google Play examples advertise seasonal events and regular feature updates.

## What Players Repeatedly Praise
- Low ad interruption.
- Relaxed but readable gameplay.
- Fast sessions with visible progress.
- Frequent new content and themed events.

## What Players Repeatedly Hate
- Aggressive ads during active gameplay.
- Timers that feel rigged or too tight.
- Small item silhouettes and unclear open-slot logic.
- Repetitive content after hundreds of levels.
- “Forced booster” difficulty where levels stop feeling solvable without spend.

## Current Shelf Rush Position

### Strengths already in the repo
- Solid feature-first Flutter architecture.
- Good local persistence for profile and active run.
- Combo scoring, stars, missions, achievements, audio hooks, telemetry hooks.
- Shelf-transfer puzzle loop already fits the shelf-sort subcategory.
- Analyze/test baseline is healthy.

### Gaps versus top genre titles
- No pacing pressure was present before this pass; market leaders commonly use timed sessions or timer-equivalent pressure.
- No first-session tutorial or assisted onboarding.
- Booster set is too thin for genre parity.
- No obstacle system, lock system, blocked shelf variants, or content modifiers.
- Level content is procedural but not authored; this risks repetition.
- No seasonal/live-event content pipeline yet.
- UX clarity is still weaker than benchmark apps for “why can’t I place this item?” moments.
- No ad strategy / monetization policy has been designed, which is good for now, but must be intentional later to avoid the exact review failures seen in benchmark titles.

## Decision Taken In This Pass
- Added timer-based pacing to the runtime model and gameplay HUD.
- Timer survives pause/resume and active-run persistence.
- Loss state now distinguishes `timeExpired` versus `noMoves`.

## Product Direction Recommendation
- Keep Shelf Rush in the “shelf sort / goods grouping” branch of the genre.
- Do not pivot to a totally different tray-based game unless user testing proves the shelf-transfer loop underperforms.
- Differentiate on fairness and clarity:
  - generous but meaningful timers
  - readable item silhouettes
  - transparent move validity
  - restrained monetization
- Avoid copying benchmark art, copy their structural strengths instead:
  - pacing
  - booster expectations
  - level variety cadence
  - live-content rhythm

## Immediate Strategic Rules
- Never ship ads during active puzzle interaction.
- If timers exist, communicate them clearly and tune them generously.
- Do not make booster usage mandatory in normal progression.
- Every new level mechanic must preserve quick readability on a phone-sized screen.
- Event content should modify goals, skins, or reward cadence before it modifies core rules.
