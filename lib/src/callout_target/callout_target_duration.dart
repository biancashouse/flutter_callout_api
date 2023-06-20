import 'package:flutter/material.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/bloc/capi_event.dart';
import 'package:flutter_callout_api/src/bloc/capi_state.dart';
import 'package:flutter_callout_api/src/callout_target/numberic_keypad.dart';

bool isShowingTargetDurationCallout() => Useful.om.anyPresent([CAPI.DURATION_CALLOUT.feature()]);

void removeTargetDurationCallout() {
  if (Useful.om.anyPresent([CAPI.DURATION_CALLOUT.feature()])) {
    print("removeStartTimeCallout");
    Useful.om.remove(CAPI.DURATION_CALLOUT.feature(), true);
  }
}

Future<void> showTargetDurationCallout(
  CAPIState state,
  final ScrollController? ancestorHScrollController,
  final ScrollController? ancestorVScrollController,
) async {
  Callout(
    feature: CAPI.DURATION_CALLOUT.feature(),
    targetGKF: () => state.selectedTarget!.gk(),
    hScrollController: ancestorHScrollController,
    vScrollController: ancestorVScrollController,
    contents: () => NumericKeypad(
      label: 'onscreen duration (ms)',
      initialValue: state.selectedTarget!.calloutDurationMs.toString(),
      onClosedF: (s) {
        // if (s != null) {
          state.selectedTarget?.bloc.add(CAPIEvent.changedCalloutDuration(tc: state.selectedTarget!, newDurationMs: int.parse(s)));
        // }
        Useful.om.remove(CAPI.DURATION_CALLOUT.feature(), true);
      },
    ),
    initialTargetAlignment: Alignment.centerRight,
    initialCalloutAlignment: Alignment.centerLeft,
    separation: 30,
    barrierOpacity: 0.0,
    arrowType: ArrowType.POINTY,
    modal: true,
    widthF: () => 400,
    heightF: () => 450,
    draggable: true,
    color: Colors.purpleAccent,
    showCloseButton: true,
    onTopRightButtonPressF: () {
      print("closed");
    },
    closeButtonColor: Colors.white,
    scaleTarget: state.selectedTarget!.transformScale,
  ).show(
    notUsingHydratedStorage: true,
  );
}
