import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_state.dart';
import 'package:flutter_callout_api/src/callout_target/callout_target_config_toolbar.dart';
import 'package:flutter_callout_api/src/model/target_config.dart';
import 'package:flutter_callout_api/src/callout_help_content/callout_sizing.dart';
import 'package:flutter_callout_api/src/wrapper/transformable_widget_wrapper.dart';

import '../bloc/capi_event.dart';

bool isShowingTargetRadiusAndZoomCallout() => Useful.om.anyPresent([CAPI.TARGET_RADIUS_AND_ZOOM_CALLOUT.feature()]);

void removeRadiusAndZoomCallout() {
  if (Useful.om.anyPresent([CAPI.TARGET_RADIUS_AND_ZOOM_CALLOUT.feature()])) {
    print("removeRadiusAndZoomCallout");
    Useful.om.remove(CAPI.TARGET_RADIUS_AND_ZOOM_CALLOUT.feature(), true);
  }
}

showRadiusAndZoomToast(final TargetConfig selectedTC) {
  return WidgetToast(
    gravity: Alignment.topCenter,
    backgroundColor: Colors.purpleAccent,
    feature: CAPI.TARGET_RADIUS_AND_ZOOM_CALLOUT.feature(),
    contents: () => RadiusAndZoom(Axis.horizontal),
    widthF: () => Useful.scrW * .9,
    heightF: () => 116,
    showCloseButton: true,
    closeButtonColor: Colors.white,
  ).show(
    notUsingHydratedStorage: true,
  );
}

// showRadiusAndZoomCallout(final TargetConfig selectedTC) {
//   return Callout(
//     feature: CAPI.TARGET_RADIUS_AND_ZOOM_CALLOUT.feature(),
//     targetGKF: () => selectedTC.gk(),
//     contents: () => RadiusAndZoom(),
//     initialTargetAlignment: Alignment.centerRight,
//     initialCalloutAlignment: Alignment.centerLeft,
//     barrierOpacity: 0.5,
//     separation: 50,
//     modal: true,
//     widthF: () => 400,
//     heightF: () => 300,
//     draggable: true,
//     color: Colors.white,
//     showCloseButton: true,
//     onTopRightButtonPressF: () {
//       print("closed");
//     },
//     closeButtonColor: Colors.white,
//     scaleTarget: selectedTC.transformScale,
//   ).show(
//     notUsingHydratedStorage: true,
//   );
// }

class RadiusAndZoom extends StatefulWidget {
  final Axis axis;

  const RadiusAndZoom(this.axis, {super.key});

  @override
  State<RadiusAndZoom> createState() => _RadiusAndZoomState();
}

class _RadiusAndZoomState extends State<RadiusAndZoom> {
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    CAPIBloc bloc = BlocProvider.of<CAPIBloc>(context);
    TargetConfig? selectedTC = bloc.state.selectedTarget;
    return selectedTC == null
    ? Offstage()
    : widget.axis == Axis.vertical
        ? Container(
            color: Colors.purpleAccent,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Spacer(),
                const Text(
                  "Target Radius",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                ResizeSlider(
                    value: selectedTC.radius,
                    icon: Icons.circle_outlined,
                    onChange: (value) {
                      if (isShowingTargetConfigCallout()) removeTargetConfigToolbarCallout();

                      // Cancel previous debounce timer, if any
                      if (_debounce?.isActive ?? false) _debounce?.cancel();

                      // Set up a new debounce timer
                      _debounce = Timer(const Duration(milliseconds: 100), () {
                        bloc.add(CAPIEvent.changedTargetRadius(tc: selectedTC, newRadius: value));
                      });
                    },
                    min: 10.0,
                    max: 100.0),
                const Spacer(),
                const Text(
                  "Zoom Factor",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                ResizeSlider(
                    value: selectedTC.transformScale,
                    icon: Icons.photo_size_select_large,
                    onChange: (value) {
                      bloc.add(CAPIEvent.changedTransformScale(tc: selectedTC, newScale: value));
                      // find the selected target's TransformableWidgetWrapper
                      // var map = CAPIState.wGKMap;
                      var gk = CAPIState.gk(selectedTC.wName);
                      // var widg = gk?.currentWidget;
                      var ctx = gk?.currentContext;
                      // var state = gk?.currentState;
                      if (ctx != null) {
                        TransformableWidgetWrapperState? wrapper = TransformableWidgetWrapper.of(ctx);
                        wrapper?.zoomImmediately(value, value);
                      }
                    },
                    min: 1.0,
                    max: 3.0),
                const Spacer(),
              ],
            ),
          )
        : Container(
            color: Colors.purpleAccent,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "Target Radius",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      ResizeSlider(
                          value: selectedTC.radius,
                          icon: Icons.circle_outlined,
                          onChange: (value) {
                            // Cancel previous debounce timer, if any
                            if (_debounce?.isActive ?? false) _debounce?.cancel();

                            // Set up a new debounce timer
                            _debounce = Timer(const Duration(milliseconds: 0), () {
                              bloc.add(CAPIEvent.changedTargetRadius(tc:selectedTC, newRadius: value));
                            });
                          },
                          min: 10.0,
                          max: 100.0),
                    ],
                  ),
                ),
                SizedBox(width: 50),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "Zoom Factor",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      ResizeSlider(
                          value: selectedTC.transformScale,
                          icon: Icons.photo_size_select_large,
                          onChange: (value) {
                            // Cancel previous debounce timer, if any
                            if (_debounce?.isActive ?? false) _debounce?.cancel();

                            // Set up a new debounce timer
                            _debounce = Timer(const Duration(milliseconds: 0), () {
                              bloc.add(CAPIEvent.changedTransformScale(tc:selectedTC, newScale: value));
                              // find the selected target's TransformableWidgetWrapper
                              // var map = CAPIState.wGKMap;
                              var gk = CAPIState.gk(selectedTC.wName);
                              // var widg = gk?.currentWidget;
                              var ctx = gk?.currentContext;
                              // var state = gk?.currentState;
                              if (ctx != null) {
                                TransformableWidgetWrapperState? wrapper = TransformableWidgetWrapper.of(ctx);
                                wrapper?.zoomImmediately(value, value);
                              }
                            });
                          },
                          min: 1.0,
                          max: 3.0),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
