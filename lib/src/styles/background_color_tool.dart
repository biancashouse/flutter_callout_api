import 'package:flutter_callout_api/src/styles/color_palette.dart';
import 'package:flutter/material.dart';

class BackgroundColorTool extends StatelessWidget {
  final List<Color> colors;
  final Color? activeColor;
  final Function(Color) onColorPicked;

  const BackgroundColorTool({super.key,
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
