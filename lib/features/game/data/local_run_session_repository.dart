import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/game_session.dart';
import 'run_session_repository.dart';

class LocalRunSessionRepository implements RunSessionRepository {
  static const String _activeRunKey = 'game_active_run_json';

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeRunKey);
  }

  @override
  Future<GameSession?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_activeRunKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return GameSession.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(GameSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeRunKey, jsonEncode(session.toJson()));
  }
}
