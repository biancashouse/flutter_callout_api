import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_event.dart';
import 'package:flutter_callout_api/src/bloc/capi_state.dart';
import 'package:flutter_callout_api/src/callout_target/callout_target_config_toolbar.dart';
import 'package:flutter_callout_api/src/model/target_config.dart';
import 'package:flutter_callout_api/src/callout_help_content/text_toggle_buttons.dart';

import '../../callout_api.dart';

typedef TextStyleFunc = TextStyle Function();
typedef TextAlignFunc = TextAlign Function();

bool isShowingHelpContentCallout() => Useful.om.anyPresent([CAPI.HELP_CONTENT_CALLOUT.feature()]);

void removeHelpContentEditorCallout() {
  if (Useful.om.anyPresent([CAPI.HELP_CONTENT_CALLOUT.feature()])) {
    print("removeTextEditorCallout");
    Useful.om.remove(CAPI.HELP_CONTENT_CALLOUT.feature(), true);
  }
}

/// returning false means user tapped the x
void showHelpContentEditorCallout(
  final TargetConfig selectedTC,
  final ScrollController? ancestorHScrollController,
  final ScrollController? ancestorVScrollController,
) {
  GlobalKey<TextEditorState> calloutChildGK = GlobalKey<TextEditorState>();
  int feature = CAPI.HELP_CONTENT_CALLOUT.feature();
  bool ignoreBarrierTaps = false;
  double minHeight = 0;
  int maxLines = 5;

  Callout txtEditorCallout = Callout(
    feature: feature,
    containsTextField: true,
    hScrollController: ancestorHScrollController,
    vScrollController: ancestorVScrollController,
    focusNode: selectedTC.textFocusNode(),
    targetGKF: () => selectedTC.gk(),
    scale: selectedTC.transformScale,
    contents: () => BlocBuilder<CAPIBloc, CAPIState>(
      builder: (context, state) {
        TargetConfig _tc = state.selectedTarget!;
        return Column(
          children: [
            if (_tc.usingText)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextEditor(
                    key: calloutChildGK,
                    prompt: "edit this callout text...",
                    feature: feature,
                    originalS: _tc.text(),
                    onChangedF: (s) {
                      _tc.setText(s);
                    },
                    minHeight: minHeight,
                    maxLines: maxLines,
                    focusNode: _tc.textFocusNode(),
                    dontAutoFocus: true,
                    bgColor: _tc.calloutColor(),
                    textStyleF: _tc.textStyle,
                    textAlignF: _tc.textAlign,
                  ),
                ),
              ),
            if (_tc.usingText) TextToggleButtons(ancestorHScrollController, ancestorVScrollController),
            if (!_tc.usingText)
              Placeholder(
                fallbackWidth: _tc.calloutWidth,
                fallbackHeight: _tc.calloutHeight,
              ),
          ],
        );
      },
    ),
    barrierOpacity: 0.0,
    color: selectedTC.calloutColor(),
    arrowColor: selectedTC.calloutColor(),
    arrowType: selectedTC.getArrowType(),
    animate: selectedTC.animateArrow,
    initialCalloutPos: selectedTC.getTextCalloutPos(),
    // initialCalloutAlignment: Alignment.bottomCenter,
    // initialTargetAlignment: Alignment.topCenter,
    modal: false,
    widthF: () => selectedTC.calloutWidth,
    heightF: () => selectedTC.calloutHeight + CALLOUT_CONFIG_TOOLBAR_H,
    minHeight: minHeight + 4,
    resizeableH: true,
    resizeableV: true,
    // containsTextField: true,
    // alwaysReCalcSize: true,
    onResize: (Size newSize) {
      selectedTC
        ..calloutWidth = newSize.width
        ..calloutHeight = newSize.height - CALLOUT_CONFIG_TOOLBAR_H;
    },
    onDragEndedF: (Offset newPos) {
      if (newPos.dy != selectedTC.calloutTopPc || newPos.dx != selectedTC.calloutLeftPc) {
        CAPIBloc bloc = selectedTC.bloc;
        bloc.add(CAPIEvent.changedCalloutPosition(tc: selectedTC, newPos: newPos));
        // selectedTC.setTextCalloutPos(newPos);
      }
    },
    draggable: true,
    // frameTarget: true,
    scaleTarget: selectedTC.transformScale,
    roundedCorners: 16,
    // separation: 100,
  );

  txtEditorCallout.show(
    notUsingHydratedStorage: true,
    onReadyF: () {
      Useful.afterMsDelayDo(500, selectedTC.textFocusNode().requestFocus);
    },
  );

  explainPopupsAreDraggable();
}

void showHelpContentPlayCallout(
  final TargetConfig tc,
  final ScrollController? ancestorHScrollController,
  final ScrollController? ancestorVScrollController,
) {
  GlobalKey<TextEditorState> calloutChildGK = GlobalKey<TextEditorState>();
  int feature = CAPI.HELP_CONTENT_CALLOUT.feature();
  double minHeight = 0;
  int maxLines = 5;

  // calc most suitable alignment

  Callout txtEditorCallout = Callout(
    feature: feature,
    containsTextField: true,
    hScrollController: ancestorHScrollController,
    vScrollController: ancestorVScrollController,
    focusNode: tc.textFocusNode(),
    targetGKF: () => tc.gk(),
    scale: tc.transformScale,
    contents: () => Container(
      color: tc.calloutColor(),
        padding: const EdgeInsets.all(12.0),
        child: Text(tc.text(),
          style: tc.textStyle(),
          textAlign: tc.textAlign(),
        )),
    barrierOpacity: 0.0,
    color: tc.calloutColor(),
    arrowColor: tc.calloutColor(),
    arrowType: tc.getArrowType(),
    animate: tc.animateArrow,
    initialCalloutPos: tc.getTextCalloutPos(),
    // initialCalloutAlignment: Alignment.bottomCenter,
    // initialTargetAlignment: Alignment.topCenter,
    modal: false,
    widthF: () => tc.calloutWidth,
    heightF: () => tc.calloutHeight,
    minHeight: minHeight + 4,
    resizeableH: true,
    resizeableV: true,
    draggable: true,
    scaleTarget: tc.transformScale,
    roundedCorners: 16,
    // separation: 50,
  );

  txtEditorCallout.show(
    notUsingHydratedStorage: true,
    onReadyF: () {
      Useful.afterMsDelayDo(500, tc.textFocusNode().requestFocus);
    },
  );

  explainPopupsAreDraggable();
}
