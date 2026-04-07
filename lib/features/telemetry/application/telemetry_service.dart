import '../domain/entities/telemetry_event.dart';

abstract class TelemetryService {
  Future<void> initialize();

  Future<void> track(
    TelemetryEventType type, {
    Map<String, Object?> properties,
  });
}

class NoopTelemetryService implements TelemetryService {
  const NoopTelemetryService();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> track(
    TelemetryEventType type, {
    Map<String, Object?> properties = const <String, Object?>{},
  }) async {}
}
