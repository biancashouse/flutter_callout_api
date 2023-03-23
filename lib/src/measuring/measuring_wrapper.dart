import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef OnWidgetSizeChange = void Function(Size size);
typedef OnWidgetPositionChange = void Function(Offset pos);

class MeasuringWrapper extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onSizeChangedF;
  final OnWidgetPositionChange onPosChangedF;
  final bool skipMeasure;

  const MeasuringWrapper({super.key, required this.onSizeChangedF, required this.onPosChangedF, super.child, this.skipMeasure = false});

  @override
  RenderObject createRenderObject(BuildContext context) => _MeasureWidgetRenderObject(onSizeChangedF, onPosChangedF);
}

class _MeasureWidgetRenderObject extends RenderProxyBox {
  Size? oldSize;
  Offset? oldPos;

  final OnWidgetSizeChange onSizeChange;
  final OnWidgetPositionChange onPosChange;

  _MeasureWidgetRenderObject(this.onSizeChange, this.onPosChange);

  @override
  void performLayout() {
    print("performLayout");
    super.performLayout();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Size newSize = child!.size;
      Offset newPos = child!.localToGlobal(Offset.zero);
      if (oldSize == newSize && oldPos == newPos) return;
      if (oldSize != newSize) {
        oldSize = newSize;
        onSizeChange(newSize);
      }
      if (oldPos != newPos) {
        oldPos = newPos;
        onPosChange(newPos);
      }
    });

    // Useful.afterNextBuildDo(() {
    //   var t = child;
    //   Size newSize = child!.size;
    //   Offset newPos = child!.localToGlobal(Offset.zero);
    //   if (oldSize == newSize && oldPos == newPos) return;
    //   if (oldSize != newSize) {
    //     oldSize = newSize;
    //     onSizeChange(newSize);
    //   }
    //   if (oldPos != newPos) {
    //     oldPos = newPos;
    //     onPosChange(newPos);
    //   }
    // });
  }
}
