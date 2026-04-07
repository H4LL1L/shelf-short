# Audio Mixer Design

## Goals
- Keep SFX consistent and responsive.
- Separate channel volumes for future balancing.
- Respect player sound settings globally.

## Channels
- `ui`: button and interaction cues.
- `gameplay`: match/combo/shuffle cues.
- `meta`: mission and end-state cues.

## Cues
- levelStart
- tileTap
- match
- combo
- shuffle
- undo
- pause
- resume
- win
- lose
- missionClaim
- boosterPurchase

## Runtime Behavior
- Mixer initializes once.
- `setEnabled(false)` silences all cues.
- Per-cue play request resolves channel volume and master volume.
- If asset playback fails, fallback to system click sound.

## Assets
- Path: `assets/audio/`
- Placeholder WAV files are included for all mapped cues.
- Replace placeholders with production SFX during content pass.
