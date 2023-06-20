import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callout_api/src/bloc/capi_state.dart';
import 'package:flutter_callout_api/src/overlays/callouts/callout.dart';
import 'package:flutter_callout_api/src/useful.dart';

void removeDottedBorderCallout() {
  print("removeIVRectCallout");
  Useful.om.remove(CAPI.DOTTED_BORDER_CALLOUT.feature(), true);
}

void showDottedBorderCallout(
  final String wrapperName,
  final ScrollController? ancestorHScrollController,
  final ScrollController? ancestorVScrollController,
  final int? ms,
) {
  Callout targetCallout = Callout(
    feature: CAPI.DOTTED_BORDER_CALLOUT.feature(),
    skipOnScreenCheck: true,
    contents: () => DottedBorder(
      dashPattern: const [10, 5],
      strokeWidth: 5,
      color: Colors.purpleAccent.withOpacity(.5),
      child: const Offstage(),
    ),
    initialCalloutPos: CAPIState.iwPos(wrapperName).translate(
      10 - (ancestorHScrollController?.offset ?? 0.0),
      10 - (ancestorVScrollController?.offset ?? 0.0),
    ),
    modal: false,
    widthF: () => CAPIState.iwSize(wrapperName).width - 20,
    heightF: () => CAPIState.iwSize(wrapperName).height - 20,
    draggable: false,
    arrowType: ArrowType.NO_CONNECTOR,
    color: Colors.transparent,
    animate: false,
    transparentPointer: true,
    hScrollController: ancestorHScrollController,
    vScrollController: ancestorVScrollController,
  );

// if callout completed with false, revert to original string
  targetCallout.show(
    notUsingHydratedStorage: true,
    removeAfterMs: ms,
  );
}
