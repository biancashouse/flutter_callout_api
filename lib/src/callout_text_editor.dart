
import 'package:callout_api/src/model/target_config.dart';
import 'package:callout_api/src/overlays/callouts/callout.dart';
import 'package:callout_api/src/text_editing/text_editor.dart';
import 'package:callout_api/src/useful.dart';
import 'package:flutter/material.dart';


void removeTextEditorCallout() {
  if (Useful.om.anyPresent([-4])) {
    print("removeTextEditorCallout");
    Useful.om.remove(CAPI.TEXT_CALLOUT.feature(), true);
  }
}
// void hideTextEditorCallout() {
//   print("hide");
//   Useful.om.hideCalloutByFeature(CAPI.TEXT_CALLOUT.feature());
// }
// void unhideTextEditorCallout() {
//   print("unhide");
//   Useful.om.unhideCalloutByFeature(CAPI.TEXT_CALLOUT.feature());
// }
// void updateTextCalloutTargetPos(Offset newGlobalPos) {
//   Callout.updateTargetPosByFeature(CAPI.TEXT_CALLOUT.feature(), newGlobalPos);
// }

/// returning false means user tapped the x
void showTextEditorCallout(
  final TargetConfig tc,
  final ScrollController? ancestorScrollController,
) {
  // if (preventMultipleSameTargetCreatesTimer[tc.uid]?.isActive ?? false) {
  //   print("prevented");
  //   return;
  // }

  GlobalKey<TextEditorState> calloutChildGK = GlobalKey<TextEditorState>();
  int feature = CAPI.TEXT_CALLOUT.feature();
  bool ignoreBarrierTaps = false;
  bool dontAutoFocus = true;
  double minHeight = 0;
  int maxLines = 5;

  late Callout txtEditorCallout;

  txtEditorCallout = Callout(
    feature: feature,
    hScrollController: ancestorScrollController,
    focusNode: tc.focusNode(),
    targetGKF: tc.gk,
    contents: () => TextEditor(
      key: calloutChildGK,
      prompt: "edit this callout text...",
      feature: feature,
      originalS: tc.text(),
      onChangedF: (s) {
        tc.setText(s);
      },
      minHeight: minHeight,
      maxLines: maxLines,
      focusNode: tc.focusNode(),
      dontAutoFocus: true,
      bgColor: Color(tc.calloutColorValue!),
      textStyleF: tc.textStyle,
      textAlignF: tc.textAlign,
    ),
    barrierOpacity: 0.0,
    //separation: 80,
    arrowColor: Color(tc.calloutColorValue!),
    arrowType: tc.getArrowType(),
    animate: tc.animateArrow,
    initialCalloutPos: tc.getTextCalloutPos(),
    modal: false,
    widthF: () => tc.calloutWidth,
    heightF: () => tc.calloutHeight,
    minHeight: minHeight + 4,
    resizeableH: true,
    resizeableV: true,
    containsTextField: true,
    // alwaysReCalcSize: true,
    onResize: (Size newSize) {
      tc
        ..calloutWidth = newSize.width
        ..calloutHeight = newSize.height;
    },
    onDragF: (Offset newPos) {
      tc.setTextCalloutPos(newPos);
    },
    draggable: true,
    color: tc.calloutColor(),
  );

  // if callout completed with false, revert to original string
  print("show text callout");
  txtEditorCallout.show(
      notUsingHydratedStorage: true,
      onReadyF: () {
        // print("count: ${Useful.om.itemCount()}");
        if (txtEditorCallout.isOffscreen()) {
          // Useful.om.refreshAllCallouts();
          if (!dontAutoFocus) {
            Useful.afterMsDelayDo(500, tc.focusNode().requestFocus);
          }
        }
      });
}
