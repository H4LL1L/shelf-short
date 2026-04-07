enum GameStatus {
  idle,
  playing,
  paused,
  won,
  lost,
}

extension GameStatusX on GameStatus {
  static GameStatus parse(String? raw) {
    return GameStatus.values.firstWhere(
      (status) => status.name == raw,
      orElse: () => GameStatus.idle,
    );
  }
}
