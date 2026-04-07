import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../application/telemetry_service.dart';
import '../domain/entities/telemetry_event.dart';

class LocalTelemetryService implements TelemetryService {
  LocalTelemetryService({this.maxEvents = 250});

  static const String _eventsKey = 'telemetry_events_v1';

  final int maxEvents;

  List<TelemetryEvent> _buffer = <TelemetryEvent>[];
  bool _ready = false;

  @override
  Future<void> initialize() async {
    if (_ready) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_eventsKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _buffer = list
            .map((item) => TelemetryEvent.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _buffer = <TelemetryEvent>[];
      }
    }

    _ready = true;
  }

  @override
  Future<void> track(
    TelemetryEventType type, {
    Map<String, Object?> properties = const <String, Object?>{},
  }) async {
    if (!_ready) {
      await initialize();
    }

    final event = TelemetryEvent(
      type: type,
      timestamp: DateTime.now(),
      properties: properties,
    );

    _buffer.add(event);
    if (_buffer.length > maxEvents) {
      _buffer = _buffer.sublist(_buffer.length - maxEvents);
    }

    if (kDebugMode) {
      debugPrint(
        '[telemetry] ${event.type.name} ${event.properties}',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _eventsKey,
      jsonEncode(_buffer.map((item) => item.toJson()).toList()),
    );
  }
}
