import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter_callout_api/src/blink.dart';
import 'package:flutter_callout_api/src/gotits/gotits_helper.dart';
import 'package:flutter_callout_api/src/measuring/find_global_rect.dart';
import 'package:flutter_callout_api/src/measuring/measure_sizebox.dart';
import 'package:flutter_callout_api/src/overlays/callouts/callout.dart';
import 'package:flutter_callout_api/src/overlays/callouts/coord.dart';
import 'package:flutter_callout_api/src/overlays/callouts/line.dart';
import 'package:flutter_callout_api/src/overlays/callouts/offstage_measuring_widget.dart';
import 'package:flutter_callout_api/src/overlays/callouts/path_util.dart';
import 'package:flutter_callout_api/src/overlays/callouts/pointing_line.dart';
import 'package:flutter_callout_api/src/overlays/callouts/toast.dart';
import 'package:flutter_callout_api/src/useful.dart';
import 'package:flutter_callout_api/src/widget_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'draggable_corner.dart';
import 'draggable_edge.dart';
import 'package:transparent_pointer/transparent_pointer.dart';

export 'arrow_type.dart';
export "rectangle.dart";
export "side.dart";

typedef WidthFunc = double Function();
typedef HeightFunc = double Function();

typedef TargetKeyFunc = GlobalKey? Function();
typedef ContentFunc = Widget Function();
typedef SizeChangedF = void Function(Size);
typedef PosChangedF = void Function(Offset);

const Color FUCHSIA_X = Color.fromRGBO(255, 0, 255, 1);

/// callout creator
enum CAPI {
  ANY_TOAST,
  DURATION_CALLOUT,
  TARGET_RADIUS_AND_ZOOM_CALLOUT,
  ARROW_TYPE_CALLOUT,
  TEXT_STYLE_CALLOUT,
  IMAGE_CALLOUT,
  HELP_CONTENT_CALLOUT,
  CALLOUT_CONFIG_TOOLBAR_CALLOUT,
  FONT_FAMILY_CALLOUT,
  TEXT_ALIGNMENT_CALLOUT,
  COLOR_CALLOUT,
  DOTTED_BORDER_CALLOUT,
  PICK_IMAGE,
  DEBUG_CALLOUT,
  CPI;

  int feature() => index;

  // int feature([String? twName, int? i]) {
  //   int result = -index;
  //   // multiple target callouts: also need a twName and the target index with the wrapper
  //   if (this == CAPI.TARGET_LISTVIEW_CALLOUT) {
  //     assert(twName != null);
  //     result = 1000 * (result - twName.hashCode);
  //   }
  //   return result;
  // }
}

/// callout creator

int SECS(int s) => s * 1000;

class Callout {
  // ignore: constant_identifier_names
  static const double PAD = 25.0;

  final int feature;

  final FocusNode? focusNode;
  final Axis? gotitAxis;
  final Function? onGotitPressedF;

  final bool showcpi;

  final bool? onlyOnce;

  //final GlobalKey targetGK;
  final TargetKeyFunc? targetGKF;
  final double scale;
  final ScrollController? hScrollController;
  final ScrollController? vScrollController;
  final ContentFunc contents;

  //final GlobalKey? contentsGK;
  final Function? onExpiredF;

  // extend line in the to direction by delta
  final double? fromDelta;

  // extend line in the from direction by delta
  final double? toDelta;
  final ArrowType arrowType;
  Color? arrowColor;
  Alignment? initialTargetAlignment;
  Alignment? initialCalloutAlignment;
  int initialAnimatedPositionDurationMs;
  int moveAnimatedPositionDurationMs;
  Offset? initialCalloutPos;

  // Alignment? onScreenAlignment;
  final Function? onBarrierTappedF;
  final double barrierOpacity;
  final List<Color>? barrierGradientColors;
  final bool barrierHasCircularHole;
  final double barrierHolePadding;
  final bool modal;
  final bool showCloseButton;
  final Offset closeButtonPos;
  final VoidCallback? onTopRightButtonPressF;
  final Color closeButtonColor;

  // callout gets removed if on top of the overlay manager's stack when removeTop() Callout called.
  final double? separation;
  final bool forceMeasure;
  WidthFunc? widthF;
  HeightFunc? heightF;
  WidthFunc? originalWidthF;
  HeightFunc? originalHeightF;
  double? width;
  double? height;
  double? minHeight;
  Color? color;
  final double roundedCorners;
  final double lengthDeltaPc;
  final double? contentTranslateX;
  final double? contentTranslateY;
  final double? targetTranslateX;
  final double? targetTranslateY;
  final bool animate;
  final Offset? endOffset;
  final Widget? lineLabel;
  final bool frameTarget;
  final double scaleTarget;
  final completer = Completer<bool>();
  final Widget? dragHandle;
  final double? dragHandleHeight;
  final bool draggable;
  final bool canToggleDraggable;
  final PosChangedF? onDragF;
  final VoidCallback? onDragStartedF;
  final PosChangedF? onDragEndedF;
  final bool noBorder;
  final double elevation;
  final bool skipOnScreenCheck;
  final bool resizeableH;
  final bool resizeableV;
  final SizeChangedF? onResize;
  final double draggableEdgeThickness = 30.0;
  final bool alwaysReCalcSize;
  Color? draggableColor;

  final bool containsTextField;

  final bool transparentPointer;

  // OverlayEntry? barrierEntry;
  // OverlayEntry? contentsEntry;
  // OverlayEntry? pointingLineEntry;
  // OverlayEntry? bubbleBgEntry;
  // OverlayEntry? lineLabelEntry;
  // OverlayEntry? targetEntry;
  // OverlayEntry? topLeftCornerEntry;
  // OverlayEntry? topRightCornerEntry;
  // OverlayEntry? bottomLeftCornerEntry;
  // OverlayEntry? bottomRightCornerEntry;
  // OverlayEntry? topEdgeEntry;
  // OverlayEntry? rightEdgeEntry;
  // OverlayEntry? bottomEdgeEntry;
  // OverlayEntry? leftEdgeEntry;

  double? top;
  double? left;
  Coord? lineLabelPos;

  bool isHidden = false;

  // get size of callout - ignore locn - it comes from the offstage overlay - not useful
  // we'll be adding the callout to the overlay relative to the targetRect
  late Size calloutSize;
  bool needsToScrollH = false;
  bool needsToScrollV = false;

  bool didAnimateYet = false;

  Offset dragCalloutOffset = Offset.zero;

  // for hiding / unhiding
  double? savedTop;
  double? savedLeft;

  late double actualTop;
  late double actualLeft;

  late double calloutW;
  late double calloutH;

  Timer? endOfScrollTimer;

  bool ignoreCalloutResult;

  Callout({
    required this.feature,
    this.targetGKF,
    this.scale = 1.0,
    this.hScrollController,
    this.vScrollController,
    required this.contents,
    //this.contentsGK,
    this.onExpiredF,
    this.onBarrierTappedF,
    this.separation,
    this.forceMeasure = false,
    this.widthF,
    this.heightF,
    this.minHeight,
    this.color,
    this.lengthDeltaPc = 0.8,
    this.contentTranslateX,
    this.contentTranslateY,
    this.targetTranslateX,
    this.targetTranslateY,
    this.arrowType = ArrowType.THIN,
    this.arrowColor,
    this.barrierOpacity = 0.0,
    this.barrierGradientColors = const [Colors.black12, Colors.black12],
    this.barrierHasCircularHole = false,
    this.barrierHolePadding = 0.0,
    this.modal = false,
    this.showCloseButton = false,
    this.closeButtonPos = const Offset(10,10),
    this.onTopRightButtonPressF,
    this.closeButtonColor = Colors.red,
    this.initialTargetAlignment,
    this.initialCalloutAlignment,
    this.initialAnimatedPositionDurationMs = 150,
    this.moveAnimatedPositionDurationMs = 0,
    this.initialCalloutPos,
    // this.onScreenAlignment,
    this.roundedCorners = 0,
    this.animate = false,
    this.endOffset,
    this.toDelta,
    this.fromDelta,
    this.lineLabel,
    this.frameTarget = false,
    this.scaleTarget = 1.0,
    this.noBorder = false,
    this.elevation = 5,
    this.dragHandle,
    this.dragHandleHeight,
    this.draggable = true,
    this.canToggleDraggable = false,
    this.onDragF,
    this.onDragEndedF,
    this.onDragStartedF,
    this.skipOnScreenCheck = false,
    this.resizeableH = false,
    this.resizeableV = false,
    this.onResize,
    this.draggableColor,
    this.gotitAxis,
    this.onGotitPressedF,
    this.showcpi = false,
    this.onlyOnce,
    this.containsTextField = false,
    this.alwaysReCalcSize = false,
    this.focusNode,
    this.ignoreCalloutResult = false,
    this.transparentPointer = false,
  }) {
    _targetGKfunc = targetGKF;
    color ??= FUCHSIA_X.withOpacity(.9);
    arrowColor ??= color;
    assert((dragHandle != null && dragHandleHeight != null) || (dragHandle == null && dragHandleHeight == null));
  }

  //Timer? _timer;

  late bool isDraggable;

  Rectangle? tR;

  Rectangle cR() => Rectangle.fromRect(calloutRect().translate(contentTranslateX ?? 0.0, contentTranslateY ?? 0.0));

  TargetKeyFunc? _targetGKfunc;

  GlobalKey? getTargetGK() => _targetGKfunc?.call();

  Future<bool> show({
    int? removeAfterMs,
    Offset? endOffset,
    int? animatedPositionDurationMs,
    bool notUsingHydratedStorage = false,
    VoidCallback? onReadyF,
  }) async {
    // print('${targetGK.currentContext == null ? "!!!!!!!!!!!!" : targetGK.currentContext.toString()}');

    // skip if same overlay already found
    if (/*feature >= 0 &&*/ Useful.om.anyPresent([feature])) {
      return false;
    }

    // skip if already gotit
    if (/*feature >= 0 &&*/ GotitsHelper.alreadyGotit(feature, notUsingHydratedStorage: notUsingHydratedStorage)) return false;

    // set gotit automatically once used
    if (onlyOnce ?? false) GotitsHelper.gotit(feature, notUsingHydratedStorage: notUsingHydratedStorage);

    // print('${targetGK.currentContext == null ? "!!!!!!!!!!!!" : targetGK.currentContext.toString()}');

    await init();

    if (tR == null && initialCalloutPos == null) {
      print('skipping callout(${feature}) - perhaps target not present for some reason.');
      return false;
      // // if missing target and initialOffset, just centre on screen
      // initialCalloutAlignment = null;
      // initialTargetAlignment = null;
      // initialCalloutPos = Offset(Useful.screenW(context), Useful.screenH((context)));
    }

    // print('${targetGK.currentContext == null ? "!!!!!!!!!!!!" : targetGK.currentContext.toString()}');

    insertOverlayEntries();

    //await Future.delayed(Duration(milliseconds: animatedPositionDurationMs));

    // then animate to actual pos
    rebuildOverlays(() {
      top = actualTop;
      left = actualLeft;
      if (!skipOnScreenCheck && (top ?? 999) < Useful.viewPadding.top) {
        top = Useful.viewPadding.top;
      }
    });

    await Future.delayed(const Duration(milliseconds: 50));

    // callout now in position corr to initialAlignments. Definitely on screen.
    // Now attempt to animate s.t. distance += separation in existing direction
    rebuildOverlays(() {
      if ((separation ?? 0.0) != 0.0 && tR != null && cE != null) {
        // move cE
        Coord cEbefore = cE!;
        var cEafter = Coord.changeDistanceBetweenPoints(Coord.fromOffset(tR!.center), cEbefore, separation ?? 0.0)!;
        // translate callout by separation along line
        var deltaX = cEafter.x - cEbefore.x;
        var deltaY = cEafter.y - cEbefore.y;
        // function determines whether topLeft and bottom Rect are onScreen
        bool calloutWouldNotBeOffscreen(Coord cE) {
          Rect finalCR = Rect.fromLTWH(left! + deltaX, top! + deltaY, calloutW, calloutH);
          Rect scrRect = Rect.fromLTWH(0, 0, Useful.scrW, Useful.scrH);
          return scrRect.contains(finalCR.topLeft) && scrRect.contains(finalCR.bottomRight);
        }

        if (calloutWouldNotBeOffscreen(cEafter)) {
          if (wouldBeOnscreenX(left! + deltaX)) left = left! + deltaX;
          if (wouldBeOnscreenY(top! + deltaY)) top = top! + deltaY;
        } else {
          print("oops!");
        }
      }
    });
    await Future.delayed(const Duration(milliseconds: 200));

    // finished animating: can now drag id draggable true
    rebuildOverlays(() {
      didAnimateYet = true;

      // GlobalKey<CalloutTargetState> targetGK = calloutTarget.key;
      // var targetMounted = targetGK.currentContext;
      // if (targetMounted != null)
      //   targetRectangle = targetRectangleFromGK(gk);
    });

    if (removeAfterMs != null) {
      Future.delayed(Duration(milliseconds: removeAfterMs), () => Useful.om.remove(feature, true));
    }

    // ensure callout free of soft keyboard - NOTE Scaffold.resizeToAvoidBottomInset must be false
    Useful.afterMsDelayDo(1000, () {
      if ((Useful.isIOS || Useful.isAndroid) && (top! + calloutSize.height) > (Useful.scrH - Useful.kbdH)) {
        top = Useful.scrH - Useful.kbdH - calloutSize.height - draggableEdgeThickness * 2;
        didAnimateYet = false;
        animateTo(Offset(left!, top!), 300);
        Useful.afterMsDelayDo(350, () {
          rebuildOverlays(() {
            didAnimateYet = true;
          });
        });
      }
      if (isOffscreen()) {
        rebuildOverlays(() {});
      }
    });

    onReadyF?.call();

    return completer.future;
  }

  bool wouldBeOnscreenX(double left) {
    return left + calloutW < Useful.scrW;
  }

  bool wouldBeOnscreenY(double top) {
    bool onscreen = top + calloutH < Useful.scrH - Useful.kbdH;
    return onscreen;
  }

  void changeTarget(TargetKeyFunc newTarget) {
    Useful.om.overlaySetState(f: () {
      _targetGKfunc = newTarget;
      tR = targetRectangle();
    });
  }

  Alignment rotateAlignmentBy45(Alignment a, bool clockwise) {
    late double newX;
    late double newY;
    int direction = clockwise ? -1 : 1;
    if (a.x == 0.0 && a.y == 0.0) return a;
    if (a.y == 0.0) {
      newY = a.x * direction;
    } else {
      newX = (a.y * direction);
      if (newX == (a.y * 2 * direction)) {
        newX = a.y * direction;
        newY = 0;
      }
    }
    return Alignment(newX, newY);
  }

  void animateTo(Offset dest, int millis) {
    // print('animate to');
    rebuildOverlays(() {
      didAnimateYet = false;
      moveAnimatedPositionDurationMs = millis;
      top = dest.dy;
      left = dest.dx;
    });
  }

  // if target is CalloutTarget, it automatically measures itself after a build,
  // otherwise, just measure the widget having this key
  Rectangle? targetRectangle() {
    // can supply target globalkey directly or via a function
    GlobalKey? gk = getTargetGK();
    if (gk == null && initialCalloutPos != null) {
      return Rectangle.fromPoints(initialCalloutPos!, Offset(calloutSize.width, calloutSize.height));
    }
    if (gk?.currentWidget == null) {
      if (false) developer.log('targetRectangle() - callout feature: $feature, targetGK is ${gk.toString()}', name: "callouts");
      if (false) developer.log('gk not found in the widget tree - assuming no target ?', name: "callouts");
      return null;
    } else {
      Rect? r = findGlobalRect(gk!);
      if (r == null) return null;
      // adjust for possible scroll
      double hOffset = 0;//hScrollController?.offset ?? 0.0;
      double vOffset = 0;//vScrollController?.offset ?? 0.0;
      return Rectangle.fromRect(Rect.fromLTWH(r.left + hOffset, r.top + vOffset, r.width * scaleTarget, r.height * scaleTarget));
    }
  }

  Coord? tE, cE;

  late Color calloutColor;

  void calcContentTopLeft() {
    double startingCalloutLeft;
    double startingCalloutTop;
    if (initialCalloutPos == null) {
      if (tR == null) {
        // print('targetRectangle() returned NULL !');
        return;
      }

      // these positions are relative to the target and callout local origins (just taking account of sizes)
      final targetAlignmentIntersectionPos = initialTargetAlignment!.withinRect(Rect.fromLTWH(0, 0, tR!.width, tR!.height));
      final calloutAlignmentIntersectionPos = initialCalloutAlignment!.withinRect(Rect.fromLTWH(0, 0, calloutSize.width, calloutSize.height));

      final startingCalloutTopLeftRelativeToTarget = targetAlignmentIntersectionPos - calloutAlignmentIntersectionPos;

      startingCalloutLeft = tR!.left + startingCalloutTopLeftRelativeToTarget.dx;
      if (!skipOnScreenCheck && startingCalloutLeft < 0) startingCalloutLeft = 0.0;
      startingCalloutTop = tR!.top + startingCalloutTopLeftRelativeToTarget.dy;
      if (!skipOnScreenCheck && startingCalloutTop < 0) startingCalloutTop = 0.0;
    } else {
      startingCalloutTop = initialCalloutPos!.dy;
      startingCalloutLeft = initialCalloutPos!.dx;
    }

    actualTop = startingCalloutTop;
    actualLeft = startingCalloutLeft;

    // ensure callout will be on onscreen
    // only needs  to be scrollable when can't fit on screen
    // print('============   screenH = ${Useful.screenH()}');
    needsToScrollH = calloutSize.width > Useful.scrW;
    needsToScrollV = calloutSize.height > (Useful.scrH - Useful.kbdH);
    if (!skipOnScreenCheck && !needsToScrollV && !needsToScrollH) {
      // adjust s.t entirely visible
      if (startingCalloutLeft < 0) actualLeft = 0;
      if (startingCalloutTop < 0) actualTop = 0;
      if (startingCalloutLeft + calloutSize.width > Useful.scrW) {
        actualLeft = Useful.scrW - calloutSize.width;
      }
      if (startingCalloutTop + calloutSize.height > (Useful.scrH - Useful.kbdH)) {
        actualTop = (Useful.scrH - Useful.kbdH) - calloutSize.height - 20;
      }
    } else if (needsToScrollV) {
      actualTop = 0.0;
    } else if (needsToScrollH) {
      actualLeft = 0.0;
    }

    dragCalloutOffset = Offset.zero;

    top = actualTop;
    left = actualLeft;
    // print('top: $top');
    // print('left: $left');
  }

  bool isOffscreen() {
    // print('left: $actualLeft\ncalloutSize!.width: ${calloutSize.width}\nUseful.screenW(): ${Useful.screenW()}');
    // print(
    //     'top: $actualTop\ncalloutSize!.height: ${calloutSize.height}\nUseful.screenH(): ${Useful.screenH()}\nUseful.kbdH(): ${Useful.kbdH()}');
    return !skipOnScreenCheck &&
        ((actualLeft + calloutSize.width) > Useful.scrW || (actualTop + calloutSize.height) > (Useful.scrH - Useful.kbdH));
  }

  Future<void> init() async {
    didAnimateYet = false;
    originalWidthF = widthF;
    originalHeightF = heightF;

    if (originalWidthF != null) {
      width = originalWidthF!.call();
    }
    if (originalHeightF != null) {
      height = originalHeightF!.call();
    }

    if (initialCalloutPos != null) {
      initialCalloutAlignment = initialTargetAlignment = null;
    }

    await possibleMeasure();

    isDraggable = draggable;

    calloutColor = color ?? Colors.white;
    draggableColor ??= Colors.blue.withOpacity(.1); //JIC ??

    calloutW = width!;
    calloutH = height!;
    // // if (width > Useful.screenW()) calloutW = Useful.screenW() - 30;
    // //if (height > Useful.screenH()) calloutH = Useful.screenH() - 30;
    //
    // // get size of callout - ignore locn - it comes from the offstage overlay - not useful
    // // we'll be adding the callout to the overlay relative to the targetRect
    calloutSize = Size(calloutW, calloutH);
    //print('callout widget size: ${calloutSize}');

    // separation should take into account the callout size

    tR = targetRectangle();

    /// given a Rect, returns most appropriate alignment between target and callout

    if ((initialCalloutAlignment == null || initialTargetAlignment == null)) {
      double sw = Useful.scrW;
      double sh = Useful.scrH;

      Offset targetC;
      if (tR == null) {
        // not specified target gk, so use screen centre
        targetC = Offset(
          (sw - width!) / 2,
          (sh - Useful.kbdH - height!) / 2,
        );
      } else {
        targetC = tR!.center;
      }

      Rect screenRect = Rect.fromLTWH(0, 0, Useful.scrW, Useful.scrH);
      initialTargetAlignment = -Useful.calcTargetAlignment(screenRect, tR!);
      initialCalloutAlignment = -initialTargetAlignment!;

      print("initialCalloutAlignment: ${initialCalloutAlignment.toString()}");
      print("initialTargetAlignment: ${initialTargetAlignment.toString()}");
    }

    calcContentTopLeft();
  }

  // // NOTE - wrapperRect is the screen (or scaffold) rect usually
  // Alignment calcTargetAlignment(final Rect wrapperRect, final Rect targetRect) {
  //   Rect screenRect = Rect.fromLTWH(0, 0, Useful.scrW, Useful.scrH);
  //   Offset screenC = screenRect.center;
  //   Offset targetRectC = targetRect.center;
  //   double x = (targetRectC.dx - screenC.dx) / (screenRect.width / 2);
  //   double y = (targetRectC.dy - screenC.dy) / (screenRect.height / 2);
  //   // keep away from sides
  //   if (x < -0.75)
  //     x = -1.0;
  //   else if (x > 0.75) x = 1.0;
  //   if (y < -0.75)
  //     y = -1.0;
  //   else if (y > 0.75) y = 1.0;
  //   print("$x, $y");
  //   return Alignment(x, y);
  // }

  Future<void> possibleMeasure() async {
    if ((width == null && height == null)) {
      Size calloutSize = await measureWidgetSize(context: Useful.cachedContext, widget: contents.call(), force: alwaysReCalcSize);
      // Size calloutSize = await measureWidgetSize2(widget: contents.call(), force: alwaysReCalcSize);
      width = calloutSize.width;
      height = calloutSize.height;
    } else if (height == null) {
      Size calloutSize =
      await measureWidgetSize(context: Useful.cachedContext, widget: SizedBox(width: width, child: contents.call()), force: alwaysReCalcSize);
      height = forceMeasure ? max(calloutSize.height, 40) : 40;
    } else if ((width == null)) {
      Size calloutSize =
      await measureWidgetSize(context: Useful.cachedContext, widget: SizedBox(height: height, child: contents.call()), force: alwaysReCalcSize);
      width = calloutSize.width;
    }
    // print(Size(width!, height!).toString());
  }

  void scrolledRefresh() {
    rebuildOverlays(() {});
  }

  void insertOverlayEntries() {
    bool notToast = this is! ToastCallout;

    if (notToast && barrierOpacity > 0.0) {
      Useful.om.insertCalloutOverlayEntry(this, _createBarrier());
    }
    // may be a dynamic callout of an Apple-like fixed one
    if (notToast && arrowType == ArrowType.POINTY) {
      Useful.om.insertCalloutOverlayEntry(this, _createBubbleBg());
    }
    Useful.om.insertCalloutOverlayEntry(this, _createContentsEntry());

    if (notToast && arrowType != ArrowType.NO_CONNECTOR && arrowType != ArrowType.POINTY && tR != null) {
      Useful.om.insertCalloutOverlayEntry(this, _createPointingLineEntry());
      if (lineLabel != null) Useful.om.insertCalloutOverlayEntry(this, _createLineLabelEntry());
    }
    if (notToast && frameTarget && tR != null) {
      Useful.om.insertCalloutOverlayEntry(this, _createTargetEntry());
    }
    if (resizeableH && resizeableV) {
      Future.delayed(const Duration(milliseconds: 100), () {
        Useful.om.insertCalloutOverlayEntry(this, _createDraggableCornerEntry(Alignment.topLeft));
        Useful.om.insertCalloutOverlayEntry(this, _createDraggableCornerEntry(Alignment.topRight));
        Useful.om.insertCalloutOverlayEntry(this, _createDraggableCornerEntry(Alignment.bottomLeft));
        Useful.om.insertCalloutOverlayEntry(this, _createDraggableCornerEntry(Alignment.bottomRight));
        Useful.om.insertCalloutOverlayEntry(this, _createDraggableEdgeEntry(Side.LEFT));
        Useful.om.insertCalloutOverlayEntry(this, _createDraggableEdgeEntry(Side.TOP));
        Useful.om.insertCalloutOverlayEntry(this, _createDraggableEdgeEntry(Side.RIGHT));
        Useful.om.insertCalloutOverlayEntry(this, _createDraggableEdgeEntry(Side.BOTTOM));
      });
    } else {
      if (resizeableH) {
        Future.delayed(const Duration(milliseconds: 100), () {
          Useful.om.insertCalloutOverlayEntry(this, _createDraggableEdgeEntry(Side.LEFT));
          Useful.om.insertCalloutOverlayEntry(this, _createDraggableEdgeEntry(Side.RIGHT));
        });
      }
      if (resizeableV) {
        Future.delayed(const Duration(milliseconds: 100), () {
          Useful.om.insertCalloutOverlayEntry(this, _createDraggableEdgeEntry(Side.TOP));
          Useful.om.insertCalloutOverlayEntry(this, _createDraggableEdgeEntry(Side.BOTTOM));
        });
      }
    }
  }

  OverlayEntry _createBubbleBg() =>
      OverlayEntry(
          builder: (BuildContext ctx) {
            bool targetNotOffscreen = (targetGKF != null &&
                (tR?.intersects(Rectangle.fromRect(Rect.fromLTWH(0, 0, Useful.scrW, Useful.scrH))) ?? false));
            return true //initialCalloutPos != null || targetNotOffscreen
                ? Positioned(
              top: 0,
              left: 0,
              child: CustomPaint(
                painter: BubbleShape(callout: this, fillColor: color),
                willChange: false,
              ),
            )
                : const Offstage();
          },
          opaque: false);

  OverlayEntry _createContentsEntry() =>
      OverlayEntry(
          builder: (BuildContext ctx) {
            // bool targetNotOffscreen = (targetGKF != null && (tR?.intersects(Rectangle.fromRect(Rect.fromLTWH(0, 0, Useful.scrW, Useful.scrH))) ?? false));
            // if (initialCalloutPos == null /*&& !targetNotOffscreen*/) return Offstage();

            if (!didAnimateYet) {
              return AnimatedPositioned(
                duration: Duration(milliseconds: initialAnimatedPositionDurationMs),
                curve: Curves.decelerate,
                top: (top ?? 0) + (contentTranslateY ?? 0.0),
                left: (left ?? 0) + (contentTranslateX ?? 0.0),
                child: CalloutParent(
                  // may have been called from another callout, so for that case keep a ref to it is kept in its parent container
                  callout: this,
                ),
              );
            } else {
              // tR = targetRectangle();
              if (initialCalloutPos == null && initialCalloutAlignment == null && initialTargetAlignment == null) {
                Rect screenRect = Rect.fromLTWH(0, 0, Useful.scrW, Useful.scrH);
                initialTargetAlignment = -Useful.calcTargetAlignment(screenRect, tR!);
                initialCalloutAlignment = -initialTargetAlignment!;
              }
              return AnimatedPositioned(
                  duration: Duration(milliseconds: moveAnimatedPositionDurationMs),
                  curve: Curves.decelerate,
                  top: (top ?? 0) + (contentTranslateY ?? 0.0),
                  left: (left ?? 0) + (contentTranslateX ?? 0.0),
                  // if draghandle supplied, make it the draggable and pos it above the callout itself
                  child: dragHandle != null
                      ? SizedBox(
                    width: calloutSize.width,
                    height: calloutSize.height + (dragHandleHeight ?? 0.0),
                    child: Stack(
                      children: [
                        Positioned(
                          top: dragHandleHeight,
                          child: CalloutParent(
                            // may have been called from another callout, so for that case keep a ref to it is kept in its parent container
                            callout: this,
                          ),
                        ),
                        Listener(
                          onPointerDown: _onContentPointerDown,
                          onPointerMove: _onContentPointerMove,
                          onPointerUp: _onContentPointerUp,
                          child: SizedBox(
                            height: dragHandleHeight,
                            width: calloutW,
                            child: dragHandle != null ? dragHandle : null,
                          ),
                        ),
                        if (dragHandle != null && showCloseButton)
                          Positioned(
                            top: closeButtonPos.dy,
                            right: closeButtonPos.dx,
                            child: Material(
                              color: Colors.transparent,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 24,
                                icon: Icon(
                                  Icons.close,
                                  color: closeButtonColor,
                                ),
                                onPressed: () async {
                                  onTopRightButtonPressF?.call();
                                  Useful.om.remove(feature, false);
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                      : _contentListenerNoDragHandle()
              );
            }
          },
          opaque: false);

  Listener _contentListenerNoDragHandle() =>
      Listener(
        onPointerDown: _onContentPointerDown,
        onPointerMove: _onContentPointerMove,
        onPointerUp: _onContentPointerUp,
        child: CalloutParent(
          // may have been called from another callout, so for that case keep a ref to it is kept in its parent container
          callout: this,
        ),
      );

  void _onContentPointerDown(PointerDownEvent event) {
    if (!isDraggable) return;
    dragCalloutOffset = event.localPosition;
    onDragStartedF?.call();
  }

  void _onContentPointerMove(PointerMoveEvent event) {
    if (!isDraggable) return;
    rebuildOverlays(() {
      top = event.position.dy - dragCalloutOffset.dy;
      left = event.position.dx - dragCalloutOffset.dx;
      bool OnDragOnlyOnPointerUp = false;
      if (!OnDragOnlyOnPointerUp) onDragF?.call(Offset(left!, top!));
    });
  }

  void _onContentPointerUp(PointerUpEvent event) {
    if (!isDraggable) return;
    rebuildOverlays(() {
      // calloutRect = calloutRect.translate(event.delta.dx, event.delta.dy);
      top = event.position.dy - dragCalloutOffset.dy;
      left = event.position.dx - dragCalloutOffset.dx;
      onDragF?.call(Offset(left!, top!));
      onDragEndedF?.call(Offset(left!, top!));
    });
  }

  OverlayEntry _createPointingLineEntry() =>
      OverlayEntry(
          builder: (BuildContext ctx) {
            // if (tE == null && cE == null) {
            //   print('feature ${feature}');
            //   return Offstage();
            // }

            tR = targetRectangle();
            if (initialCalloutAlignment == null && initialTargetAlignment == null) {
              Rect screenRect = Rect.fromLTWH(0, 0, Useful.scrW, Useful.scrH);
              initialTargetAlignment = -Useful.calcTargetAlignment(screenRect, tR!);
              initialCalloutAlignment = -initialTargetAlignment!;
            }

            calcEndpoints();
            Rect r = Rect.fromPoints(tE!.asOffset, cE!.asOffset);
            Offset to = tE!.asOffset
                .translate(
              -r.left,
              -r.top,
            // )
            //     .translate(
            //   -(hScrollController?.offset ?? 0.0),
            //   -(vScrollController?.offset ?? 0.0),
            );
            Offset from = cE!.asOffset.translate(-r.left, -r.top);
            Line line = Line(Coord.fromOffset(from), Coord.fromOffset(to));
            double lineLen = line.length();
            //Rect inflatedTargetRect = targetRect.inflate(separation / 2);
            Rect calloutrect = calloutRect();
            //bool overlaps = calloutrect.overlaps(inflatedTargetRect);
            // don't show line if gap between endpoints < specifid separation
            double sep = math.max(separation ?? 0.0, 50);
            bool veryClose = separation == null && lineLen <= sep;
            if (veryClose || tR == null || calloutrect.overlaps(tR!)) {
              return const Offstage();
            }

            // // only show the line if callout does not overlap (padded) target
            // if (//targetRect.contains(cE.asOffset) ||
            //     (calloutRect().overlaps(targetRect.inflate(50))))
            //   return IgnoreP_contentointer(child: Offstage());

            Widget pointingLine = IgnorePointer(
              child: PointingLine(
                arrowType.reverse ? to : from,
                arrowType.reverse ? from : to,
                arrowType,
                arrowColor!,
                lengthDeltaPc: lengthDeltaPc,
                animate: animate,
              ),
            );

            // computer pos for line label
            //if (lineLabel != null) lineLabelPos = Line(tE,cE).midPoint();

            return didAnimateYet
                ? AnimatedPositioned(
              duration: Duration(milliseconds: moveAnimatedPositionDurationMs),
              curve: Curves.decelerate,
              top: r.top,
              left: r.left,
              child: pointingLine,
            )
                : AnimatedPositioned(
              duration: Duration(milliseconds: initialAnimatedPositionDurationMs),
              curve: Curves.decelerate,
              top: r.top,
              left: r.left,
              child: pointingLine,
            );
          },
          opaque: false);

  OverlayEntry _createLineLabelEntry() =>
      OverlayEntry(
          builder: (BuildContext ctx) {
            //Rect r = Rect.fromPoints(tE.asOffset, cE.asOffset);
            return Positioned(
              top: (tE!.y + cE!.y) / 2,
              left: (tE!.x + cE!.x) / 2,
              child: Material(
                child: lineLabel,
              ),
            );
          },
          opaque: false);

  OverlayEntry _createTargetEntry() =>
      OverlayEntry(
          builder: (BuildContext ctx) {
            return Positioned(
              top: tR!.top,
              left: tR!.left,
              child: Material(
                color: Colors.yellow.withOpacity(.3),
                child: Container(
                  color: Colors.transparent,
                  width: tR!.width * scaleTarget,
                  height: tR!.height * scaleTarget,
                ),
              ),
            );
          },
          opaque: false);

  OverlayEntry _createDraggableCornerEntry(Alignment corner) =>
      OverlayEntry(
          builder: (BuildContext ctx) {
            return DraggableCorner(alignment: corner, thickness: draggableEdgeThickness, color: draggableColor!, parent: this);
          },
          opaque: false);

  OverlayEntry _createDraggableEdgeEntry(Side side) =>
      OverlayEntry(
          builder: (BuildContext ctx) {
            return DraggableEdge(side: side, thickness: draggableEdgeThickness, color: draggableColor!, parent: this);
          },
          opaque: false);

  OverlayEntry _createBarrier() =>
      OverlayEntry(
          builder: (BuildContext ctx) {
            tR = targetRectangle();
            // print('_createBarrier() build');
            return Positioned.fill(
                child: IgnorePointer(
                  ignoring: !(modal || onBarrierTappedF != null),
                  child: Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerUp: (_) {
                        onBarrierTappedF?.call();
                      },
                      // barrier now never tappable, because no way to pass taps through to lower widget, such as a button outside of the callout
                      // onPointerDown: (_) {
                      //   barrierTapped = true;
                      //   completed(false);
                      //   onBarrierTappedF?.call();
                      // },
                      child: !kIsWeb && tR != null
                          ? ColorFiltered(
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(barrierOpacity), BlendMode.srcOut),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: tR!.top - barrierHolePadding,// - (vScrollController?.offset ?? 0.0),
                                left: tR!.left - barrierHolePadding,// - (hScrollController?.offset ?? 0.0),
                                child: Container(
                                  height: tR!.height + barrierHolePadding * 2,
                                  width: tR!.width + barrierHolePadding * 2,
                                  decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.red,
                                        blurRadius: 5.0,
                                        spreadRadius: 2.0,
                                      ),
                                    ],
                                    color: Colors.black,
                                    // Color does not matter but should not be transparent
                                    borderRadius:
                                    barrierHasCircularHole ? BorderRadius.circular(tR!.height / 2 + barrierHolePadding) : BorderRadius.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          : barrierGradientColors!.isNotEmpty
                          ? Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            end: Alignment.topCenter,
                            begin: Alignment.bottomCenter,
                            colors: barrierGradientColors!,
                          ),
                        ),
                      )
                          : Container(
                        color: Colors.black.withOpacity(barrierOpacity),
                      )
                    //     : ClipPath(
                    //   clipper: DarkScreenWithHolePainter1(tR, barrierOpacity, padding: barrierHolePadding, round: barrierHasCircularHole),
                    //   child: Container(
                    //     color: Colors.black.withOpacity(barrierOpacity),
                    //   ),
                    // )
                    // CustomPaint(
                    //     size: Size(screenW, screenH),
                    //     painter: DarkScreenWithHolePainter2(tR, barrierOpacity, padding: barrierHolePadding, round: barrierHasCircularHole)
                    // )
                    // TweenAnimationBuilder<Color>(
                    //   duration: kThemeAnimationDuration,
                    //   tween: ColorTween(
                    //     begin: Colors.transparent,
                    //     end: barrierOpacity != null ? Colors.black.withOpacity(barrierOpacity) : Colors.transparent,
                    //   ),
                    //   builder: (context, color, child) {
                    //     return ColoredBox(color: color);
                    //   },
                    // ),
                  ),
                ));
          },
          opaque: false);

// OverlayEntry _createBarrierOLD() =>
//     OverlayEntry(builder: (BuildContext ctx) {
//       return Positioned.fill(
//         child: GestureDetector(
//           behavior: HitTestBehavior.opaque,
//           onTap: () {
//             barrierTapped = true;
//             completed(false);
//             onBarrierTappedF?.call();
//           },
//           child: TweenAnimationBuilder<Color>(
//             duration: kThemeAnimationDuration,
//             tween: ColorTween(
//               begin: Colors.transparent,
//               end: barrierOpacity != null ? Colors.black.withOpacity(barrierOpacity) : Colors.transparent,
//             ),
//             builder: (context, color, child) {
//               return ColoredBox(color: color);
//             },
//           ),
//         ),
//       );
//     });

// Rectangle targetRectangleFromGK(GlobalKey targetGK) {
//   // get size and global pos of target
//   Rect targetRect = CalloutHelper.findGlobalRect(targetGK);
//   if (targetRect == null) {
//     print('*****  showCallout targetGK not found !  ******');
//     return null;
//   }
//   return Rectangle.fromRect(targetRect);
// }

  Rect calloutRect() => Rect.fromLTWH(left!, top!, calloutSize.width, calloutSize.height);

  Offset calloutCentre() => calloutRect().center;

// return target rectangle if target found, otherwise null
  Line? calcEndpoints() {
    if (tR == null) return null;

    // account for possible offset X or Y as well
    Offset tCentre = tR!.center;
    Offset cCentre = cR().center;
    Line line = Line.fromOffsets(cCentre, tCentre);
    tE = Rectangle.getTargetIntersectionPoint2(Coord.fromOffset(cCentre), line, tR!);
    cE = Rectangle.getTargetIntersectionPoint2(Coord.fromOffset(tCentre), line, cR());
    if (toDelta != null && toDelta != 0.0) tE = Coord.changeDistanceBetweenPoints(cE, tE, toDelta);
    if (fromDelta != null && fromDelta != 0.0) cE = Coord.changeDistanceBetweenPoints(tE, cE, fromDelta);
    return line;
  }

  void hide() {
    if (!isHidden)
      Useful.om.overlaySetState(f: () {
        savedTop = top;
        savedLeft = left;
        top = 9999;
        left = 9999;
        isHidden = true;
      });
  }

  void unhide() {
    if (isHidden)
      Useful.om.overlaySetState(f: () {
        top = savedTop;
        left = savedLeft;
        isHidden = false;
      });
  }

// used by onTap callbacks and barrier itself
// will be passed to the barrier overlay and also to the callout (to be accessible via ...findAncestorType...)
  void completed(bool result) {
    if (!completer.isCompleted) {
      onExpiredF?.call();
      // triggers caller with true = did something, or false = aborted
      completer.complete(result);
    } else {
      print("Completer was already completed!");
    }
  }

  static void moveToByFeature(int feature, Offset newGlobalPos) {
    Callout? callout = Useful.om.findCallout(feature);
    if (callout != null) {
      callout.rebuildOverlays(() {
        callout.top = newGlobalPos.dy;
        callout.left = newGlobalPos.dx;
        callout.tR = callout.targetRectangle();
        callout.didAnimateYet = true;
      });
    }
  }

  // refreshes the pointy
  static void updateTargetPosByFeature(int feature, Offset newTargetPos) {
    Callout? callout = Useful.om.findCallout(feature);
    if (callout != null) {
      callout.rebuildOverlays(() {
        if (callout.targetRectangle() != null) {
          callout.tR = callout.targetRectangle();
          double deltaV = newTargetPos.dy - callout.tR!.top;
          double deltaH = newTargetPos.dx - callout.tR!.left;
          callout.tR = Rectangle.fromRect(callout.tR!.translate(deltaH, deltaV));
          callout.didAnimateYet = true;
        }
      });
    }
  }

  void rebuildOverlays(VoidCallback f) {
    Useful.om.overlaySetState(f: f);
  }

  void refresh({bool resetSize = false}) {
    Useful.om.overlaySetState(f: () {
      if (resetSize) {
        widthF = originalWidthF;
        heightF = originalHeightF;
      }
      tR = targetRectangle();
      possibleMeasure().then((_) {
        didAnimateYet = false;
        initialAnimatedPositionDurationMs = 500;
        calcContentTopLeft();
        Useful.afterMsDelayDo(550, () {
          didAnimateYet = true;
        });
      });
    });
  }

  static final Map<int, Size> _calloutSizeCache = {};

// measures by creating a hidden callout OffStage, hence requires the context
  Future<Size> measureWidgetSize({
    required BuildContext context,
    Widget? widget,
    //BoxConstraints? boxConstraints,
    required bool force,
  }) async {
    if (!context.mounted) {
      print("oh shit, context has been unmounted!");
    }
    // print('--- MEASURING --');
    // if found width, assume height also present
    if (!force && _calloutSizeCache.containsKey(feature)) {
      return _calloutSizeCache[feature]!;
    } else {
      Completer<Size> completer = Completer();
      OverlayEntry? entry;
      entry = OverlayEntry(builder: (BuildContext ctx) {
        return Material(
          child: OffstageMeasuringWidget(
            //boxConstraints: boxConstraints,
            onSized: (size) {
              // _calloutSizeCache[feature] = size;
              if (false) {
                developer.log('''
- - - - - - - - - - MEASURED Feature $feature -> Size(${size.width},${size.height}) - - - - - - - - - - 
      ''', name: "callouts");
              }
              entry?.remove();
              completer.complete(size);
            },
            child: widget,
          ),
        );
      });

      Overlay.of(context).insert(entry);
      return completer.future;
    }
  }

// measures by creating a widget inside an Offstage MeasureSizeBox
  Future<Size> measureWidgetSize2({
    Widget? widget,
    required bool force,
  }) async {
    // print('--- MEASURING --');
    // if found width, assume height also present
    if (!force && _calloutSizeCache.containsKey(feature)) {
      return _calloutSizeCache[feature]!;
    } else {
      Completer<Size> completer = Completer();
      OverlayEntry? entry;
      entry = OverlayEntry(builder: (BuildContext ctx) {
        return Material(
          child: Offstage(
            offstage: true,
            child: MeasureSizeBox(
              //TODO is key required ?
              onSizedCallback: (Size size) {
                _calloutSizeCache[feature] = size;
                entry?.remove();
                completer.complete(size);
              },
              child: widget,
            ),
          ),
        );
      });
      Timer.run(() {
        Useful.om.overlayState.insert(entry!);
      });
      return completer.future;
    }
  }

  static Future<void> showCallouts({required List<Callout> list, int? removeAfterMs, bool notUsingHydratedStorage = false}) async {
    if (list.isNotEmpty) {
      for (var callout in list) {
        if (callout.targetGKF?.call() == null && callout.initialTargetAlignment != null && callout.initialCalloutAlignment != null) return;
        print('showCallout');
        callout.show(removeAfterMs: removeAfterMs, notUsingHydratedStorage: notUsingHydratedStorage);
      }
    }
  }
}

class CalloutParent extends StatefulWidget {
  final Callout callout;

  const CalloutParent({
    Key? key,
    required this.callout,
  }) : super(key: key);

  @override
// ignore: library_private_types_in_public_api
  _CalloutParentState createState() => _CalloutParentState();
}

class _CalloutParentState extends State<CalloutParent> {
  bool hiding = false;

  @override
  Widget build(BuildContext context) {
// return Material(
//   type: MaterialType.transparency,
//   child: Center(child: Container(width: 300,height: 400,color: Colors.black12))
// );
// print("widget.callout.gotitAxis = ${widget.callout.gotitAxis.toString()}");
    return hiding
        ? const Offstage()
        : TransparentPointer(
      transparent: widget.callout.transparentPointer, // TRUE means treat as invisible, and pass events down below
      child: Material(
        type: MaterialType.transparency, //widget.callout.roundedCorners > 0 ? MaterialType.card : MaterialType.canvas,
//color: Colors.white.withOpacity(.5),
        borderRadius: BorderRadius.all(Radius.circular(widget.callout.roundedCorners)),
//elevation: widget.callout.elevation,
// shapes explained at https://medium.com/codechai/anatomy-of-material-buttons-in-flutter-first-part-40eb790979a6
// shape: widget.callout.noBorder
//     ? null
//     : OutlineInputBorder(
//         borderSide: BorderSide(
//           color: Colors.black,
//           width: 3.0,
//           style: BorderStyle.solid,
//         ),
//         borderRadius: BorderRadius.all(Radius.circular(widget.callout.roundedCorners)),
//       ),
// shape: CircleBorder(
//   side: BorderSide(
//     color: Colors.black,
//     width:3.0,
//     style: BorderStyle.solid,
//   )
// ),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            boldText: false,
            textScaleFactor: 1.0,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: widget.callout.calloutSize.width,
// - (widget.callout.gotitAxis == Axis.horizontal ? 50 : 0),
            height: widget.callout.calloutSize.height,
// - (widget.callout.gotitAxis == Axis.vertical ? 50 : 0),
            decoration: BoxDecoration(
              color: widget.callout.color,
              borderRadius: BorderRadius.all(Radius.circular(widget.callout.roundedCorners)),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 7, spreadRadius: 9),
              ],
            ),
            child: Stack(
              children: <Widget>[
                Flex(
                  direction: widget.callout.gotitAxis ?? Axis.horizontal,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: widget.callout.draggable
                          ? MouseRegion(
                        cursor: SystemMouseCursors.grab,
                        child: _possiblyScrollableContents(),
                      )
                          : _possiblyScrollableContents(),
                    ),
                    if (widget.callout.gotitAxis != null && !widget.callout.showcpi)
                      Blink(
                        child: IconButton(
                          tooltip: "got it - don't show again.",
                          iconSize: 36,
                          icon: const Icon(
                            Icons.thumb_up,
                            color: Colors.orangeAccent,
                          ),
                          onPressed: () async {
                            GotitsHelper.gotit(widget.callout.feature);
                            Useful.om.remove(widget.callout.feature, true);
                            widget.callout.onGotitPressedF?.call();
                          },
                        ),
                        animateColor: false,
                      ),
                    if (widget.callout.showcpi)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          backgroundColor: widget.callout.color,
                        ),
                      ),
                  ],
                ),
                if (widget.callout.dragHandle == null && widget.callout.showCloseButton)
                  Positioned(
                    top: widget.callout.closeButtonPos.dy,
                    right: widget.callout.closeButtonPos.dx,
                    child: IconButton(
                      iconSize: 24,
                      icon: Icon(
                        Icons.close,
                        color: widget.callout.closeButtonColor,
                      ),
                      onPressed: () async {
                        widget.callout.onTopRightButtonPressF?.call();
                        Useful.om.remove(widget.callout.feature, false);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _possiblyScrollableContents() =>
// (widget.callout.needsToScrollV || widget.callout.needsToScrollH)
// ? SizedBox.fromSize(
//     size: widget.callout.calloutSize,
//     child: SingleChildScrollView(
//       scrollDirection: Axis.vertical,
//       child: widget.callout.contents,
//     ),
//   )
// :
  SizedBox(
    width: widget.callout.calloutSize.width,
    height: widget.callout.calloutSize.height,
    child: widget.callout.contents.call(),
  );
}

// class DarkScreenWithHolePainter2 extends CustomPainter {
//   final Rectangle targetRect;
//   final double opacity;
//   final bool round;
//   final double padding;
//
//   DarkScreenWithHolePainter2(this.targetRect, this.opacity, {this.round = false, this.padding: 0.0});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = Colors.black.withOpacity(opacity);
//
//     if (round) {
//       var centre = targetRect.center;
//       var radius = max(targetRect.width, targetRect.height) / 2 + padding;
//       canvas.drawPath(
//           Path.combine(
//             PathOperation.difference,
//             Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
//             Path()
//               ..addOval(Rect.fromCircle(center: centre, radius: radius))
//               ..close(),
//           ),
//           paint);
//     } else
//       canvas.drawPath(
//           Path.combine(
//             PathOperation.difference,
//             Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
//             Path()
//               ..addRect(
//                   Rect.fromLTWH(targetRect.left - padding, targetRect.top - padding, targetRect.width + padding * 2, targetRect.height + padding * 2))
//               ..close(),
//           ),
//           paint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }

// class DarkScreenWithHolePainter1 extends CustomClipper<Path> {
//   final Rectangle targetRect;
//   final double opacity;
//   final bool round;
//   final double padding;
//
//   DarkScreenWithHolePainter1(this.targetRect, this.opacity, {this.round = false, this.padding: 0.0});
//
//   @override
//   Path getClip(Size size) {
//     if (round) {
//       var centre = targetRect.center;
//       var radius = max(targetRect.width, targetRect.height) / 2 + padding;
//
//       return Path()
//         ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
//         ..addOval(Rect.fromCircle(center: centre, radius: radius))
//         ..fillType = PathFillType.evenOdd;
//     } else
//       return Path()
//         ..addRect(Rect.fromLTWH(targetRect.left - padding, targetRect.top - padding, targetRect.width + padding * 2, targetRect.height + padding * 2))
//         ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
//     // ..fillType = PathFillType.evenOdd;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => true;
// }

class BubbleShape extends CustomPainter {
  final Callout callout;
  final Color? lineColor;
  final Color? fillColor;
  final double thickness;

  BubbleShape({required this.callout, this.lineColor = Colors.black, this.fillColor = Colors.yellowAccent, this.thickness = 1.5});

  @override
  void paint(Canvas canvas, Size size) {
    // print('BubbleShape:paint()');
    Path? path = PathUtil.draw(callout, pointyThickness: callout.height! <= 40 ? 5 : null);
    if (path != null) {
      canvas.drawPath(path, bgPaint(callout.calloutColor));
      canvas.drawPath(path, linePaint(Colors.black, theThickness: thickness));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
