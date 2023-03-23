import 'package:flutter/material.dart';

import 'callout.dart';

class DraggableCorner extends StatelessWidget {
  final Alignment alignment;
  final double thickness;
  final Callout parent;
  final Color color;

  const DraggableCorner({required this.alignment, required this.thickness, required this.parent, required this.color, Key? key}) : super(key:key);

  BorderRadius getBorderRadius(Alignment alignment) {
    if (alignment == Alignment.topLeft) {
      return BorderRadius.only(
        topLeft: Radius.circular(thickness / 2),
      );
    } else     if (alignment == Alignment.topRight) {
      return BorderRadius.only(
        topRight: Radius.circular(thickness / 2),
      );
    } else     if (alignment == Alignment.bottomLeft) {
      return BorderRadius.only(
        bottomLeft: Radius.circular(thickness / 2),
      );
    } else     if (alignment == Alignment.bottomRight) {
      return BorderRadius.only(
        bottomRight: Radius.circular(thickness / 2),
      );
    }

    return const BorderRadius.only(
      topLeft: Radius.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    // double top = _pos().dy;
    // double left = _pos().dx;
    return Positioned(
      top: _pos().dy,
      left: _pos().dx,
      child: Draggable(
        feedback: const Offstage(),
        child: Container(
          //color: color,
          width: thickness,
          height: thickness,
          decoration: BoxDecoration(
            color: color,
            borderRadius: getBorderRadius(alignment),
          ),
        ),
        onDragUpdate: (DragUpdateDetails dud) {
          var deltaX = dud.delta.dx;
          var deltaY = dud.delta.dy;
          Size calloutSize = parent.calloutSize;
          if (alignment == Alignment.topLeft) {
            if (parent.minHeight != null && calloutSize.height + deltaY < parent.minHeight!) {
              parent.calloutSize = Size(calloutSize.width, parent.minHeight!);
            }
            parent.left = parent.left! + deltaX;
            parent.calloutSize = Size(parent.calloutSize.width - deltaX, parent.calloutSize.height);
            parent.top = parent.top! + deltaY;
            parent.calloutSize = Size(parent.calloutSize.width, parent.calloutSize.height - deltaY);
          } else if (alignment == Alignment.topRight) {
            if (parent.minHeight != null && calloutSize.height + deltaY < parent.minHeight!) {
              parent.calloutSize = Size(calloutSize.width, parent.minHeight!);
              return;
            }
            parent.top = parent.top! + deltaY;
            parent.calloutSize = Size(parent.calloutSize.width, parent.calloutSize.height - deltaY);
            parent.calloutSize = Size(parent.calloutSize.width + deltaX, parent.calloutSize.height);
          } else if (alignment == Alignment.bottomLeft) {
            if (parent.minHeight != null && calloutSize.height + deltaY < parent.minHeight!) {
              parent.calloutSize = Size(calloutSize.width, parent.minHeight!);
              return;
            }
            parent.left = parent.left! + deltaX;
            parent.calloutSize = Size(parent.calloutSize.width - deltaX, parent.calloutSize.height);
            parent.calloutSize = Size(parent.calloutSize.width, parent.calloutSize.height + deltaY);
          } else if (alignment == Alignment.bottomRight) {
            if (parent.minHeight != null && calloutSize.height + deltaY < parent.minHeight!) {
              parent.calloutSize = Size(calloutSize.width, parent.minHeight!);
              return;
            }
            parent.calloutSize = Size(parent.calloutSize.width + deltaX, parent.calloutSize.height);
            parent.calloutSize = Size(parent.calloutSize.width, parent.calloutSize.height + deltaY);
          }
          parent.refreshOverlay(() {
            parent.onResize?.call(parent.calloutSize);
          });
        },
      ),
    );
  }

  Offset _pos() {
    Rect calloutRect = Rect.fromLTWH(parent.left!, parent.top!, parent.calloutSize.width, parent.calloutSize.height);
    if (alignment == Alignment.topLeft) {
      return calloutRect.topLeft.translate(-thickness, -thickness);
    } else if (alignment == Alignment.topRight) {
      return calloutRect.topRight.translate(0, -thickness);
    } else if (alignment == Alignment.bottomLeft) {
      return calloutRect.bottomLeft.translate(-thickness, 0);
    } else if (alignment == Alignment.bottomRight) {
      return calloutRect.bottomRight.translate(0, 0);
    } else {
      throw ('Corner _pos() unexpected alignment!');
    }
  }
}
