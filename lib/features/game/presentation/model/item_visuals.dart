import 'package:flutter/material.dart';

import '../../domain/entities/item_kind.dart';

enum ProductShape {
  carton,
  bottleSlim,
  bottleRound,
  can,
  tube,
  chipBag,
  coffeeCup,
  dispenser,
  box,
  jar,
  ball,
  trophy,
}

class ItemVisual {
  const ItemVisual({
    required this.label,
    required this.badgeText,
    required this.shape,
    required this.baseColor,
    required this.accentColor,
    required this.capColor,
    required this.shadowColor,
    required this.widthFactor,
    required this.heightFactor,
  });

  final String label;
  final String badgeText;
  final ProductShape shape;
  final Color baseColor;
  final Color accentColor;
  final Color capColor;
  final Color shadowColor;
  final double widthFactor;
  final double heightFactor;
}

class ItemVisuals {
  ItemVisuals._();

  static const Map<ItemKind, ItemVisual> _catalog = {
    ItemKind.milk: ItemVisual(
      label: 'Fresh Milk',
      badgeText: 'MILK',
      shape: ProductShape.carton,
      baseColor: Color(0xFFF5F2EC),
      accentColor: Color(0xFFD8B145),
      capColor: Color(0xFF9A7730),
      shadowColor: Color(0x664F3417),
      widthFactor: 0.42,
      heightFactor: 1.0,
    ),
    ItemKind.bread: ItemVisual(
      label: 'Chocolate Bar',
      badgeText: 'CHOCO',
      shape: ProductShape.chipBag,
      baseColor: Color(0xFFEFD278),
      accentColor: Color(0xFF7D4A2B),
      capColor: Color(0xFFD2A341),
      shadowColor: Color(0x664F3417),
      widthFactor: 0.48,
      heightFactor: 0.94,
    ),
    ItemKind.fish: ItemVisual(
      label: 'Berry Soda',
      badgeText: 'SODA',
      shape: ProductShape.can,
      baseColor: Color(0xFFC16DF5),
      accentColor: Color(0xFFF0D6FF),
      capColor: Color(0xFF8252B5),
      shadowColor: Color(0x664F3417),
      widthFactor: 0.36,
      heightFactor: 0.82,
    ),
    ItemKind.carrot: ItemVisual(
      label: 'Orange Juice',
      badgeText: 'RIO',
      shape: ProductShape.bottleSlim,
      baseColor: Color(0xFFF6B24D),
      accentColor: Color(0xFFFFE39F),
      capColor: Color(0xFFE48C1A),
      shadowColor: Color(0x664F3417),
      widthFactor: 0.34,
      heightFactor: 0.98,
    ),
    ItemKind.pepper: ItemVisual(
      label: 'Lotion Bottle',
      badgeText: 'BEST',
      shape: ProductShape.bottleRound,
      baseColor: Color(0xFFF5C75E),
      accentColor: Color(0xFFFFF0B2),
      capColor: Color(0xFFD89429),
      shadowColor: Color(0x664F3417),
      widthFactor: 0.40,
      heightFactor: 0.92,
    ),
    ItemKind.cheese: ItemVisual(
      label: 'Kitchen Box',
      badgeText: 'SK',
      shape: ProductShape.box,
      baseColor: Color(0xFFF1C84E),
      accentColor: Color(0xFFF7E69A),
      capColor: Color(0xFFD09B22),
      shadowColor: Color(0x664F3417),
      widthFactor: 0.45,
      heightFactor: 0.88,
    ),
    ItemKind.coffee: ItemVisual(
      label: 'Coffee Cup',
      badgeText: 'COFF',
      shape: ProductShape.coffeeCup,
      baseColor: Color(0xFFD0A456),
      accentColor: Color(0xFF82592D),
      capColor: Color(0xFFF5E4C2),
      shadowColor: Color(0x664F3417),
      widthFactor: 0.44,
      heightFactor: 0.88,
    ),
    ItemKind.apple: ItemVisual(
      label: 'Soap Pump',
      badgeText: 'SOAP',
      shape: ProductShape.dispenser,
      baseColor: Color(0xFFF5B548),
      accentColor: Color(0xFFFFF1B3),
      capColor: Color(0xFFD28E1B),
      shadowColor: Color(0x664F3417),
      widthFactor: 0.40,
      heightFactor: 0.98,
    ),
    ItemKind.banana: ItemVisual(
      label: 'Pear Fruit',
      badgeText: '',
      shape: ProductShape.jar,
      baseColor: Color(0xFFC9A44C),
      accentColor: Color(0xFF96B94A),
      capColor: Color(0xFF8A6B20),
      shadowColor: Color(0x664F3417),
      widthFactor: 0.44,
      heightFactor: 0.92,
    ),
    ItemKind.donut: ItemVisual(
      label: 'Sport Ball',
      badgeText: '',
      shape: ProductShape.ball,
      baseColor: Color(0xFFF0D17F),
      accentColor: Color(0xFFFDF6D5),
      capColor: Color(0xFFD2A541),
      shadowColor: Color(0x664F3417),
      widthFactor: 0.36,
      heightFactor: 0.58,
    ),
    ItemKind.burger: ItemVisual(
      label: 'Golden Trophy',
      badgeText: '',
      shape: ProductShape.trophy,
      baseColor: Color(0xFFF3D36C),
      accentColor: Color(0xFFFFF3BC),
      capColor: Color(0xFFD2A538),
      shadowColor: Color(0x664F3417),
      widthFactor: 0.48,
      heightFactor: 0.86,
    ),
    ItemKind.cake: ItemVisual(
      label: 'Beauty Tube',
      badgeText: 'MSSY',
      shape: ProductShape.tube,
      baseColor: Color(0xFFF0C763),
      accentColor: Color(0xFFFFE7A7),
      capColor: Color(0xFFD39C28),
      shadowColor: Color(0x664F3417),
      widthFactor: 0.36,
      heightFactor: 0.96,
    ),
  };

  static ItemVisual of(ItemKind kind) => _catalog[kind]!;
}
