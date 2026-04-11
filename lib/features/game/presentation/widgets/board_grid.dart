import 'package:flutter/material.dart';

import '../../domain/entities/item_kind.dart';
import '../../domain/entities/shelf_hint_move.dart';
import '../model/item_visuals.dart';
import 'shelf_product.dart';

typedef ShelfMoveCallback =
    void Function(int fromShelf, int fromSlot, int toShelf);

class BoardGrid extends StatelessWidget {
  const BoardGrid({
    super.key,
    required this.shelves,
    required this.closedShelves,
    required this.shelfCapacity,
    required this.isInputEnabled,
    this.hintMove,
    required this.onMoveItem,
  });

  final List<List<ItemKind>> shelves;
  final List<bool> closedShelves;
  final int shelfCapacity;
  final bool isInputEnabled;
  final ShelfHintMove? hintMove;
  final ShelfMoveCallback onMoveItem;

  @override
  Widget build(BuildContext context) {
    if (shelves.isEmpty) {
      return const Center(child: Text('Loading shelves...'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 7
            : constraints.maxWidth >= 560
            ? 6
            : 6;
        final aspectRatio = constraints.maxWidth >= 560 ? 1.08 : 1.16;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(3, 3, 3, 6),
          physics: const BouncingScrollPhysics(),
          itemCount: shelves.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemBuilder: (context, shelfIndex) {
            final items = shelves[shelfIndex];
            final isClosed =
                closedShelves.length > shelfIndex && closedShelves[shelfIndex];

            return _ShelfCell(
              key: ValueKey<String>(
                'shelf-$shelfIndex-${isClosed ? 'closed' : 'open'}-${items.map((e) => e.name).join('_')}',
              ),
              shelfIndex: shelfIndex,
              items: items,
              isClosed: isClosed,
              shelfCapacity: shelfCapacity,
              isInputEnabled: isInputEnabled,
              isHintSource: hintMove?.fromShelf == shelfIndex,
              isHintTarget: hintMove?.toShelf == shelfIndex,
              onMoveItem: onMoveItem,
            );
          },
        );
      },
    );
  }
}

class _ShelfCell extends StatelessWidget {
  const _ShelfCell({
    super.key,
    required this.shelfIndex,
    required this.items,
    required this.isClosed,
    required this.shelfCapacity,
    required this.isInputEnabled,
    required this.isHintSource,
    required this.isHintTarget,
    required this.onMoveItem,
  });

  final int shelfIndex;
  final List<ItemKind> items;
  final bool isClosed;
  final int shelfCapacity;
  final bool isInputEnabled;
  final bool isHintSource;
  final bool isHintTarget;
  final ShelfMoveCallback onMoveItem;

  @override
  Widget build(BuildContext context) {
    return DragTarget<_DraggedItem>(
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        if (!isInputEnabled || isClosed) return false;
        if (data.fromShelf == shelfIndex) return false;
        if (items.length >= shelfCapacity) return false;
        return items.isEmpty || items.last == data.kind;
      },
      onAcceptWithDetails: (details) {
        onMoveItem(details.data.fromShelf, details.data.fromSlot, shelfIndex);
      },
      builder: (context, candidateData, _) {
        final isCandidate = candidateData.isNotEmpty;
        final hintBorderColor = isHintTarget
            ? const Color(0xFFB8FF7B)
            : isHintSource
            ? const Color(0xFF8DE0FF)
            : const Color(0xFF895423);
        final hintShadowColor = isHintTarget
            ? const Color(0x663A9B22)
            : isHintSource
            ? const Color(0x6645A7C9)
            : const Color(0x22000000);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFD39E68), Color(0xFFB2703C)],
            ),
            border: Border.all(
              color: isCandidate
                  ? const Color(0xFFFFE7A6)
                  : hintBorderColor,
              width: isCandidate || isHintSource || isHintTarget ? 1.3 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: hintShadowColor,
                blurRadius: isHintSource || isHintTarget ? 8 : 0,
                spreadRadius: isHintSource || isHintTarget ? 0.3 : 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(2, 2, 2, 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF2D2A0),
                        const Color(0xFFE2B177),
                        const Color(0xFFCD8C4F).withValues(alpha: 0.98),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 2,
                right: 2,
                bottom: 2,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFB16E39), Color(0xFF834A1C)],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(1, 1, 1, 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List<Widget>.generate(shelfCapacity, (slotIndex) {
                    final item = slotIndex < items.length
                        ? items[slotIndex]
                        : null;
                    final isDraggable =
                        item != null && isInputEnabled && !isClosed;

                    final slotKey = ValueKey<String>(
                      'slot-$shelfIndex-$slotIndex-${item?.name ?? 'empty'}-${items.length}',
                    );

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.2),
                        child: isDraggable
                            ? LongPressDraggable<_DraggedItem>(
                                key: slotKey,
                                delay: const Duration(milliseconds: 70),
                                hapticFeedbackOnStart: false,
                                data: _DraggedItem(
                                  fromShelf: shelfIndex,
                                  fromSlot: slotIndex,
                                  kind: item,
                                ),
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: ShelfProduct(
                                    kind: item,
                                    maxHeight: 74,
                                    isLifted: true,
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.35,
                                  child: _ShelfSlotBody(
                                    kind: item,
                                    isDraggable: false,
                                  ),
                                ),
                                child: _ShelfSlotBody(
                                  kind: item,
                                  isDraggable: true,
                                ),
                              )
                            : _ShelfSlotBody(
                                key: slotKey,
                                kind: item,
                                isDraggable: false,
                              ),
                      ),
                    );
                  }),
                ),
              ),
              if (isClosed)
                const Positioned.fill(child: _ClosedCupboardOverlay()),
              if (!isClosed && (isHintSource || isHintTarget))
                Positioned(
                  top: 4,
                  right: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isHintTarget
                          ? const Color(0xFF3E8F2A)
                          : const Color(0xFF2A79A7),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      child: Text(
                        isHintTarget ? 'DROP' : 'MOVE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ShelfSlotBody extends StatelessWidget {
  const _ShelfSlotBody({
    super.key,
    required this.kind,
    required this.isDraggable,
  });

  final ItemKind? kind;
  final bool isDraggable;

  @override
  Widget build(BuildContext context) {
    if (kind == null) {
      return const SizedBox.expand();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final visual = ItemVisuals.of(kind!);
        final fittedHeight = (constraints.maxHeight - 1).clamp(18.0, 72.0);
        final fittedWidth = (constraints.maxWidth - 0.5).clamp(6.0, 24.0);

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            ShelfProduct(
              kind: kind!,
              maxHeight: fittedHeight,
              maxWidth: fittedWidth,
              isLifted: isDraggable,
            ),
            if (isDraggable)
              const Positioned(
                top: -1,
                right: -1,
                child: Icon(
                  Icons.unfold_more_rounded,
                  size: 7,
                  color: Color(0xFFFFE07B),
                ),
              ),
            if (visual.badgeText.isNotEmpty && constraints.maxHeight > 26)
              Positioned(
                left: 0,
                right: 0,
                bottom: 2,
                child: Text(
                  visual.badgeText,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 4.4,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF7D541D),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ClosedCupboardOverlay extends StatelessWidget {
  const _ClosedCupboardOverlay();

  @override
  Widget build(BuildContext context) {
    const doorColor = Color(0xFF8A5428);
    const innerDoorColor = Color(0xFFA26732);

    return Container(
      margin: const EdgeInsets.fromLTRB(2, 2, 2, 3),
      child: Row(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  bottomLeft: Radius.circular(2),
                ),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [doorColor, innerDoorColor],
                ),
                border: Border.all(color: const Color(0xFF6D3E18), width: 0.5),
              ),
              child: const _DoorLabel(label: 'SOLD'),
            ),
          ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(2),
                  bottomRight: Radius.circular(2),
                ),
                gradient: const LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [doorColor, innerDoorColor],
                ),
                border: Border.all(color: const Color(0xFF6D3E18), width: 0.5),
              ),
              child: const _DoorLabel(label: 'LOCK'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoorLabel extends StatelessWidget {
  const _DoorLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotatedBox(
        quarterTurns: 1,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 6,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFF6E3B8),
          ),
        ),
      ),
    );
  }
}

class _DraggedItem {
  const _DraggedItem({
    required this.fromShelf,
    required this.fromSlot,
    required this.kind,
  });

  final int fromShelf;
  final int fromSlot;
  final ItemKind kind;
}
