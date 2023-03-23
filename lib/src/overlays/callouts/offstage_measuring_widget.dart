
import 'package:flutter_callout_api/src/measuring/find_global_rect.dart';
import 'package:flutter/material.dart';

class OffstageMeasuringWidget extends StatefulWidget {
  final Widget? child;
  final ValueSetter<Size>? onSized;
  final BoxConstraints? boxConstraints;

  const OffstageMeasuringWidget({
    Key? key,
    this.child,
    this.onSized,
    this.boxConstraints,
  }) : super(key: key);

  @override
  _OffstageMeasuringWidgetState createState() => _OffstageMeasuringWidgetState();
}

class _OffstageMeasuringWidgetState extends State<OffstageMeasuringWidget> {
  late GlobalKey key;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(afterFirstLayout);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: true,
      child: Center(
        child: Container(
          key: key = GlobalKey(),
          // constraints: widget.boxConstraints,
          child: widget.child,
        ),
      ),
    );
  }

  void afterFirstLayout(Duration context) {
    Rect rect = findGlobalRect(key);
    // only the size is useful, because widget is rendered offstage
    widget.onSized?.call(Size(rect.width, rect.height));
  }
}