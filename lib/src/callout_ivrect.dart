
import 'package:callout_api/src/overlays/callouts/callout.dart';
import 'package:callout_api/src/useful.dart';
import 'package:callout_api/src/wrapper/app_wrapper.dart';
import 'package:callout_api/src/wrapper/widget_wrapper.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';


void removeIVRectCallout() {
  print("removeIVRectCallout");
  Useful.om.remove(CAPI.IVRECT_CALLOUT.feature(), true);
}

void showIVRectCallout(final CAPIWidgetWrapperState parent) {
  Callout targetCallout = Callout(
    feature: CAPI.IVRECT_CALLOUT.feature(),
    skipOnScreenCheck: true,
    contents: () => DottedBorder(
        dashPattern: const [10, 5],
        strokeWidth: 5,
        color: Colors.purpleAccent.withOpacity(.5),
        child: const Offstage(),
      ),
    initialCalloutPos: CAPIAppWrapper.wwPos(parent.widget.wwName).translate(10 -(parent.widget.ancestorScrollController?.offset??0.0), 10),
    modal: false,
    widthF: () => CAPIAppWrapper.wwSize(parent.widget.wwName).width - 20,
    heightF: () => CAPIAppWrapper.wwSize(parent.widget.wwName).height - 20,
    draggable: false,
    arrowType: ArrowType.NO_CONNECTOR,
    color: Colors.transparent,
    animate: false,
    transparentPointer: true,
    hScrollController: parent.widget.ancestorScrollController,
  );

// if callout completed with false, revert to original string
  targetCallout.show(
    notUsingHydratedStorage: true,
  );
}
