import 'package:flutter/material.dart';

Size calculateTextSize({
  required String text,
  required TextStyle style,
  required int numLines,
  required BuildContext context,
}) {
  final double textScaleFactor = MediaQuery.of(context).textScaleFactor;

  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text.replaceAll("`10`", "\n"), style: style),
    textDirection: Directionality.of(context),
    textScaleFactor: textScaleFactor,
    maxLines: 6,
  )..layout(minWidth: 0, maxWidth: double.infinity);

  return numLines > 1 ? Size(textPainter.size.width, textPainter.size.height) : textPainter.size;
}
