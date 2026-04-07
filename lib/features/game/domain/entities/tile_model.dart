import 'item_kind.dart';

class TileModel {
  const TileModel({
    required this.id,
    required this.kind,
    this.isCollected = false,
  });

  final String id;
  final ItemKind kind;
  final bool isCollected;

  TileModel copyWith({
    String? id,
    ItemKind? kind,
    bool? isCollected,
  }) {
    return TileModel(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      isCollected: isCollected ?? this.isCollected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind.name,
      'isCollected': isCollected,
    };
  }

  factory TileModel.fromJson(Map<String, dynamic> json) {
    return TileModel(
      id: json['id'] as String? ?? '',
      kind: _parseKind(json['kind'] as String?),
      isCollected: json['isCollected'] as bool? ?? false,
    );
  }

  static ItemKind _parseKind(String? raw) {
    return ItemKind.values.firstWhere(
      (kind) => kind.name == raw,
      orElse: () => ItemKind.milk,
    );
  }
}
