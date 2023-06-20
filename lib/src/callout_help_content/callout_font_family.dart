import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_event.dart';
import 'package:flutter_callout_api/src/bloc/capi_state.dart';
import 'package:flutter_callout_api/src/styles/option_button.dart';

import '../../callout_api.dart';
import '../model/target_config.dart';

void showFontFamilyCallout(
  final GlobalKey btnGK,
  final TargetConfig tc,
  final ScrollController? ancestorHScrollController,
  final ScrollController? ancestorVScrollController,
) {
  Callout(
    feature: CAPI.FONT_FAMILY_CALLOUT.feature(),
    hScrollController: ancestorHScrollController,
    vScrollController: ancestorVScrollController,
    targetGKF: () => btnGK,
    contents: () => FontFamilyTool(
      tc: tc,
      ancestorHScrollController: ancestorHScrollController,
      ancestorVScrollController: ancestorVScrollController,
    ),
    initialCalloutAlignment: Alignment.centerRight,
    initialTargetAlignment: Alignment.centerLeft,
    separation: 30,
    barrierOpacity: 0.1,
    modal: true,
    widthF: () => 230,
    heightF: () => 230,
    draggable: true,
    resizeableV: true,
    color: Colors.purpleAccent,
    arrowType: ArrowType.POINTY,
    roundedCorners: 16,
    showCloseButton: true,
    closeButtonColor: Colors.white,
    scaleTarget: tc.transformScale,
  ).show(notUsingHydratedStorage: true);
}

class FontFamilyTool extends StatelessWidget {
  final TargetConfig tc;
  final ScrollController? ancestorHScrollController;
  final ScrollController? ancestorVScrollController;

  const FontFamilyTool({
    super.key,
    required this.tc,
    this.ancestorHScrollController,
    this.ancestorVScrollController,
  });

  @override
  Widget build(BuildContext context) {
    List<String> fontFamilies = const [
      'OpenSansBold',
      "OpenSansExtraBold",
      'OpenSans',
      'Roboto',
      'AlkatraBold.ttf',
    ];
    return BlocBuilder<CAPIBloc, CAPIState>(
      builder: (context, state) {
        TargetConfig _tc = state.selectedTarget!;
        String selectedFamily = _tc.fontFamily;
        return Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView(
                children: [
                  // FONT FAMILY
                  Center(
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: fontFamilies
                          .map<_FontFamilyOptionBtn>(
                            (family) => _FontFamilyOptionBtn(
                              family,
                              isSelected: selectedFamily == family,
                              onSelect: (selectedFont) {
                                _tc.bloc.add(
                                  CAPIEvent.changedCalloutTextStyle(tc:_tc,
                                    newTextStyle: _tc.textStyle().copyWith(
                                          fontFamily: family,
                                        ),
                                  ),
                                );
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FontFamilyOptionBtn extends StatelessWidget {
  final String font;
  final bool isSelected;
  final Function(String) onSelect;

  const _FontFamilyOptionBtn(this.font, {required this.onSelect, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return OptionButton(
      isActive: isSelected,
      size: const Size(160, 45),
      onPressed: () => onSelect(font),
      child: Center(child: Text(font, style: TextStyle(fontFamily: font, color: Colors.white))),
    );
  }
}
