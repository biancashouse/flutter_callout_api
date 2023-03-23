
import 'package:callout_api/src/overlays/callouts/arrow_type.dart';
import 'package:flutter/material.dart';


class ArrowTypeTool extends StatefulWidget {
  final Function(
      ArrowType ArrowType,
      ) onTypePicked;
  final Function(
      bool animate,
      ) onAnimateArrowToggled;
  final ArrowType? arrowType;
  final bool animate;
  final TextStyle textStyle;

  const ArrowTypeTool({super.key, required this.onTypePicked, required this.onAnimateArrowToggled, this.arrowType, required this.animate, required this.textStyle});

  @override
  State<ArrowTypeTool> createState() => _ArrowTypeToolState();
}

class _ArrowTypeToolState extends State<ArrowTypeTool> {
  late ArrowType _arrowType;
  late bool _animate;

  @override
  void initState() {
    super.initState();
    _arrowType = widget.arrowType ?? ArrowType.POINTY;
    _animate = widget.animate;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ...ArrowType.values
            .map((t) => Padding(
              padding: const EdgeInsets.all(3.0),
              child: _ArrowTypeOption(
                    arrowType: t,
                    arrowColor: widget.textStyle.backgroundColor ?? Colors.white12,
                    isActive: _arrowType == t,
                    onPressed: () {
                      setState(() => _arrowType = t);
                      widget.onTypePicked(t);
                    },
                  ),
            ))
            .toList(),
        OutlinedButton(
          style: OutlinedButton.styleFrom(backgroundColor: widget.animate ? Colors.white : Colors.white12),
          child: const Text(
            'animate',
          ),
          onPressed: () {
            setState(() => _animate = !_animate);
            widget.onAnimateArrowToggled(_animate);
          },
        )
      ],
    );
  }
}

class _ArrowTypeOption extends StatelessWidget {
  final ArrowType arrowType;
  final Color arrowColor;
  final Function() onPressed;
  final bool isActive;

  const _ArrowTypeOption({
    required this.arrowType,
    required this.arrowColor,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = arrowColor==Colors.white ? Colors.black26 : Colors.black12;
    return Container(
      width: 80,
      height: 40,
      color: !isActive ? bgColor : bgColor.withOpacity(.5),
      child: InkWell(
        onTap: onPressed,
        child: arrowType == ArrowType.NO_CONNECTOR
            ? Icon(Icons.rectangle_rounded, color: arrowColor)
            : arrowType == ArrowType.POINTY
                ? Icon(Icons.messenger, color: arrowColor)
                : arrowType == ArrowType.VERY_THIN
                    ? Icon(Icons.south_west, color: arrowColor, size: 15)
                    : arrowType == ArrowType.VERY_THIN_REVERSED
                        ? Icon(Icons.north_east, color: arrowColor, size: 15)
                        : arrowType == ArrowType.THIN
                            ? Icon(Icons.south_west, color: arrowColor, size: 20)
                            : arrowType == ArrowType.THIN_REVERSED
                                ? Icon(Icons.north_east, color: arrowColor, size: 20)
                                : arrowType == ArrowType.MEDIUM
                                    ? Icon(Icons.south_west, color: arrowColor, size: 25)
                                    : arrowType == ArrowType.MEDIUM_REVERSED
                                        ? Icon(Icons.north_east, color: arrowColor, size: 25)
                                        : arrowType == ArrowType.LARGE
                                            ? Icon(Icons.south_west, color: arrowColor, size: 35)
                                            : arrowType == ArrowType.LARGE_REVERSED
                                                ? Icon(Icons.north_east, color: arrowColor, size: 35)
                                                : arrowType == ArrowType.HUGE
                                                    ? Icon(Icons.south_west, color: arrowColor, size: 40)
                                                    : Icon(Icons.north_east, color: arrowColor, size: 40),
      ),
    );
  }
}
