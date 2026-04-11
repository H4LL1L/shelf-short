enum GameLossReason {
  noMoves,
  timeExpired,
}

extension GameLossReasonX on GameLossReason {
  static GameLossReason? parse(String? raw) {
    for (final value in GameLossReason.values) {
      if (value.name == raw) {
        return value;
      }
    }
    return null;
  }
}
