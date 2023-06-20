import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_state.dart';
import 'package:flutter_callout_api/src/measuring/find_global_rect.dart';
import 'package:flutter_callout_api/src/useful.dart';
import 'package:flutter_callout_api/src/wrapper/transformable_widget_wrapper.dart';

class WidgetWrapper extends StatefulWidget {
  final String twName;
  final String wwName;
  final Alignment initialTargetAlignment;
  final Alignment initialCalloutAlignment;
  final Widget child;
  final ScrollController? ancestorHScrollController;
  final ScrollController? ancestorVScrollController;

  WidgetWrapper({
    required this.twName,
    required this.wwName,
    required this.initialTargetAlignment,
    required this.initialCalloutAlignment,
    required this.child,
    this.ancestorHScrollController,
    this.ancestorVScrollController,
  }) : super(key: CAPIState.gkMap["ww.$wwName"] = GlobalKey());

  @override
  State<WidgetWrapper> createState() => WidgetWrapperState();

// /// given a Rect, returns most appropriate alignment between target and callout
// static Alignment calcTargetAlignment(final Rect rect) {
//   double topOffset = rect.top;
//   double bottomOffset = Useful.scrH - rect.bottom;
//   double leftOffset = rect.left;
//   double rightOffset = Useful.scrW - rect.right;
//
//   late double x;
//   late double y;
//   if (leftOffset < Useful.scrW / 3)
//     x = -1;
//   else if (rightOffset < Useful.scrW / 3)
//     x = 1;
//   else
//     x = 0;
//   if (topOffset < Useful.scrH / 3)
//     y = -1;
//   else if (bottomOffset < Useful.scrH / 3)
//     y = 1;
//   else
//     y = 0;
//   print("$x, $y");
//   return Alignment(x, y);
// }
}

class WidgetWrapperState extends State<WidgetWrapper> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Animation<Offset> translationAnimation;
  late Animation<Matrix4> matrix4Animation;
  late AnimationController aController;

  Offset? savedChildLocalPosPc;

  Timer? showTextCalloutTimer;
  bool targetCreationInProgress = false;

  double? scrollOffset;
  Orientation? _lastO;

  final double _scaleX = 1;
  final double _scaleY = 1;

  CAPIBloc get bloc => BlocProvider.of<CAPIBloc>(context);

  @override
  void initState() {
    super.initState();

    aController = AnimationController(vsync: this, duration: DEFAULT_TRANSITION_DURATION_MS);

    matrix4Animation = Matrix4Tween(
      begin: Matrix4.identity(),
      end: Matrix4.identity(),
    ).animate(aController);

    Useful.afterNextBuildDo(() {
      Object? parentState = TransformableWidgetWrapper.of(context);
      if (parentState != null) {
        if (parentState is TransformableWidgetWrapperState)
          parentState.showPlayButton(
            widget.wwName,
            widget.initialTargetAlignment,
            widget.initialCalloutAlignment,
          );
      }

      //   measureWidget();
      //   Callout(
      //     feature: _feature,
      //     targetGKF: () => gk,
      //     contents: () => Material(
      //       color: Colors.transparent,
      //       child: GestureDetector(
      //         onTap: () {
      //           // tapped helper icon - transform scaffold corr to target widget
      //           TransformableBodyWrapperState? swState = CAPIState.twGKMap[widget.twName]?.currentState;
      //           if (swState != null && _rect != null) {
      //             Alignment ta = WidgetWrapper.calcTargetAlignment(_rect!);
      //             swState.applyTransform(3.0, 3.0, ta);
      //             Useful.afterMsDelayDo(3000, () {
      //               swState.resetTransform();
      //             });
      //           }
      //         },
      //         child: Container(
      //           width: 30,
      //           height: 30,
      //           decoration: BoxDecoration(color: FUCHSIA_X, shape: BoxShape.circle),
      //           child: Text(
      //             "?",
      //             style: TextStyle(color: Colors.white, fontSize: 24),
      //             textAlign: TextAlign.center,
      //           ),
      //         ),
      //       ),
      //     ),
      //     initialTargetAlignment: widget.initialTargetAlignment,
      //     initialCalloutAlignment: widget.initialCalloutAlignment,
      //     roundedCorners: 20,
      //     draggable: false,
      //     color: FUCHSIA_X,
      //   ).show(notUsingHydratedStorage: true);
    });
  }

  // void measureWidget() {
  //   try {
  //     _rect = findGlobalRect(gk);
  //   } catch (e) {
  //     print("measureWidget exception!");
  //     // ignore but then don't update pos
  //   }
  // }
  //
  // @override
  // void didChangeMetrics() {
  //   print("***  didChangeMetrics  ***");
  //   measureWidget();
  // }

// @override
// void didUpdateWidget(Object oldWidget) {
//   print("didUpdateWidget");
// }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    aController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (SizeChangedLayoutNotification notification) {
        print("CAPIWidgetWrapperState on Size Change Notification - ${widget.wwName}");
        // measureWidget();
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: BlocBuilder<CAPIBloc, CAPIState>(builder: (context, state) {
          // print("--- ${widget.wwName} builder");
          return Material(
              child: AnimatedBuilder(
            animation: aController,
            builder: (BuildContext context, _) {
              return Transform(
                // transform: matrix4Animation.value,
                transform: Matrix4.identity()..scale(_scaleX, _scaleY),
                child: Container(
                  key: CAPIState.gkMap["w.${widget.wwName}"] = GlobalKey(),
                  child: widget.child,
                ),
              );
            },
          ));
        }),
      ),
    );
  }
}
