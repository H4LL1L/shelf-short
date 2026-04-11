# Execution Todo

Date: 2026-04-11

## Done In This Pass
- Added level timer pacing to gameplay.
- Exposed remaining time in the HUD.
- Preserved timer state across pause/resume and saved active runs.
- Split loss state into `noMoves` and `timeExpired`.
- Added controller tests for timer behavior and kept the suite green.
- Added a coin-based `Hint` booster with board highlight feedback.
- Added a coin-based `+Time` booster tied to the live level timer.
- Added telemetry coverage and regression tests for the new boosters.

## P0 - Core Genre Parity
- [ ] Build a first-session tutorial overlay.
  - Explain drag rules, shelf closing, timer pressure, undo, and shuffle in-context.
  - Acceptance: new player can complete level 1 without leaving the screen confused.
- [ ] Add at least two more boosters.
  - Recommended: `Hint` and `+Time`.
  - Acceptance: each booster has economy cost, telemetry event, and disabled-state messaging.
- [ ] Improve move-validity feedback.
  - Highlight valid targets during drag and explain invalid drops visually.
  - Acceptance: player can tell why a drop is blocked without trial-and-error frustration.
- [ ] Tune timer difficulty.
  - Start generous, then test failure rates by level band.
  - Acceptance: normal progression does not require boosters to clear early and mid levels.
- [ ] Add authored level patterns on top of pure procedural generation.
  - Mix curated seeds, empty-shelf counts, and variety spikes.
  - Acceptance: first 50 levels feel intentionally sequenced, not random.

## P1 - Retention And Content Depth
- [ ] Add obstacle or modifier system.
  - Recommended first set: locked shelves, frozen slots, or hidden-door shelves.
  - Acceptance: each modifier has unique UI treatment and one tutorial intro.
- [ ] Expand booster economy.
  - Add free reward path, mission rewards, and shop pricing table.
  - Acceptance: booster usage feels earned before it feels monetized.
- [ ] Create daily reward / streak reward surface.
  - Acceptance: returning next day gives a visible reason to re-enter the game.
- [ ] Upgrade the home screen into a proper progression hub.
  - Add chapterized level bands, featured missions, and event callouts.
  - Acceptance: home screen tells the player what to do next in one glance.
- [ ] Add richer run-end feedback.
  - Show failure reason, target miss delta, earned coins/xp, and retry recommendation.

## P1 - Visual Quality
- [ ] Increase product readability at small sizes.
  - Review silhouettes, label noise, and contrast.
  - Acceptance: all item types remain distinguishable on 6.1-inch screens.
- [ ] Add stronger drag motion and shelf-close payoff.
  - Acceptance: successful grouping feels tactile without slowing the loop.
- [ ] Audit invalid-state clarity.
  - Especially near full shelves and low-time moments.

## P2 - Live Ops And Production
- [ ] Define event framework.
  - Seasonal goal reskins, limited missions, boosted rewards.
  - Acceptance: one event can be configured without app-store resubmission assumptions leaking into code.
- [ ] Add remote balancing inputs.
  - Timer values, booster costs, mission rewards, and level gating should become tunable.
- [ ] Expand telemetry.
  - Track failure reason, time remaining on win, booster use by level band, and restart loops.
- [ ] Prepare ad policy before monetization.
  - Rule: no ads during active interaction, no fake “remove ads” promises, no forced friction spikes.
- [ ] Add cloud sync / account restoration if distribution scope justifies it.

## Recommended Build Order
1. Tutorial
2. Hint booster
3. Extra-time booster
4. Timer tuning pass
5. Curated level packs
6. First obstacle type
7. Progression hub upgrade
8. Event framework

## Non-Negotiable Product Rules
- Fairness beats monetization tricks.
- Readability beats visual clutter.
- New mechanics must be teachable in under 10 seconds.
- If a level feels impossible without a booster, the level is wrong.
- Benchmark the player complaints, not just the store screenshots.
