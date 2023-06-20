import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_event.dart';
import 'package:flutter_callout_api/src/bloc/capi_state.dart';

import '../../callout_api.dart';
import '../model/target_config.dart';
import '../styles/color_palette.dart';

void showColorCallout(
  final GlobalKey btnGK,
  final TargetConfig tc,
  final ScrollController? ancestorHScrollController,
  final ScrollController? ancestorVScrollController,
) {
  Callout(
    feature: CAPI.COLOR_CALLOUT.feature(),
    hScrollController: ancestorHScrollController,
    vScrollController: ancestorVScrollController,
    targetGKF: () => btnGK,
    contents: () => ColorTool(
      tc: tc,
      ancestorHScrollController: ancestorHScrollController,
      ancestorVScrollController: ancestorVScrollController,
    ),
    initialCalloutAlignment: Alignment.centerRight,
    initialTargetAlignment: Alignment.centerLeft,
    separation: 50,
    barrierOpacity: 0.1,
    arrowColor: Colors.purpleAccent,
    // arrowType: tc.getArrowType(),
    // animate: tc.animateArrow,
    modal: true,
    widthF: () => 666,
    heightF: () => 220,
    draggable: true,
    color: Colors.purpleAccent,
    arrowType: ArrowType.POINTY,
    roundedCorners: 16,
    showCloseButton: true,
    closeButtonColor: Colors.purpleAccent,
    scaleTarget: tc.transformScale,
  ).show(notUsingHydratedStorage: true);
}

class ColorTool extends StatelessWidget {
  final TargetConfig tc;
  final ScrollController? ancestorHScrollController;
  final ScrollController? ancestorVScrollController;

  const ColorTool({
    super.key,
    required this.tc,
    this.ancestorHScrollController,
    this.ancestorVScrollController,
  });

  @override
  Widget build(BuildContext context) {
    List<Color> paletteColors = [
      Colors.white,
      Colors.black,
      Colors.yellow,
      Colors.orange,
      Colors.blue,
      Colors.blue[900]!,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.brown,
      Colors.cyanAccent,
      Colors.pink[50]!,
    ];

    return BlocBuilder<CAPIBloc, CAPIState>(
      builder: (context, state) {
        TargetConfig _tc = state.selectedTarget!;
        String selectedFamily = _tc.fontFamily;
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.white, _tc.calloutColor(), _tc.calloutColor(), Colors.white],
              )),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              ColorPalette(
                activeColor: _tc.textColor(),
                onColorPicked: (color) {
                  _tc.bloc.add(
                    CAPIEvent.changedCalloutTextStyle(tc:_tc, newTextStyle: _tc.textStyle().copyWith(color: color)),
                  );
                },
                colors: paletteColors,
                forBg: false,
              ),
              ColorPalette(
                activeColor: _tc.calloutColor(),
                onColorPicked: (color) {
                  _tc.bloc.add(
                    CAPIEvent.changedCalloutTextStyle(tc:_tc, newTextStyle: _tc.textStyle().copyWith(backgroundColor: color)),
                  );
                },
                colors: paletteColors,
                forBg: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
