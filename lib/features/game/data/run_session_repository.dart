import '../domain/entities/game_session.dart';

abstract class RunSessionRepository {
  Future<GameSession?> load();

  Future<void> save(GameSession session);

  Future<void> clear();
}

class NoopRunSessionRepository implements RunSessionRepository {
  const NoopRunSessionRepository();

  @override
  Future<void> clear() async {}

  @override
  Future<GameSession?> load() async => null;

  @override
  Future<void> save(GameSession session) async {}
}
