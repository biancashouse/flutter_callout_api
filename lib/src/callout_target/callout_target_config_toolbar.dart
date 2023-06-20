import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_state.dart';
import 'package:flutter_callout_api/src/callout_help_content/callout_help_content.dart';
import 'package:flutter_callout_api/src/callout_help_content/callout_pointy.dart';
import 'package:flutter_callout_api/src/callout_target/callout_radius_and_zoom.dart';
import 'package:flutter_callout_api/src/callout_target/callout_target_duration.dart';
import 'package:flutter_callout_api/src/model/target_config.dart';

import '../bloc/capi_event.dart';
import '../styles/option_button.dart';

const CALLOUT_CONFIG_TOOLBAR_H = 60.0;

bool isShowingTargetConfigCallout() => Useful.om.anyPresent([CAPI.CALLOUT_CONFIG_TOOLBAR_CALLOUT.feature()]);

void removeTargetConfigToolbarCallout() {
  if (Useful.om.anyPresent([CAPI.CALLOUT_CONFIG_TOOLBAR_CALLOUT.feature()])) {
    print("removeTextEditorCallout");
    Useful.om.remove(CAPI.CALLOUT_CONFIG_TOOLBAR_CALLOUT.feature(), true);
  }
}

void showTargetConfigToolbarCallout(
  final CAPIBloc bloc,
  final ScrollController? ancestorHScrollController,
  final ScrollController? ancestorVScrollController,
) {
  TargetConfig selectedTC = bloc.state.selectedTarget!;
  Callout(
    feature: CAPI.CALLOUT_CONFIG_TOOLBAR_CALLOUT.feature(),
    hScrollController: ancestorHScrollController,
    vScrollController: ancestorVScrollController,
    targetGKF: () => selectedTC.gk(),
    contents: () => CalloutConfigToolbar(
      bloc: bloc,
      ancestorHScrollController: ancestorHScrollController,
      ancestorVScrollController: ancestorVScrollController,
    ),
    // initialCalloutAlignment: Alignment.bottomRight,
    // initialTargetAlignment: Alignment.topLeft,
    separation: 100,
    barrierOpacity: 0.0,
    arrowType: ArrowType.POINTY,
    modal: false,
    widthF: () => 260,
    heightF: () => CALLOUT_CONFIG_TOOLBAR_H,
    draggable: true,
    color: Colors.purpleAccent,
    scaleTarget: selectedTC.transformScale,
    roundedCorners: 16,
  ).show(notUsingHydratedStorage: true);
}

class CalloutConfigToolbar extends StatelessWidget {
  final CAPIBloc bloc;
  final ScrollController? ancestorHScrollController;
  final ScrollController? ancestorVScrollController;

  const CalloutConfigToolbar({
    required this.bloc,
    this.ancestorHScrollController,
    this.ancestorVScrollController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CAPIBloc, CAPIState>(
      builder: (context, state) {
        TargetConfig selectedTarget = state.selectedTarget!;
        bool usingImage = !selectedTarget.usingText;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OptionButton(
              isActive: isShowingTargetDurationCallout(),
              child: const Icon(
                Icons.timer,
                color: Colors.white,
              ),
              onPressed: () {
                if (isShowingTargetDurationCallout()) {
                  removeTargetDurationCallout();
                } else {
                  removeRadiusAndZoomCallout();
                  showTargetDurationCallout(
                    state,
                    ancestorHScrollController,
                    ancestorVScrollController,
                  );
                }
              },
            ),
            OptionButton(
              isActive: isShowingTargetRadiusAndZoomCallout(),
              child: const Icon(
                Icons.circle_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                if (isShowingTargetRadiusAndZoomCallout()) {
                  removeRadiusAndZoomCallout();
                } else {
                  removeTargetDurationCallout();
                  showRadiusAndZoomToast(selectedTarget);
                }
              },
            ),
            //ImageSwitch(tc),
            Container(
              decoration: const ShapeDecoration(
                  color: Colors.purpleAccent,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  )),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  IconButton(
                    icon: const Icon(Icons.image),
                    color: isShowingHelpContentCallout() && usingImage ? Colors.white : Colors.grey,
                    iconSize: 30,
                    onPressed: () {
                      if (isShowingHelpContentCallout() && usingImage) {
                        removeHelpContentEditorCallout();
                        if (isShowingPointyCallout()) removePointyCallout();
                      } else {
                        showHelpContentEditorCallout(selectedTarget, ancestorHScrollController, ancestorVScrollController);
                      }
                      selectedTarget.bloc.add(CAPIEvent.changedHelpContentType(tc:selectedTarget, useImage: true));
                      selectedTarget.bloc.add(CAPIEvent.changedHelpContentType(tc:selectedTarget, useImage: true));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.text_snippet_sharp),
                    color: isShowingHelpContentCallout() && !usingImage ? Colors.white : Colors.grey,
                    iconSize: 30,
                    onPressed: () {
                      if (isShowingHelpContentCallout() && !usingImage) {
                        removeHelpContentEditorCallout();
                        if (isShowingPointyCallout()) removePointyCallout();
                      } else {
                        showHelpContentEditorCallout(selectedTarget, ancestorHScrollController, ancestorVScrollController);
                      }
                      selectedTarget.bloc.add(CAPIEvent.changedHelpContentType(tc:selectedTarget, useImage: false));
                    },
                  ),
                  !isShowingHelpContentCallout()
                      ? Offstage()
                      : IconButton(
                          icon: const Icon(Icons.messenger),
                          color: isShowingPointyCallout() && !usingImage ? Colors.white : Colors.grey,
                          iconSize: 30,
                          onPressed: () {
                            if (isShowingPointyCallout()) {
                              removePointyCallout();
                            } else {
                              showPointyToolToast(selectedTarget, ancestorHScrollController, ancestorVScrollController);
                            }
                          },
                        ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
