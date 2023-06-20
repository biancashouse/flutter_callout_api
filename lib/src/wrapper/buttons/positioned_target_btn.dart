import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_event.dart';
import 'package:flutter_callout_api/src/bloc/capi_state.dart';
import 'package:flutter_callout_api/src/callout_help_content/callout_help_content.dart';
import 'package:flutter_callout_api/src/model/target_config.dart';
import 'package:flutter_callout_api/src/wrapper/image_wrapper_auto.dart';
import 'package:flutter_callout_api/src/wrapper/transformable_widget_wrapper.dart';

class PositionedTargetBtn extends StatefulWidget {
  final ImageWrapperAutoState parent;
  final String iwName;
  final int tcIndex;
  final bool draggable;

  const PositionedTargetBtn({
    required this.parent,
    required this.iwName,
    required this.tcIndex,
    required this.draggable,
    super.key,
  });

  @override
  State<PositionedTargetBtn> createState() => _PositionedTargetBtnState();
}

class _PositionedTargetBtnState extends State<PositionedTargetBtn> {
  @override
  Widget build(BuildContext context) {
    CAPIBloc bloc = BlocProvider.of<CAPIBloc>(context);
    TargetConfig tc = bloc.state.target(widget.iwName, widget.tcIndex)!;
    return Positioned(
      top: tc.btnStackPos().dy - tc.bloc.state.CAPI_TARGET_BTN_RADIUS,
      left: tc.btnStackPos().dx - tc.bloc.state.CAPI_TARGET_BTN_RADIUS,
      child: widget.draggable ? _draggableSelectTargetBtn() : _playTargetBtn(),
    );
  }

  Widget _draggableSelectTargetBtn() {
    CAPIBloc bloc = BlocProvider.of<CAPIBloc>(context);
    TargetConfig tc = bloc.state.target(widget.iwName, widget.tcIndex)!;
    return Draggable(
        childWhenDragging: Offstage(),
        feedback: IntegerCircleAvatar(
          tc,
          num: tc.bloc.state.targetIndex(tc) + 1,
          bgColor: tc.calloutColor(),
          radius: tc.bloc.state.CAPI_TARGET_BTN_RADIUS,
          textColor: Color(tc.textColorValue ?? Colors.white.value),
          fontSize: 14,
        ),
        child: GestureDetector(
          onTap: () {
            if (tc.bloc.state.aTargetIsSelected()) {
              tc.bloc.add(CAPIEvent.clearSelection(wName: widget.parent.widget.iwName));
            } else {
              tc.bloc.add(CAPIEvent.selectTarget(tc: tc));
            }
          },
          child: IntegerCircleAvatar(
            tc,
            num: tc.bloc.state.targetIndex(tc) + 1,
            bgColor: tc.calloutColor(),
            radius: tc.bloc.state.CAPI_TARGET_BTN_RADIUS,
            textColor: Color(tc.textColorValue ?? Colors.white.value),
            fontSize: 14,
          ),
        ),
        // onDragUpdate: (DragUpdateDetails details) {
        //   Offset newGlobalPos = details.globalPosition.translate(
        //     widget.parent.widget.ancestorHScrollController?.offset ?? 0.0,
        //     widget.parent.widget.ancestorVScrollController?.offset ?? 0.0,
        //   );
        //   // tc.setBtnStackPosPc(newGlobalPos);
        // },
        onDragEnd: (DraggableDetails details) {
          Offset iwPos = CAPIState.iwPos(widget.parent.widget.iwName).translate(
            widget.parent.widget.ancestorHScrollController?.offset ?? 0.0,
            widget.parent.widget.ancestorVScrollController?.offset ?? 0.0,
          );
          Offset localPos = details.offset.translate(
            -iwPos.dx,
            -iwPos.dy,
          );
          double scale = tc.getScale();
          // localPos = localPos * scale;
          Offset newGlobalPos = localPos.translate(iwPos.dx, iwPos.dy);
          tc.setBtnStackPosPc(newGlobalPos);
          tc.bloc.add(CAPIEvent.btnMoved(tc: tc, newGlobalPos: newGlobalPos));
        },
      );
  }

  Widget _playTargetBtn() {
    CAPIBloc bloc = BlocProvider.of<CAPIBloc>(context);
    TargetConfig tc = bloc.state.target(widget.iwName, widget.tcIndex)!;
    return GestureDetector(
        onTap: () {
          // bloc.add(CAPIEvent.startPlaying(iwName: widget.iwName));
          playTarget(tc);
        },
        child: IntegerCircleAvatar(
          tc,
          num: tc.bloc.state.targetIndex(tc) + 1,
          bgColor: tc.calloutColor(),
          radius: tc.bloc.state.CAPI_TARGET_BTN_RADIUS,
          textColor: Color(tc.textColorValue ?? Colors.white.value),
          fontSize: 14,
        ),
      );
  }

  void playTarget(tc) {
    // tapped helper icon - transform scaffold corr to target widget, then show content callout
    Rect? wrapperRect = findGlobalRect(CAPIState.gk(widget.parent.widget.iwName)!);
    Rect? targetRect = findGlobalRect(tc.gk());
    if (wrapperRect != null && targetRect != null) {
      TransformableWidgetWrapperState? parentState = TransformableWidgetWrapper.of(context);
      if (parentState != null) {
        Alignment ta = Useful.calcTargetAlignment(wrapperRect, targetRect);
        tc.bloc.add(CAPIEvent.hideTargetsDuringPlayExcept(tc: tc));
        parentState.applyTransform(tc.transformScale, tc.transformScale, ta, afterTransformF: (_) {
          showHelpContentPlayCallout(
            tc,
            widget.parent.widget.ancestorHScrollController,
            widget.parent.widget.ancestorVScrollController,
          );
        });
        Useful.afterMsDelayDo(tc.calloutDurationMs, () {
          removeHelpContentEditorCallout();
          parentState.resetTransform();
          tc.bloc.add(CAPIEvent.unhideTargets());
        });
      }
    }
  }
}
