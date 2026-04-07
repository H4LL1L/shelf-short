class BoardGenerationRequest {
  const BoardGenerationRequest({
    required this.seed,
    required this.tileCount,
    required this.variety,
  });

  final int seed;
  final int tileCount;
  final int variety;
}
