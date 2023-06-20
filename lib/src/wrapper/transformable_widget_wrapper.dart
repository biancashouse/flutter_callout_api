import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/model/target_config.dart';

import '../../callout_api.dart';
import '../bloc/capi_state.dart';
import 'widget_wrapper.dart';

class TransformableWidgetWrapper extends StatefulWidget {
  final String twName;
  final Widget Function() widgetF;
  final ScrollController? ancestorHScrollController;
  final ScrollController? ancestorVScrollController;

  TransformableWidgetWrapper({
    required this.twName,
    required this.widgetF,
    this.ancestorHScrollController,
    this.ancestorVScrollController,
  }) : super(key: CAPIState.gkMap[twName] = GlobalKey());

  static TransformableWidgetWrapperState? of(BuildContext context) {
    // assert(context != null);
    final TransformableWidgetWrapperState? result = context.findAncestorStateOfType<TransformableWidgetWrapperState>();
    // if (result != null) {
    return result;
    // }
    // throw FlutterError.fromParts(<DiagnosticsNode>[
    //   ErrorSummary(
    //     'TransformableAppBarWrapperState.of() called with a context that does not contain a TransformableAppBarWrapper.',
    //   ),
    //   ErrorDescription(
    //     'No TransformableAppBarWrapper ancestor could be found starting from the context that was passed to TransformableAppBarWrapper.of(). '
    //         'This usually happens when the context provided is from the same StatefulWidget as that '
    //         'whose build function actually creates the TransformableAppBarWrapper widget being sought.',
    //   ),
    //   ErrorHint(
    //     'There are several ways to avoid this problem. The simplest is to use a Builder to get a '
    //         'context that is "under" the TransformableAppBarWrapper.',
    //   ),
    //   ErrorHint(
    //     'A more efficient solution is to split your build function into several widgets. This '
    //         'introduces a new context from which you can obtain the TransformableAppBarWrapper. In this solution, '
    //         'you would have an outer widget that creates the TransformableAppBarWrapper populated by instances of '
    //         'your new inner widgets, and then in these inner widgets you would use TransformableAppBarWrapper.of().\n'
    //         'A less elegant but more expedient solution is assign a GlobalKey to the TransformableAppBarWrapper, '
    //         'then use the key.currentState property to obtain the TransformableAppBarWrapperState rather than '
    //         'using the TransformableAppBarWrapper.of() function.',
    //   ),
    //   context.describeElement('The context used was'),
    // ]);
  }

  @override
  State<TransformableWidgetWrapper> createState() => TransformableWidgetWrapperState();
}

class TransformableWidgetWrapperState extends State<TransformableWidgetWrapper> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Animation<Matrix4> _matrix4Animation;
  late AnimationController _aController;
  late Alignment _transformAlignment;
  late Matrix4 _transformMatrix;

  // Rect? _rect;
  int _feature = DateTime.now().microsecondsSinceEpoch;
  double _scaleX = 1;
  double _scaleY = 1;

  CAPIBloc get bloc => BlocProvider.of<CAPIBloc>(context);

  // called when refreshing from slider change (zero duration etc)
  zoomImmediately(final double scaleX, final double scaleY) {
    _matrix4Animation = Matrix4Tween(begin: Matrix4.identity(), end: Matrix4.identity()..scale(scaleX, scaleY)).animate(_aController);
    _aController.duration = Duration.zero;
    _aController
      ..reset
      ..forward().then((value) {
        _aController.duration = DEFAULT_TRANSITION_DURATION_MS;
      });
  }

  // /// given a Rect, returns most appropriate alignment between target and callout
  // Alignment calcTargetAlignment(final Rect wrapperRect, final Rect targetRect) {
  //   // Rect? wrapperRect = findGlobalRect(widget.key as GlobalKey);
  //
  //   Offset wrapperC = wrapperRect.center;
  //   Offset targetRectC = targetRect.center;
  //   double x = (targetRectC.dx - wrapperC.dx) / (wrapperRect.width / 2);
  //   double y = (targetRectC.dy - wrapperC.dy) / (wrapperRect.height / 2);
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

  void applyTransform(final double scaleX, final double scaleY, final Alignment alignment, {required Function(CAPIBloc) afterTransformF}) {
    _matrix4Animation =
        Matrix4Tween(begin: Matrix4.identity(), end: _transformMatrix = (Matrix4.identity()..scale(scaleX, scaleY))).animate(_aController);
    _transformAlignment = alignment;
    _aController..forward().then((value) => afterTransformF.call(bloc));
  }

  void resetTransform() {
    // _matrix4Animation = Matrix4Tween(begin: Matrix4.identity(), end: Matrix4.identity()).animate(_aController);
    _aController.reverse();
  }

  @override
  void initState() {
    super.initState();

    if (widget.ancestorHScrollController != null) CAPIState.registerScrollController(widget.ancestorHScrollController!);
    if (widget.ancestorVScrollController != null) CAPIState.registerScrollController(widget.ancestorVScrollController!);

    // make available globally
    // CAPIState.gkMap[widget.twName] = widget.key as GlobalKey;

    _aController = AnimationController(vsync: this, duration: DEFAULT_TRANSITION_DURATION_MS);

    // initially no transform
    _matrix4Animation = Matrix4Tween(
      begin: Matrix4.identity(),
      end: Matrix4.identity(),
    ).animate(_aController);

    _transformAlignment = Alignment.center;

    Useful.afterNextBuildDo(() {});
  }

  @override
  void didChangeDependencies() {
    Useful.instance.initWithContext(context, force: true);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CAPIBloc, CAPIState>(
      builder: (context, state) {
        return AnimatedBuilder(
            animation: _aController,
            builder: (BuildContext context, _) {
              return Transform(transform: _matrix4Animation.value, alignment: _transformAlignment, child: widget.widgetF.call());
            });
      },
    );
  }

  void showPlayButton(
    final String wwName,
    final Alignment initialTargetAlignment,
    final Alignment initialCalloutAlignment,
  ) {
    GlobalKey? gk = CAPIState.gk("w.$wwName");
    Callout(
      feature: _feature,
      targetGKF: () => gk,
      contents: () => Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            // tapped helper icon - transform scaffold corr to target widget
            Rect? wrapperRect = findGlobalRect(CAPIState.gk(widget.twName)!);
            Rect? targetRect = findGlobalRect(CAPIState.gk("w.$wwName")!);
            if (wrapperRect != null && targetRect != null) {
              Alignment ta = Useful.calcTargetAlignment(wrapperRect, targetRect);
              applyTransform(3.0, 3.0, ta, afterTransformF: (_){});
              Useful.afterMsDelayDo(3000, () {
                resetTransform();
              });
            }
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: FUCHSIA_X, shape: BoxShape.circle),
            child: Text(
              "?",
              style: TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      initialTargetAlignment: initialTargetAlignment,
      initialCalloutAlignment: initialCalloutAlignment,
      roundedCorners: 20,
      draggable: false,
      color: FUCHSIA_X,
    ).show(notUsingHydratedStorage: true);
  }
}
