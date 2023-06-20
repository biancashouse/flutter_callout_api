import 'package:flutter/material.dart';

import 'callout.dart';
import 'side.dart';

class DraggableEdge extends StatelessWidget {
  final Side side;
  final double thickness;
  final Callout parent;
  final Color color;

  const DraggableEdge({required this.side, required this.thickness, required this.parent, required this.color, Key? key}) : super(key: key);

  Axis axis() {
    switch (side) {
      case Side.TOP:
      case Side.BOTTOM:
        return Axis.vertical;
      case Side.LEFT:
      case Side.RIGHT:
        return Axis.horizontal;
    }
  }

  IconData iconData() {
    switch (side) {
      case Side.TOP:
        return Icons.arrow_drop_down;
      case Side.BOTTOM:
        return Icons.arrow_drop_up;
      case Side.LEFT:
        return Icons.arrow_right;
      case Side.RIGHT:
        return Icons.arrow_left;
    }
  }

  @override
  Widget build(BuildContext context) {
    double top = _topLeft().dy;
    double left = _topLeft().dx;
    return Positioned(
      top: top,
      left: left,
      child: Draggable(
        axis: axis(),
        feedback: const Offstage(),
        child: Container(
          color: color,
          width: _width(),
          height: _height(),
        ),
        onDragUpdate: (DragUpdateDetails dud) {
          var deltaX = dud.delta.dx;
          var deltaY = dud.delta.dy;
          Size calloutSize = parent.calloutSize;
          if (side == Side.LEFT) {
            parent.left = parent.left! + deltaX;
            parent.calloutSize = Size(calloutSize.width - deltaX, calloutSize.height);
          } else if (side == Side.TOP) {
            if (parent.minHeight != null && calloutSize.height + deltaY <= parent.minHeight!) {
              parent.calloutSize = Size(calloutSize.width, parent.minHeight!);
              //parent.top = parent.top! + deltaY;
            } else {
              parent.top = parent.top! + deltaY;
              parent.calloutSize = Size(calloutSize.width, calloutSize.height - deltaY);
            }
          } else if (side == Side.RIGHT) {
            parent.calloutSize = Size(calloutSize.width + deltaX, calloutSize.height);
          } else if (side == Side.BOTTOM) {
            if (parent.minHeight != null && calloutSize.height + deltaY < parent.minHeight!) {
              parent.calloutSize = Size(calloutSize.width, parent.minHeight!);
            } else {
              parent.calloutSize = Size(calloutSize.width, calloutSize.height + deltaY);
            }
          }
          parent.rebuildOverlays(() {
            parent.onResize?.call(parent.calloutSize);
          });
        },
      ),
    );
  }

  Offset _topLeft() {
    Size calloutSize = parent.calloutSize;
    Rect calloutRect = Rect.fromLTWH(parent.left!, parent.top!, calloutSize.width, calloutSize.height+(parent.dragHandleHeight??0));
    if (side == Side.LEFT) {
      return (calloutRect.topLeft.translate(-thickness, 0));
    } else if (side == Side.RIGHT) {
      return (calloutRect.topRight.translate(0, 0));
    } else if (side == Side.TOP) {
      return (calloutRect.topLeft.translate(0, -thickness));
    } else {
      return (calloutRect.bottomLeft.translate(0, 0));
    }
  }

  double _width() {
    Size calloutSize = parent.calloutSize;
    if (side == Side.LEFT || side == Side.RIGHT) {
      return thickness;
    } else {
      return calloutSize.width;
    }
  }

  double _height() {
    Size calloutSize = parent.calloutSize;
    if (side == Side.TOP || side == Side.BOTTOM) {
      return thickness;
    } else {
      return calloutSize.height+(parent.dragHandleHeight??0);
    }
  }
}
