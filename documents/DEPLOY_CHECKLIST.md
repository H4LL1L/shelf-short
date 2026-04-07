# Deploy Checklist

## 1. Product Readiness
- [ ] Core loop verified: tap -> tray -> triple clear -> win/lose.
- [ ] All critical buttons tested: pause, resume, restart, undo, shuffle, booster buy.
- [ ] Daily missions and achievements persist after app restart.
- [ ] No blocked UI states after win/lose overlays.

## 2. Technical Quality Gate
- [ ] `flutter pub get`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `flutter build apk --release`
- [ ] `flutter build appbundle --release`

## 3. Android Release Config
- [ ] Set package id and signing config.
- [ ] Set versionName/versionCode.
- [ ] Verify minSdk/targetSdk compliance.
- [ ] Verify launch icon and adaptive icon.
- [ ] Verify network permissions only if needed.

## 4. Store Listing Assets
- [ ] 512x512 icon.
- [ ] Feature graphic.
- [ ] Phone screenshots (minimum 4, max 8).
- [ ] Short description and long description.
- [ ] Localized metadata (TR + EN minimum).

## 5. Compliance
- [ ] Privacy policy URL live and reachable.
- [ ] Data safety form completed.
- [ ] Ads declaration aligned with in-app behavior.
- [ ] Age rating questionnaire completed.

## 6. Live Ops Setup
- [ ] Daily mission rotation validated.
- [ ] Reward economy sanity pass completed.
- [ ] Event calendar for 4 weeks created.

## 7. Final Go/No-Go
- [ ] Crash-free smoke test on low-end Android device.
- [ ] Session recovery test after app kill.
- [ ] Store pre-launch report reviewed.
- [ ] Release candidate tag created.
