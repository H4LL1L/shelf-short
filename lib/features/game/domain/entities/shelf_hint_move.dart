class ShelfHintMove {
  const ShelfHintMove({
    required this.fromShelf,
    required this.fromSlot,
    required this.toShelf,
  });

  final int fromShelf;
  final int fromSlot;
  final int toShelf;

  @override
  bool operator ==(Object other) {
    return other is ShelfHintMove &&
        other.fromShelf == fromShelf &&
        other.fromSlot == fromSlot &&
        other.toShelf == toShelf;
  }

  @override
  int get hashCode => Object.hash(fromShelf, fromSlot, toShelf);
}
