import 'package:callout_api/src/blink.dart';
import 'package:callout_api/src/gotits/gotits_helper.dart';
import 'package:callout_api/src/useful.dart';
import 'package:flutter/material.dart';

import 'discovery_controller.dart';


class PlayOverlaysButton extends StatefulWidget {
  final DiscoveryController discoveryController;
  final List<int> features;

  PlayOverlaysButton(this.discoveryController, this.features)
      : super(key: GlobalKey<PlayOverlaysButtonState>()) {
    discoveryController.registerPlayFeaturesButton(key as GlobalKey<PlayOverlaysButtonState>?);
  }

  @override
  PlayOverlaysButtonState createState() => PlayOverlaysButtonState();

  bool alreadyGotAllFeatures(BuildContext context) {
    bool result = true;
    for (var fe in features) {
      if (!GotitsHelper.alreadyGotit(fe)) result = false;
    }
    return result;
  }

}

class PlayOverlaysButtonState extends State<PlayOverlaysButton> {

  refresh(f) => setState(f);

  @override
  Widget build(BuildContext context) {
    //print('alreadyGotIt ${widget.features} is ${alreadyGotAllFeatures(context)}');
    int? activeFeature = widget.discoveryController.activeFeature();
    Color? featureColor = activeFeature != null ? DiscoveryController.featureFgColors[activeFeature] :Colors.white;
    //FeaturedWidget activeFw = widget.discoveryController.widgetOf(activeFeature);
    return alreadyGotAllFeatures(context)
        ? Container()
        : SizedBox(
            width: 50,
            child: IconButton(
              icon: Blink(child:Icon(
                Icons.info,
                size: Useful.narrowWidth ? 24.0 : 32.0,
                color: featureColor,
              )),
              onPressed: () {
                widget.discoveryController.startPlay(widget.features);
              },
            ));
  }

  bool alreadyGotAllFeatures(BuildContext context) {
    return widget.alreadyGotAllFeatures(context);
  }
}
