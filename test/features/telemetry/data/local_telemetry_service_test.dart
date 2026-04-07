import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelf_short/features/telemetry/data/local_telemetry_service.dart';
import 'package:shelf_short/features/telemetry/domain/entities/telemetry_event.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stores telemetry events in local buffer', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final service = LocalTelemetryService(maxEvents: 3);

    await service.initialize();
    await service.track(
      TelemetryEventType.levelStart,
      properties: const <String, Object?>{'level': 1},
    );
    await service.track(TelemetryEventType.tileTap);
    await service.track(TelemetryEventType.shuffleUsed);
    await service.track(TelemetryEventType.levelComplete);

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('telemetry_events_v1');

    expect(raw, isNotNull);
    expect(raw!, contains('levelComplete'));
    expect(raw.contains('levelStart'), isFalse);
  });
}
