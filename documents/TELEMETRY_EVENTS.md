# Telemetry Events

## Purpose
Track core funnel, economy, and gameplay quality metrics locally for diagnostics and future analytics adapter integration.

## Event Schema
- `type`: enum event name.
- `timestamp`: ISO-8601 event time.
- `properties`: key-value payload.

## Implemented Events
- `appOpen`
- `runRestored`
- `levelStart`
- `tileTap`
- `tripleClear`
- `comboAchieved`
- `shuffleUsed`
- `undoUsed`
- `boosterPurchase`
- `missionClaim`
- `pause`
- `resume`
- `runExit`
- `levelComplete`
- `levelFailed`

## Storage
- Backing store: SharedPreferences.
- Key: `telemetry_events_v1`.
- Ring-buffer behavior with max event cap.

## Notes
- Current implementation logs in debug mode and persists local JSON history.
- A remote telemetry adapter can replace or wrap current service later without changing game logic.
