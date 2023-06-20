import 'package:flutter/material.dart';

Rect? findGlobalRect(GlobalKey key) {
  Widget? w = key.currentWidget;
  RenderObject? renderObject = key.currentContext?.findRenderObject();
  if (renderObject == null) {
    return null;
  }

  try {
    if (renderObject is RenderBox) {
      var globalOffset = renderObject.localToGlobal(Offset.zero);

      var bounds = renderObject.paintBounds;
      bounds = bounds.translate(globalOffset.dx, globalOffset.dy);
      return bounds;
    } else {
      var bounds = renderObject!.paintBounds;
      final translation = renderObject.getTransformTo(null).getTranslation();
      bounds = bounds.translate(translation.x, translation.y);
      return bounds;
    }
  } catch (e) {
    print("findGlobalRect: ${e.toString()}");
    return null;
  }
}
