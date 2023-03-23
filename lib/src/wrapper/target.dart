
import 'package:flutter/material.dart';

class Target extends StatelessWidget {
  final double radius;

  const Target({required this.radius, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 2 * radius,
            height: 2 * radius,
            decoration: BoxDecoration(color: Colors.white.withOpacity(.25), shape: BoxShape.circle),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: CustomPaint(
            foregroundPainter: TargetPainter(),
            size: Size(radius * 2, radius * 2),
          ),
        ),
      ],
    );
  }
}

class TargetPainter extends CustomPainter {
  TargetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    Paint paintWhite() => Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke;
    Paint paintBlack() => Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;
    Paint paintPurple() => Paint()
      ..color = Colors.purpleAccent
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(radius, radius), radius - 10, paintWhite());
    canvas.drawCircle(Offset(radius, radius), radius - 9, paintPurple());
    canvas.drawCircle(Offset(radius, radius), radius - 8, paintWhite());
    canvas.drawLine(Offset(radius-1, 20), Offset(radius-1, size.height - 20), paintWhite());
    canvas.drawLine(Offset(radius, 20), Offset(radius, size.height - 20), paintPurple());
    canvas.drawLine(Offset(radius+1, 20), Offset(radius+1, size.height - 20), paintWhite());
    canvas.drawLine(Offset(20, radius-1), Offset(size.width - 20, radius-1), paintWhite());
    canvas.drawLine(Offset(20, radius), Offset(size.width - 20, radius), paintPurple());
    canvas.drawLine(Offset(20, radius+1), Offset(size.width - 20, radius+1), paintWhite());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
