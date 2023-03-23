import 'package:flutter/material.dart';

/// just try to get global pos, ignore size, because after a window resize, an assertion fails:
/// Assertion failed: file:///Users/Shared/installers/flutter/packages/flutter/lib/src/rendering/box.dart:2017:13
// debugDoingThisResize || debugDoingThisLayout || _computingThisDryLayout ||
//               (RenderObject.debugActiveLayout == parent && size._canBeUsedByParent)
// "RenderBox.size accessed beyond the scope of resize, layout, or permitted parent access. RenderBox can always access its own size, otherwise, the only object that is allowed to read RenderBox.size is its parent, if they have said they will. It you hit this assert trying to access a child's size, pass \"parentUsesSize: true\" to that child's layout()."
Offset? findGlobalPos(GlobalKey key) {
  BuildContext? cxt = key.currentContext;
  RenderObject? renderObject = cxt?.findRenderObject();
  return (renderObject as RenderBox).localToGlobal(Offset.zero);
}
