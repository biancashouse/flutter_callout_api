import 'package:callout_api/src/styles/color_palette.dart';
import 'package:flutter/material.dart';

class FontColorTool extends StatelessWidget {
  final List<Color> colors;
  final Color? activeColor;
  final Function(Color) onColorPicked;

  FontColorTool({
    required this.colors,
    required this.onColorPicked,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return ColorPalette(
      activeColor: activeColor,
      onColorPicked: onColorPicked,
      colors: colors,
    );
  }
}
