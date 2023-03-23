import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:callout_api/src/blink.dart';
import 'package:callout_api/src/gotits/gotits_helper.dart';
import 'package:callout_api/src/measuring/find_global_rect.dart';
import 'package:callout_api/src/overlays/callouts/callout.dart';
import 'package:callout_api/src/overlays/callouts/coord.dart';
import 'package:callout_api/src/overlays/callouts/line.dart';
import 'package:callout_api/src/overlays/callouts/offstage_measuring_widget.dart';
import 'package:callout_api/src/overlays/callouts/path_util.dart';
import 'package:callout_api/src/overlays/callouts/pointing_line.dart';
import 'package:callout_api/src/overlays/callouts/toast.dart';
import 'package:callout_api/src/useful.dart';
import 'package:callout_api/src/widget_helper.dart';
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

/// callout creator
enum CAPI {
  ANY_TOAST,
  TARGET_LISTVIEW_CALLOUT, //one per targetwrapper
  STYLES_CALLOUT,
  START_TIME_CALLOUT,
  TEXT_CALLOUT,
  IVRECT_CALLOUT,
  DEBUG_CALLOUT,
  CPI;

  int feature([String? twName, int? i]) {
    int result = -index;
    // multiple target callouts: also need a twName and the target index with the wrapper
    if (this == CAPI.TARGET_LISTVIEW_CALLOUT) {
      assert(twName != null);
      result = 1000 * (result - twName.hashCode);
    }
    return result;
  }
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
  final Color arrowColor;
  Alignment? initialTargetAlignment;
  Alignment? initialCalloutAlignment;
  int initialAnimatedPositionDurationMs;
  int moveAnimatedPositionDurationMs;
  Offset? initialCalloutPos;
  Alignment? onScreenAlignment;
  final Function? onBarrierTappedF;
  final double barrierOpacity;
  final List<Color>? barrierGradientColors;
  final bool barrierHasCircularHole;
  final double barrierHolePadding;
  final bool modal;
  final bool showTopRightCloseButton;

  // callout gets removed if on top of the overlay manager's stack when removeTop() Callout called.
  final double? separation;
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
    this.hScrollController,
    this.vScrollController,
    required this.contents,
    //this.contentsGK,
    this.onExpiredF,
    this.onBarrierTappedF,
    this.separation,
    this.widthF,
    this.heightF,
    this.minHeight,
    this.color,
    this.lengthDeltaPc = 0.8,
    this.contentTranslateX,
    this.contentTranslateY,
    this.targetTranslateX,
    this.targetTranslateY,
    this.arrowType = ArrowType.POINTY,
    this.arrowColor = Colors.grey,
    this.barrierOpacity = 0.0,
    this.barrierGradientColors = const [Colors.black12, Colors.black12],
    this.barrierHasCircularHole = false,
    this.barrierHolePadding = 0.0,
    this.modal = false,
    this.showTopRightCloseButton = false,
    this.initialTargetAlignment,
    this.initialCalloutAlignment,
    this.initialAnimatedPositionDurationMs = 150,
    this.moveAnimatedPositionDurationMs = 0,
    this.initialCalloutPos,
    this.onScreenAlignment,
    this.roundedCorners = 0,
    this.animate = false,
    this.endOffset,
    this.toDelta,
    this.fromDelta,
    this.lineLabel,
    this.frameTarget = false,
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
    color ??= Colors.yellow.withOpacity(.9);
    assert((dragHandle != null && dragHandleHeight != null) || (dragHandle == null && dragHandleHeight == null));
    if (widthF != null && heightF == null) {
      heightF = ()=>40;
    }
  }

  //Timer? _timer;

  late bool isDraggable;

  Rectangle? tR;

  Rectangle cR() => Rectangle.fromRect(calloutRect().translate(contentTranslateX ?? 0.0, contentTranslateY ?? 0.0));

  TargetKeyFunc? _targetGKfunc;

  GlobalKey? getTargetGK() => _targetGKfunc?.call();

  // Future<bool> show2({
  //   required int feature,
  //   bool modal = false,
  //   bool showTopRightCloseButton = false,
  //   // with gotit button - only if gotit axis supplied
  //   Axis? gotitAxis,
  //   Function? onGotitPressedF,
  //   bool? onlyOnce,
  //   // ------------------
  //   // can pass in a single target gk and corr onShowing func, or a map of target,trigger func
  //   TargetKeyFunc? targetGKF,
  //   ScrollController? vScrollController,
  //   ScrollController? hScrollController,
  //   Function? onExpiredF,
  //   required ContentFunc contents,
  //   ArrowType arrowType = ArrowType.POINTY,
  //   Color arrowColor = Colors.grey,
  //   // use either 2 alignments, or the callout pos
  //   Alignment? initialTargetAlignment,
  //   Alignment? initialCalloutAlignment,
  //   Offset? initialCalloutPos,
  //   // ---------
  //   Function? onBarrierTappedF,
  //   double barrierOpacity = 0.0,
  //   List<Color>? barrierGradientColors = const [Colors.black12, Colors.black12],
  //   double? separation,
  //   int? removeAfterMs,
  //   double lengthDeltaPc = 1.0,
  //   Offset? endOffset,
  //   bool reverseDirection = false,
  //   double? width,
  //   double? height,
  //   double? minHeight,
  //   Color? color,
  //   double roundedCorners = 0,
  //   double? contentTranslateX,
  //   double? contentTranslateY,
  //   double? targetTranslateX,
  //   double? targetTranslateY,
  //   bool animate = false,
  //   bool barrierHasCircularHole = false,
  //   double barrierHolePadding = 0.0,
  //   Widget? lineLabel,
  //   int initialAnimatedPositionDurationMs = 150,
  //   int moveAnimatedPositionDurationMs = 0,
  //   Widget? dragHandle,
  //   bool draggable = true,
  //   bool canToggleDraggable = false,
  //   double elevation = 5,
  //   bool noBorder = false,
  //   bool skipOnScreenCheck = false,
  //   bool resizeableH = false,
  //   bool resizeableV = false,
  //   bool containsTextField = false,
  //   PosChangedF? onDrag,
  //   SizeChangedF? onResize,
  //   bool notUsingHydratedStorage = false,
  //   bool ignoreCalloutResult = false,
  //   VoidCallback? onReadyF,
  // }) async {
  //   assert(targetGKF != null || (width != null && height != null));
  //
  //   Callout callout = Callout(
  //     feature: feature,
  //     targetGKF: targetGKF,
  //     hScrollController: vScrollController,
  //     vScrollController: vScrollController,
  //     onExpiredF: onExpiredF,
  //     contents: contents,
  //     initialCalloutAlignment: initialCalloutAlignment,
  //     initialTargetAlignment: initialTargetAlignment,
  //     initialCalloutPos: initialCalloutPos,
  //     modal: modal,
  //     showTopRightCloseButton: showTopRightCloseButton,
  //     onBarrierTappedF: onBarrierTappedF,
  //     barrierOpacity: barrierOpacity,
  //     barrierGradientColors: barrierGradientColors,
  //     barrierHasCircularHole: barrierHasCircularHole,
  //     barrierHolePadding: barrierHolePadding,
  //     separation: separation,
  //     arrowColor: arrowColor,
  //     arrowType: arrowType,
  //     width: width,
  //     height: height,
  //     minHeight: minHeight,
  //     color: color,
  //     roundedCorners: roundedCorners,
  //     lengthDeltaPc: lengthDeltaPc,
  //     contentTranslateX: contentTranslateX,
  //     contentTranslateY: contentTranslateY,
  //     targetTranslateX: targetTranslateX,
  //     targetTranslateY: targetTranslateY,
  //     animate: animate,
  //     lineLabel: lineLabel,
  //     initialAnimatedPositionDurationMs: initialAnimatedPositionDurationMs,
  //     moveAnimatedPositionDurationMs: moveAnimatedPositionDurationMs,
  //     dragHandle: dragHandle,
  //     draggable: draggable,
  //     canToggleDraggable: canToggleDraggable,
  //     noBorder: noBorder,
  //     elevation: elevation,
  //     skipOnScreenCheck: skipOnScreenCheck,
  //     resizeableH: resizeableH,
  //     resizeableV: resizeableV,
  //     gotitAxis: gotitAxis,
  //     onlyOnce: onlyOnce,
  //     containsTextField: containsTextField,
  //     onDrag: onDrag,
  //     onResize: onResize,
  //     ignoreCalloutResult: ignoreCalloutResult,
  //   );
  //
  //   // // register callout with the target for measurement updates
  //   // calloutTarget.addCallout(callout);
  //
  //   // if keyboard would be popped up, refresh after a while
  //   if (containsTextField && !kIsWeb && callout.top != null) {
  //     Future.delayed(const Duration(milliseconds: 200), () {
  //       callout.refresh(() {
  //         if (!callout.wouldBeOnscreenY(callout.top!)) {
  //           callout.top = callout.top! - 400;
  //         }
  //       });
  //       // print("animate)");
  //       // callout.animateTo(Offset(callout.left!, callout.top! - 300.0), 200);
  //     });
  //   }
  //
  //   bool result = await show(
  //     removeAfterMs: removeAfterMs,
  //     endOffset: endOffset,
  //     notUsingHydratedStorage: notUsingHydratedStorage,
  //     onReadyF: onReadyF,
  //   );
  //
  //   return result;
  // }

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
    refreshOverlay(() {
      top = actualTop;
      left = actualLeft;
      if (!skipOnScreenCheck && (top ?? 999) < Useful.viewPadding.top) {
        top = Useful.viewPadding.top;
      }
    });

    await Future.delayed(const Duration(milliseconds: 50));

    // then replace AnimatedPosition with the draggable
    refreshOverlay(() {
      if ((separation ?? 0.0) != 0.0 && tR != null && cE != null) {
        // move cE
        var cEbefore = cE!;
        // var tE = calcTe();
        var cEafter = Coord.changeDistanceBetweenPoints(Coord.fromOffset(tR!.center), cEbefore, separation ?? 0.0)!;
        // translate callout by corr amount along line
        var deltaX = cEafter.x - cEbefore.x;
        var deltaY = cEafter.y - cEbefore.y;
        if (wouldBeOnscreenX(left! + deltaX)) left = left! + deltaX;
        if (wouldBeOnscreenY(top! + deltaY)) top = top! + deltaY;
      }
    });
    await Future.delayed(const Duration(milliseconds: 200));

    // show callout
    refreshOverlay(() {
      didAnimateYet = true;

      // GlobalKey<CalloutTargetState> targetGK = calloutTarget.key;
      // var targetMounted = targetGK.currentContext;
      // if (targetMounted != null)
      //   targetRectangle = targetRectangleFromGK(gk);
    });
    if (removeAfterMs != null) {
      Future.delayed(Duration(milliseconds: removeAfterMs), () {
        Useful.om.remove(feature, true);
      });

      // slide to end pos during callout's time (if not already on screen)
      // if (endOffset != null && !wouldBeOnscreen(endOffset))
      //   overlaySetState(() {
      //     didAnimateYet = false;
      //     //animatedPositionDurationMs = removeAfterMs;
      //     top = top! + endOffset.dx;
      //     left = left! + endOffset.dy;
      //   });
    }

    onReadyF?.call();

    return completer.future;
  }

  bool wouldBeOnscreenX(double left) {
    return left + calloutW < Useful.scrW;
  }

  bool wouldBeOnscreenY(double top) {
    bool onscreen = top + calloutH < Useful.scrH - (containsTextField ? 200 : 0);
    return onscreen;
  }

  void changeTarget(TargetKeyFunc newTarget) {
    Useful.om.overlaySetState(() {
      _targetGKfunc = newTarget;
      tR = targetRectangle();
    });
  }

  void animateTo(Offset dest, int millis) {
    // print('animate to');
    refreshOverlay(() {
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
      Rect r = findGlobalRect(gk!);
      // // adjust for possible scroll
      // double hOffset = 0.0;
      // double vOffset = 0.0;
      // if (hScrollController != null) {
      //   hOffset = hScrollController?.offset ?? 0.0;
      // }
      // if (vScrollController != null) {
      //   vOffset = vScrollController?.offset ?? 0.0;
      // }
      // print('scroll: $hOffset, $vOffset');
      return Rectangle.fromRect(r); //Rectangle.fromRect(Rect.fromLTWH(r!.left - hOffset, r.top - vOffset, r.width, r.height));
    }
  }

  Coord? tE, cE;

  late Color calloutColor;

  void calcContentTopLeft() {
    calloutW = width!;
    calloutH = height!;
    // // if (width > Useful.screenW()) calloutW = Useful.screenW() - 30;
    // //if (height > Useful.screenH()) calloutH = Useful.screenH() - 30;
    //
    // // get size of callout - ignore locn - it comes from the offstage overlay - not useful
    // // we'll be adding the callout to the overlay relative to the targetRect
    calloutSize = Size(calloutW, calloutH);
    //print('callout widget size: ${calloutSize}');

    tR = targetRectangle();

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
    needsToScrollV = calloutSize.height > (Useful.scrH - Useful.keyboardHeight);
    if (!skipOnScreenCheck && !needsToScrollV && !needsToScrollH) {
      // adjust s.t entirely visible
      if (startingCalloutLeft < 0) actualLeft = 0;
      if (startingCalloutTop < 0) actualTop = 0;
      if (startingCalloutLeft + calloutSize.width > Useful.scrW) {
        actualLeft = Useful.scrW - calloutSize.width;
      }
      if (startingCalloutTop + calloutSize.height > (Useful.scrH - Useful.keyboardHeight)) {
        actualTop = (Useful.scrH - Useful.keyboardHeight) - calloutSize.height - 20;
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
    //     'top: $actualTop\ncalloutSize!.height: ${calloutSize.height}\nUseful.screenH(): ${Useful.screenH()}\nUseful.keyboardHeight(): ${Useful.keyboardHeight()}');
    return !skipOnScreenCheck &&
        ((actualLeft + calloutSize.width) > Useful.scrW || (actualTop + calloutSize.height) > (Useful.scrH - Useful.keyboardHeight));
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

    if (initialCalloutPos == null && initialTargetAlignment == null && initialCalloutAlignment == null) {
      if (onScreenAlignment == Alignment.topCenter) {
        initialCalloutPos = Offset(
          (Useful.scrW - width!) / 2,
          20,
        );
      } else if (onScreenAlignment == Alignment.bottomCenter) {
        initialCalloutPos = Offset(
          (Useful.scrW - width!) / 2,
          Useful.scrH - Useful.keyboardHeight - height! - 20,
        );
      } else {
        // if alignment not specified, just centre on screen
        initialCalloutPos = Offset(
          (Useful.scrW - width!) / 2,
          (Useful.scrH - Useful.keyboardHeight - height!) / 2,
        );
      }
    }

    isDraggable = draggable;

    calloutColor = color ?? Colors.white;
    draggableColor ??= Colors.blue.withOpacity(.1); //JIC ??

    //test
    double sw = Useful.scrW;

    calcContentTopLeft();

    // if scrollcontroller supplied, listen to it for refreshing the callout on scroll
    hScrollController?.addListener(() {
      hRefresh();
    });
    vScrollController?.addListener(() {
      double scroll = vScrollController?.offset ?? 0.0;
      refresh();
      // vRefresh();
    });
  }

  Future<void> possibleMeasure() async {
    if ((width == null && height == null)) {
      Size calloutSize = await measureWidgetSize(context: Useful.cachedContext, widget: contents.call(), force: alwaysReCalcSize);
      width = calloutSize.width;
      height = calloutSize.height;
    } else if ((height == null)) {
      Size calloutSize =
          await measureWidgetSize(context: Useful.cachedContext, widget: SizedBox(width: width, child: contents.call()), force: alwaysReCalcSize);
      height = calloutSize.height;
    } else if ((width == null)) {
      Size calloutSize =
          await measureWidgetSize(context: Useful.cachedContext, widget: SizedBox(height: height, child: contents.call()), force: alwaysReCalcSize);
      width = calloutSize.width;
      height = calloutSize.height;
    }
    // print(Size(width!, height!).toString());
  }

  void vRefresh() {
    // endOfScrollTimer?.cancel();
    // endOfScrollTimer = Timer(const Duration(milliseconds: 200), () {
    if (initialCalloutPos != null) {
      refreshOverlay(() {
        top = initialCalloutPos!.dy - (vScrollController?.offset ?? 0.0);
        tR = targetRectangle();
        didAnimateYet = true;
      });
    }
    // });

    // Useful.om.refreshCallout(this);
    // endOfScrollTimer?.cancel();
    // endOfScrollTimer = Timer(const Duration(milliseconds: 200), () {
    //   Useful.om.refreshCallout(this);
    // });
  }

  void hRefresh() {
    // endOfScrollTimer?.cancel();
    // endOfScrollTimer = Timer(const Duration(milliseconds: 5), () {
    if (initialCalloutPos != null) {
      refreshOverlay(() {
        // print("hScrollController?.offset: ${hScrollController?.offset}");
        // left = initialCalloutPos!.dx - (hScrollController?.offset ?? 0.0);
        tR = targetRectangle();
        didAnimateYet = true;
      });
    }
    // });

    // Useful.om.refreshCallout(this);
    // endOfScrollTimer?.cancel();
    // endOfScrollTimer = Timer(const Duration(milliseconds: 200), () {
    //   Useful.om.refreshCallout(this);
    // });
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

  OverlayEntry _createBubbleBg() => OverlayEntry(
      builder: (BuildContext ctx) {
        bool targetNotOffscreen = (targetGKF != null && (tR?.intersects(Rectangle.fromRect(Rect.fromLTWH(0, 0, Useful.scrW, Useful.scrH))) ?? false));
        return initialCalloutPos != null || targetNotOffscreen
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

  OverlayEntry _createContentsEntry() => OverlayEntry(
      builder: (BuildContext ctx) {
        //print('${didAnimateYet ? "Positioned" : "AnimatedPositioned"}');
        // if (!didAnimateYet) {
        //   print('animating to ($left,$top over $animatedPositionDurationMs ms...');
        // } else {}
        bool targetNotOffscreen = (targetGKF != null && (tR?.intersects(Rectangle.fromRect(Rect.fromLTWH(0, 0, Useful.scrW, Useful.scrH))) ?? false));
        return initialCalloutPos != null || targetNotOffscreen
            ? !didAnimateYet
                ? AnimatedPositioned(
                    duration: Duration(milliseconds: initialAnimatedPositionDurationMs),
                    curve: Curves.decelerate,
                    top: (top ?? 0) + (contentTranslateY ?? 0.0),
                    left: (left ?? 0) + (contentTranslateX ?? 0.0),
                    child: CalloutParent(
                      // may have been called from another callout, so for that case keep a ref to it is kept in its parent container
                      callout: this,
                    ),
                  )
                : AnimatedPositioned(
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
                                  onPointerDown: (PointerDownEvent event) {
                                    if (!isDraggable) return;
                                    //print('global: ${event.position}, local ${event.localPosition}');
                                    // calc offset from callout topLeft
                                    dragCalloutOffset = event.localPosition;
                                    // refresh(() {});
                                    onDragStartedF?.call();
                                  },
                                  onPointerMove: (PointerMoveEvent event) {
                                    if (!isDraggable) return;
                                    //print(event.position);
                                    refreshOverlay(() {
                                      top = event.position.dy - dragCalloutOffset.dy;
                                      left = event.position.dx - dragCalloutOffset.dx;
                                      onDragF?.call(Offset(left!, top!));
                                    });
                                  },
                                  onPointerUp: (PointerUpEvent event) {
                                    if (!isDraggable) return;
                                    //print(event.position);
                                    refreshOverlay(() {
                                      // calloutRect = calloutRect.translate(event.delta.dx, event.delta.dy);
                                      top = event.position.dy - dragCalloutOffset.dy;
                                      left = event.position.dx - dragCalloutOffset.dx;
                                      onDragF?.call(Offset(left!, top!));
                                      onDragEndedF?.call(Offset(left!, top!));
                                    });
                                  },
                                  child: SizedBox(
                                    height: dragHandleHeight,
                                    width: calloutW,
                                    child: dragHandle != null ? dragHandle : null,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : TransparentPointer(
                            transparent: transparentPointer, // TRUE means treat as invisible, and pass events down below
                            child: Listener(
                              onPointerDown: (PointerDownEvent event) {
                                if (!isDraggable) return;
                                //print('global: ${event.position}, local ${event.localPosition}');
                                // calc offset from callout topLeft
                                dragCalloutOffset = event.localPosition;
                                // refresh(() {});
                                onDragStartedF?.call();
                              },
                              onPointerMove: (PointerMoveEvent event) {
                                if (!isDraggable) return;
                                //print(event.position);
                                refreshOverlay(() {
                                  top = event.position.dy - dragCalloutOffset.dy;
                                  left = event.position.dx - dragCalloutOffset.dx;
                                  bool OnDragOnlyOnPointerUp = false;
                                  if (!OnDragOnlyOnPointerUp) onDragF?.call(Offset(left!, top!));
                                });
                              },
                              onPointerUp: (PointerUpEvent event) {
                                if (!isDraggable) return;
                                //print(event.position);
                                refreshOverlay(() {
                                  // calloutRect = calloutRect.translate(event.delta.dx, event.delta.dy);
                                  top = event.position.dy - dragCalloutOffset.dy;
                                  left = event.position.dx - dragCalloutOffset.dx;
                                  onDragF?.call(Offset(left!, top!));
                                  onDragEndedF?.call(Offset(left!, top!));
                                });
                              },
                              child: CalloutParent(
                                // may have been called from another callout, so for that case keep a ref to it is kept in its parent container
                                callout: this,
                              ),
                            ),
                          ),
                  )
            : const Offstage();
      },
      opaque: false);

  OverlayEntry _createPointingLineEntry() => OverlayEntry(
      builder: (BuildContext ctx) {
        // if (tE == null && cE == null) {
        //   print('feature ${feature}');
        //   return Offstage();
        // }
        calcEndpoints();
        Rect r = Rect.fromPoints(tE!.asOffset, cE!.asOffset);
        Offset to = tE!.asOffset.translate(-r.left, -r.top);
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
            arrowColor,
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

  OverlayEntry _createLineLabelEntry() => OverlayEntry(
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

  OverlayEntry _createTargetEntry() => OverlayEntry(
      builder: (BuildContext ctx) {
        return Positioned(
          top: tR!.top,
          left: tR!.left,
          child: Material(
            color: Colors.yellow.withOpacity(.3),
            child: Container(
              color: Colors.transparent,
              width: tR!.width,
              height: tR!.height,
            ),
          ),
        );
      },
      opaque: false);

  OverlayEntry _createDraggableCornerEntry(Alignment corner) => OverlayEntry(
      builder: (BuildContext ctx) {
        return DraggableCorner(alignment: corner, thickness: draggableEdgeThickness, color: draggableColor!, parent: this);
      },
      opaque: false);

  OverlayEntry _createDraggableEdgeEntry(Side side) => OverlayEntry(
      builder: (BuildContext ctx) {
        return DraggableEdge(side: side, thickness: draggableEdgeThickness, color: draggableColor!, parent: this);
      },
      opaque: false);

  OverlayEntry _createBarrier() => OverlayEntry(
      builder: (BuildContext ctx) {
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
                              top: tR!.top - barrierHolePadding,
                              left: tR!.left - barrierHolePadding,
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

    // account for possible offest X or Y as well
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
      Useful.om.overlaySetState(() {
        savedTop = top;
        savedLeft = left;
        top = 9999;
        left = 9999;
        isHidden = true;
      });
  }

  void unhide() {
    if (isHidden)
      Useful.om.overlaySetState(() {
        top = savedTop;
        left = savedLeft;
        isHidden = false;
      });
  }

  // void removeRelatedOverlayEntries() {
  //   // print("removeRelatedOverlayEntries");
  //   try {
  //     focusNode?.unfocus();
  //     barrierEntry?.remove();
  //     contentsEntry?.remove();
  //     pointingLineEntry?.remove();
  //     bubbleBgEntry?.remove();
  //     lineLabelEntry?.remove();
  //     targetEntry?.remove();
  //     if (resizeableH && resizeableV) {
  //       topLeftCornerEntry?.remove();
  //       topRightCornerEntry?.remove();
  //       bottomLeftCornerEntry?.remove();
  //       bottomRightCornerEntry?.remove();
  //       leftEdgeEntry?.remove();
  //       rightEdgeEntry?.remove();
  //       bottomEdgeEntry?.remove();
  //       topEdgeEntry?.remove();
  //     } else if (resizeableH) {
  //       leftEdgeEntry?.remove();
  //       rightEdgeEntry?.remove();
  //     } else if (resizeableV) {
  //       topEdgeEntry?.remove();
  //       bottomEdgeEntry?.remove();
  //     }
  //   } catch (e) {
  //     // don't know what is causing this issue.
  //     if (false) developer.log("Caught exception removing a callout overlay enty!\n$e", name: "callouts");
  //   }
  // }

// used by onTap callbacks and barrier itself
// will be passed to the barrier overlay and also to the callout (to be accessible via ...findAncestorType...)
  void completed(bool result) {
    if (!completer.isCompleted) {
      // removeRelatedOverlayEntries();
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
      callout.refreshOverlay(() {
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
      callout.refreshOverlay(() {
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

  void refreshOverlay(VoidCallback f) {
    Useful.om.overlaySetState(f);
  }

  void refresh({bool resetSize = false}) {
    Useful.om.overlaySetState(() {
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
              _calloutSizeCache[feature] = size;
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
        : Material(
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
                    if (widget.callout.showTopRightCloseButton)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          iconSize: 36,
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            Useful.om.remove(widget.callout.feature, false);
                          },
                        ),
                      ),
                  ],
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
// print('drawPath');
    Path? path = PathUtil.draw(callout, pointyThickness: callout.height! <= 40 ? 5 : null);
    if (path != null) {
      canvas.drawPath(path, bgPaint(callout.calloutColor));
      canvas.drawPath(path, linePaint(callout.arrowColor, theThickness: thickness));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
