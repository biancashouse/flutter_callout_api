import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'dart:ui' as ui;


import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:collection/collection.dart';

/// Functional equivalent of [RSTransform] in [Matrix4] world,
/// check [RSTransform.fromComponents] for more info about the parameters.

Matrix4 composeMatrix({
  double scale = 1,
  double rotation = 0,
  double translateX = 0,
  double translateY = 0,
  double anchorX = 0,
  double anchorY = 0,
}) {
  final double c = cos(rotation) * scale;
  final double s = sin(rotation) * scale;
  final double dx = translateX - c * anchorX + s * anchorY;
  final double dy = translateY - s * anchorX - c * anchorY;

  //  ..[0]  = c       # x scale
  //  ..[1]  = s       # y skew
  //  ..[4]  = -s      # x skew
  //  ..[5]  = c       # y scale
  //  ..[10] = 1       # diagonal "one"
  //  ..[12] = dx      # x translation
  //  ..[13] = dy      # y translation
  //  ..[15] = 1       # diagonal "one"
  return Matrix4(c, s, 0, 0, -s, c, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
}

/// Helper function that uses [Offset] as [translate] and [anchor].
/// See [composeMatrix] for more info.

Matrix4 composeMatrixFromOffsets({
  double scale = 1,
  double rotation = 0,
  Offset translate = Offset.zero,
  Offset anchor = Offset.zero,
}) => composeMatrix(
  scale: scale,
  rotation: rotation,
  translateX: translate.dx,
  translateY: translate.dy,
  anchorX: anchor.dx,
  anchorY: anchor.dy,
);

class TransformEntry with Diagnosticable {
  /// The scale factor.
  final double scale;

  /// The rotation in radians.
  final double rotation;

  /// The x coordinate of the offset by which to translate the anchor point.
  final double translateX;

  /// The y coordinate of the offset by which to translate the anchor point.
  final double translateY;

  /// The x coordinate of the point around which to scale and rotate.
  final double anchorX;

  /// The y coordinate of the point around which to scale and rotate.
  final double anchorY;

  TransformEntry({
    this.scale = 1,
    this.rotation = 0,
    this.translateX = 0,
    this.translateY = 0,
    this.anchorX = 0,
    this.anchorY = 0,
  });

  TransformEntry.fromOffsets({
    this.scale = 1,
    this.rotation = 0,
    Offset translate = Offset.zero,
    Offset anchor = Offset.zero,
  }) :
        translateX = translate.dx,
        translateY = translate.dy,
        anchorX = anchor.dx,
        anchorY = anchor.dy;

  Matrix4 get matrix => composeMatrix(
    scale: scale,
    rotation: rotation,
    translateX: translateX,
    translateY: translateY,
    anchorX: anchorX,
    anchorY: anchorY,
  );

  TransformEntry updateBy({
    double? scale,
    double? rotation,
    double? translateX,
    double? translateY,
    double? anchorX,
    double? anchorY,
  }) => TransformEntry(
    scale: scale == null? this.scale : this.scale * scale,
    rotation: rotation == null? this.rotation : this.rotation + rotation,
    translateX: translateX == null? this.translateX : this.translateX + translateX,
    translateY: translateY == null? this.translateY : this.translateY + translateY,
    anchorX: anchorX == null? this.anchorX : this.anchorX + anchorX,
    anchorY: anchorY == null? this.anchorY : this.anchorY + anchorY,
  );

  TransformEntry updateByOffsets({
    double? scale,
    double? rotation,
    Offset? translate,
    Offset? anchor,
  }) => TransformEntry(
    scale: scale == null? this.scale : this.scale * scale,
    rotation: rotation == null? this.rotation : this.rotation + rotation,
    translateX: translate == null? translateX : translateX + translate.dx,
    translateY: translate == null? translateY : translateY + translate.dy,
    anchorX: anchor == null? anchorX : anchorX + anchor.dx,
    anchorY: anchor == null? anchorY : anchorY + anchor.dy,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('scale', scale));
    properties.add(DoubleProperty('rotation', rotation));
    properties.add(DoubleProperty('translateX', translateX));
    properties.add(DoubleProperty('translateY', translateY));
    properties.add(DoubleProperty('anchorX', anchorX));
    properties.add(DoubleProperty('anchorY', anchorY));
  }
}

class TransformEntryTween extends Tween<TransformEntry> {
  TransformEntryTween({
    TransformEntry? begin,
    TransformEntry? end
  }) : super(begin: begin, end: end);

  @override
  TransformEntry lerp(double t) => TransformEntry(
    scale: lerpDouble(begin?.scale, end?.scale, t) ?? 1,
    rotation: lerpDouble(begin?.rotation, end?.rotation, t) ?? 0,
    translateX: lerpDouble(begin?.translateX, end?.translateX, t) ?? 0,
    translateY: lerpDouble(begin?.translateY, end?.translateY, t) ?? 0,
    anchorX: lerpDouble(begin?.anchorX, end?.anchorX, t) ?? 0,
    anchorY: lerpDouble(begin?.anchorY, end?.anchorY, t) ?? 0,
  );
}

class AnimatedTransformEntry extends ImplicitlyAnimatedWidget {
  const AnimatedTransformEntry({
    super.key,
    required this.transformEntry,
    this.child,
    super.curve,
    required super.duration,
    super.onEnd,
  });

  final TransformEntry transformEntry;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  @override
  AnimatedWidgetBaseState<AnimatedTransformEntry> createState() => _AnimatedTransformEntryState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TransformEntry>('transformEntry', transformEntry));
  }
}

class _AnimatedTransformEntryState extends AnimatedWidgetBaseState<AnimatedTransformEntry> {
  TransformEntryTween? _transformEntry;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: _transformEntry!.evaluate(animation).matrix,
      child: widget.child,
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _transformEntry = visitor(_transformEntry, widget.transformEntry, (dynamic value) => TransformEntryTween(begin: value as TransformEntry)) as TransformEntryTween?;
  }
}

// ============================================================================
// ============================================================================
//
// examples
//
// ============================================================================
// ============================================================================

main() {
  final examples = [
    _TransformEntryExample0(),
    _TransformEntryExample1(),
    _TransformEntryExample2(),
    _TransformEntryExample3(),
    _TransformEntryExample4(),
    _TransformEntryExample5(),
  ];

  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (ctx) => Scaffold(body: _StartPage()),
      for (int i = 0; i < examples.length; i++)
        'transformEntryExample$i': (ctx) => Scaffold(
          appBar: AppBar(
            titleTextStyle: Theme.of(ctx).textTheme.labelLarge,
            title: Text('_TransformEntryExample$i'),
          ),
          body: examples[i],
        ),
    },
  ));
}

class _StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text('direct Matrix4 composing inside custom FlowDelegate'),
          subtitle: const Text('_TransformEntryExample0'),
          onTap: () => Navigator.of(context).pushNamed('transformEntryExample0'),
        ),
        ListTile(
          title: const Text('direct Matrix4 composing inside custom CustomPainter'),
          subtitle: const Text('_TransformEntryExample1'),
          onTap: () => Navigator.of(context).pushNamed('transformEntryExample1'),
        ),
        ListTile(
          title: const Text('using TransformEntryTween with Transform widget'),
          subtitle: const Text('_TransformEntryExample2'),
          onTap: () => Navigator.of(context).pushNamed('transformEntryExample2'),
        ),
        ListTile(
          title: const Text('using TransformEntryTween with custom CustomPainter'),
          subtitle: const Text('_TransformEntryExample3'),
          onTap: () => Navigator.of(context).pushNamed('transformEntryExample3'),
        ),
        ListTile(
          title: const Text('basic AnimatedTransformEntry example'),
          subtitle: const Text('_TransformEntryExample4'),
          onTap: () => Navigator.of(context).pushNamed('transformEntryExample4'),
        ),
        ListTile(
          title: const Text('multiple AnimatedTransformEntry example showing Truchet tiles'),
          subtitle: const Text('_TransformEntryExample5'),
          onTap: () => Navigator.of(context).pushNamed('transformEntryExample5'),
        ),
      ],
    );
  }
}

class _ExampleFrame extends StatelessWidget {
  const _ExampleFrame({
    super.key,
    required this.child,
    required this.tipText,
  });

  final Widget child;
  final String tipText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: const Color(0xff33ff33),
            padding: const EdgeInsets.all(8),
            child: Text(tipText),
          ),
        ),
      ],
    );
  }
}

class _TransformEntryExample0 extends StatefulWidget {
  @override
  State<_TransformEntryExample0> createState() => _TransformEntryExample0State();
}

class _TransformEntryExample0State extends State<_TransformEntryExample0> {
  late final ticker = Ticker(tick);
  final notifier = ValueNotifier(0);
  final colorNotifier = ValueNotifier(0.0);
  final position = ValueNotifier(const Offset(200, 200));
  Duration totalDuration = Duration.zero;
  Duration lastDuration = Duration.zero;
  final childOpacity = <double>[0.5, 1, 1];

  @override
  Widget build(BuildContext context) {
    return _ExampleFrame(
      tipText: 'tap down and move your finger',
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (d) {
          position.value = d.localPosition;
          ticker.start();
        },
        onPanUpdate: (d) {
          position.value = d.localPosition;
        },
        onPanEnd: (d) {
          totalDuration += lastDuration;
          ticker.stop();
        },
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  for (int i = 0; i < 3; i++)
                    Stack(
                      children: [
                        Slider(
                          value: childOpacity[i],
                          onChanged: (v) => setState(() => childOpacity[i] = v),
                        ),
                        Center(child: Text('child #$i opacity')),
                      ],
                    ),
                ],
              ),
            ),
            Flow(
              delegate: _TransformEntryExample0Delegate(notifier, position, childOpacity),
              children: [
                // child 0
                const SizedBox(
                  width: 150,
                  height: 150,
                  child: FlutterLogo(),
                ),
                // child 1
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    border: Border.symmetric(horizontal: BorderSide(width: 1, color: Colors.black87)),
                  ),
                  child: const FittedBox(child: Icon(Icons.place_outlined, color: Colors.orange)),
                ),
                // child 2
                ValueListenableBuilder<double>(
                    valueListenable: colorNotifier,
                    builder: (context, value, child) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: HSVColor.fromAHSV(1, value % 360, 1, 1).toColor(),
                        ),
                        child: const FittedBox(child: Text('child #2')),
                      );
                    }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  tick(Duration duration) {
    lastDuration = duration;
    notifier.value = duration.inMilliseconds + totalDuration.inMilliseconds;

    colorNotifier.value = notifier.value / 50;
  }

  @override
  void dispose() {
    super.dispose();
    ticker.dispose();
  }
}

class _TransformEntryExample0Delegate extends FlowDelegate {
  _TransformEntryExample0Delegate(this.notifier, this.position, this.childOpacity) : super(repaint: notifier);

  final ValueNotifier<int> notifier;
  final ValueNotifier<Offset> position;
  final List<double> childOpacity;

  @override
  void paintChildren(FlowPaintingContext context) {
    final ms = notifier.value;
    // print(ms);

    context.paintChild(0,
      // defaults to:
      // scale: 1,
      transform: composeMatrixFromOffsets(
        translate: position.value,
        rotation: pi / 8 - pi * ms / 4200,
        anchor: Alignment.center.alongSize(context.getChildSize(0)!),
      ),
      opacity: childOpacity[0],
    );

    context.paintChild(1,
      // defaults to:
      // rotation: 0,
      transform: composeMatrixFromOffsets(
        translate: position.value,
        scale: 1 + pow(sin(pi * ms / 5000), 2) as double,
        anchor: Alignment.topCenter.alongSize(context.getChildSize(1)!),
        rotation: pi * 0.1 * sin(pi * ms / 500),
      ),
      opacity: childOpacity[1],
    );

    final childSize = context.getChildSize(2)!;
    context.paintChild(2,
      transform: composeMatrixFromOffsets(
        translate: position.value,
        scale: 1 + 0.5 * pow(sin(pi * ms / 1200), 2),
        rotation: pi * ms / 1000,
        // anchor: Alignment(1, 0.5).alongSize(childSize),
        anchor: Offset(childSize.width, childSize.height * (1 + sin(pi * ms / 900)) / 2),
      ),
      opacity: childOpacity[2],
    );
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) => true;
}

// ============================================================================

class _TransformEntryExample1 extends StatefulWidget {
  @override
  State<_TransformEntryExample1> createState() => _TransformEntryExample1State();
}

class _TransformEntryExample1State extends State<_TransformEntryExample1> with TickerProviderStateMixin {
  late final AnimationController elevationController;
  late final AnimationController rotationController;
  late Offset center;
  late double currentAngle;
  late double oldAngle;
  late double cumulativeAngle;
  VelocityTracker tracker = VelocityTracker.withKind(PointerDeviceKind.touch);
  bool down = false;
  late ExtensibleLinearSimulation simulation;

  @override
  void initState() {
    super.initState();
    elevationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    rotationController = AnimationController.unbounded(
      vsync: this,
    );
    rotationController.value = 2.22 * pi;

    oldAngle = currentAngle = cumulativeAngle = rotationController.value % (2 * pi);
  }

  get time => Duration(milliseconds: DateTime.now().millisecondsSinceEpoch);

  get rotation => rotationController.value;

  @override
  Widget build(BuildContext context) {
    return _ExampleFrame(
      tipText: 'tap down and move your finger around the center of the red circle\n'
          'you can fling it too',
      child: LayoutBuilder(
          builder: (context, constraints) {
            center = constraints.biggest.center(Offset.zero);
            return Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: Colors.grey.shade400,
                ),
                GestureDetector(
                  onPanDown: (d) {
                    down = true;
                    tracker = VelocityTracker.withKind(PointerDeviceKind.touch);
                    rotationController.stop();
                    cumulativeAngle = oldAngle = rotation;
                    _updateAngle(d.localPosition, false);
                    simulation = ExtensibleLinearSimulation(
                      start: rotationController.value,
                      end: cumulativeAngle,
                      velocity: 2 * pi,
                    );
                    rotationController
                        .animateWith(simulation)
                        .whenCompleteOrCancel(_upElevation);
                  },
                  onPanUpdate: (d) {
                    if (rotationController.isAnimating) {
                      _updateAngle(d.localPosition, false);
                      simulation.extendTo(cumulativeAngle);
                    } else {
                      _updateAngle(d.localPosition);
                      tracker.addPosition(time, Offset(rotation, 0));
                    }
                  },
                  onPanEnd: (d) {
                    down = false;
                    tracker.addPosition(time, Offset(rotation, 0));
                    final v = tracker.getVelocity().pixelsPerSecond.dx;
                    rotationController
                        .animateWith(ClampingScrollSimulation(position: rotation, velocity: v, friction: 0.0001))
                        .whenCompleteOrCancel(elevationController.reverse);
                  },
                  child: CustomPaint(
                    painter: _RotatedLabelsPainter(rotationController, elevationController),
                  ),
                ),
              ],
            );
          }
      ),
    );
  }

  _upElevation() {
    if (down) elevationController.forward();
  }

  @override
  dispose() {
    super.dispose();
    elevationController.dispose();
    rotationController.dispose();
  }

  _updateAngle(Offset position, [bool sync = true]) {
    currentAngle = (position - center).direction;
    final delta = (currentAngle - oldAngle + pi) % (2 * pi) - pi;
    cumulativeAngle += delta;
    oldAngle = currentAngle;
    if (sync) {
      rotationController.value = cumulativeAngle;
    }
  }
}

class _RotatedLabelsPainter extends CustomPainter {
  _RotatedLabelsPainter(this.rotationController, this.elevationController)
      : super(repaint: Listenable.merge([rotationController, elevationController]));

  final AnimationController rotationController;
  final AnimationController elevationController;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const alignments = [Alignment(0.5, -0.25), Alignment(-0.2, 0.35), Alignment(0, 0)];
    const factors = [0.21, 0.71, 1.0];
    final colors = [Colors.blue.shade800, Colors.green.shade800, Colors.red.shade800];
    const intervals = [Interval(0.5, 1.0), Interval(0.25, 0.75), Interval(0.0, 0.5)];

    for (final i in IterableZip([alignments, colors])) {
      final a = i[0] as Alignment;
      final color = i[1] as Color;
      circlePaint.color = color.withOpacity(0.75);
      canvas
        ..drawCircle(a.withinRect(rect), rect.shortestSide * 0.25, circlePaint)
        ..drawCircle(a.withinRect(rect), rect.shortestSide * 0.075, circlePaint);
    }

    for (final i in IterableZip([alignments, factors, intervals])) {
      final a = i[0] as Alignment;
      final factor = i[1] as double;
      final interval = i[2] as Interval;
      final angle = (factor * rotationController.value) % (2 * pi);
      final degrees = 180 * angle / pi;
      final builder = ui.ParagraphBuilder(ui.ParagraphStyle())
        ..pushStyle(ui.TextStyle(fontSize: 20, color: Colors.white))
        ..addText('${degrees.toStringAsFixed(1)}° = ')
        ..pushStyle(ui.TextStyle(color: Colors.orange))
        ..addText('${(angle / pi).toStringAsFixed(2)}𝜋');
      final paragraph = builder.build()
        ..layout(ui.ParagraphConstraints(width: rect.longestSide));
      final paragraphSize = Size(paragraph.longestLine, paragraph.height);
      const paragraphPadding = EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      );
      final boxSize = paragraphPadding.inflateSize(paragraphSize);

      final curve = (elevationController.status == AnimationStatus.reverse)? interval.flipped : interval;
      final t = curve.transform(elevationController.value);
      final matrix = composeMatrixFromOffsets(
        rotation: angle,
        anchor: Offset(-rect.shortestSide * 0.075 - lerpDouble(10, 2, t)!, boxSize.height / 2),
        translate: a.withinRect(rect),
      );
      canvas
        ..save()
        ..transform(matrix.storage);

      final leftColor = HSVColor.fromAHSV(1, degrees, 1, 0.8).toColor();
      final rightColor = HSVColor.fromAHSV(1, degrees, 1, 0.3).toColor();
      final background = BoxDecoration(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
        gradient: LinearGradient(
          colors: [
            Color.lerp(Colors.black, leftColor, t)!,
            Color.lerp(Colors.grey.shade600, rightColor, t)!,
          ],
        ),
        border: Border.all(width: 2, color: Colors.black38),
        boxShadow: [
          BoxShadow(
            blurRadius: 6 * t,
            offset: Offset.fromDirection(angle - pi / 4, 12 * t).scale(1, -1),
            color: Colors.black.withOpacity(0.66),
          ),
        ],
      ).createBoxPainter();
      background.paint(canvas, Offset.zero, ImageConfiguration(size: boxSize));
      canvas
        ..drawParagraph(paragraph, paragraphPadding.topLeft)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_RotatedLabelsPainter oldDelegate) => false;
}

/// Simulates linear movement from [start] to [end] with a fixed, constant [velocity].
/// The [end] position can be extended with [extendBy] / [extendTo] methods making
/// the simulation shorter or longer depending on the new [end] value.
class ExtensibleLinearSimulation extends Simulation {

  ExtensibleLinearSimulation({
    required this.start,
    required double end,
    required double velocity,
  }) : assert(velocity > 0), _end = end, velocity = velocity * (end - start).sign;

  /// Start distance
  final double start;

  /// End distance, can be extended with [extendBy] / [extendTo] methods
  double get end => _end;
  double _end;

  /// Fixed velocity
  final double velocity;

  /// Extend [end] position by given [amount]
  void extendBy(double amount) => extendTo(_end + amount);

  /// Extend [end] position to [value]
  void extendTo(double value) {
    _end = velocity > 0? max(start, value) : min(start, value);
  }

  @override
  double x(double time) {
    final s = start + time * velocity;
    return velocity > 0? min(_end, s) : max(_end, s);
  }

  @override
  double dx(double time) => velocity;

  @override
  bool isDone(double time) => x(time) == _end;
}

// ============================================================================

class _TransformEntryExample2 extends StatefulWidget {
  @override
  State<_TransformEntryExample2> createState() => _TransformEntryExample2State();
}

class _TransformEntryExample2State extends State<_TransformEntryExample2> with TickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  final _intervals = List.generate(5, (index) {
    final begin = lerpDouble(0.2, 0.0, index / 4)!;
    return CurveTween(curve: Interval(begin, begin + 0.8));
  });
  Iterable<Animatable<TransformEntry>> _entries = [];
  Offset _beginOffset = Offset.zero, _endOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return _ExampleFrame(
      tipText: 'tap anywhere to see orange square moving',
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (d) {
              // timeDilation = 10;
              _beginOffset = _endOffset;
              _endOffset = d.localPosition;
              _entries = _intervals.map((interval) => TransformEntryTween(
                begin: TransformEntry.fromOffsets(
                  rotation: 0,
                  translate: _beginOffset,
                  anchor: const Offset(50, 50),
                ),
                end: TransformEntry.fromOffsets(
                  rotation: pi,
                  translate: _endOffset,
                  anchor: const Offset(50, 50),
                ),
              ).chain(interval));
              _controller.forward(from: 0.0);
            },
            child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double t = 0;
                  final children = _entries.map((te) {
                    t = (t + 0.2).clamp(0, 1);
                    return Transform(
                      transform: te.animate(_controller).value.matrix,
                      child: SizedBox.fromSize(
                        size: const Size(100, 100),
                        child: Material(
                          color: HSVColor.fromAHSV(1.0, 40, t, 1.0).toColor(),
                          elevation: 4,
                        ),
                      ),
                    );
                  }).toList();
                  return Stack(
                    children: children,
                  );
                }
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

// ============================================================================

class _TransformEntryExample3 extends StatefulWidget {
  @override
  State<_TransformEntryExample3> createState() => _TransformEntryExample3State();
}

class _TransformEntryExample3State extends State<_TransformEntryExample3> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  final _intervals = List.generate(5, (index) {
    final begin = lerpDouble(0.2, 0.0, index / 4)!;
    return CurveTween(curve: Interval(begin, begin + 0.8));
  });
  Iterable<Animatable<TransformEntry>> _entries = [];
  Offset _beginOffset = Offset.zero, _endOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return _ExampleFrame(
      tipText: 'tap anywhere to see orange square moving',
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (d) {
              _beginOffset = _endOffset;
              _endOffset = d.localPosition;
              _entries = _intervals.map((interval) {
                final te0 = TransformEntry.fromOffsets(
                  scale: 1,
                  rotation: 0,
                  translate: _beginOffset,
                  anchor: const Offset(50, 50),
                );
                final te1 = TransformEntry.fromOffsets(
                  scale: 2,
                  rotation: pi / 2,
                  translate: (_beginOffset + _endOffset) / 2,
                  anchor: const Offset(50, 50),
                );
                final te2 = TransformEntry.fromOffsets(
                  scale: 1,
                  rotation: pi,
                  translate: _endOffset,
                  anchor: const Offset(50, 50),
                );
                return TweenSequence<TransformEntry>([
                  TweenSequenceItem(tween: TransformEntryTween(begin: te0, end: te1), weight: 1),
                  TweenSequenceItem(tween: TransformEntryTween(begin: te1, end: te2), weight: 2),
                ]).chain(interval);
              });
              _controller.forward(from: 0.0);
              setState(() {});
            },
            child: CustomPaint(
              painter: TransformEntryExample3Painter(_controller, _entries),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class TransformEntryExample3Painter extends CustomPainter {
  TransformEntryExample3Painter(this._controller, this._entries) : super(repaint: _controller);

  final AnimationController _controller;
  final Iterable<Animatable<TransformEntry>> _entries;
  final _paint0 = Paint();
  final _paint1 = Paint()..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    // timeDilation = 10;
    final rect = Offset.zero & const Size(100, 100);
    double t = 0;
    for (final entry in _entries) {
      t = (t + 0.2).clamp(0, 1);
      final matrix = entry.animate(_controller).value.matrix;
      final color = HSVColor.fromAHSV(1.0, 40, t, 1.0).toColor();
      canvas
        ..save()
        ..transform(matrix.storage)
        ..drawRect(rect, _paint0..color = color)
        ..drawRect(rect, _paint1..color = Colors.black.withOpacity(t))
        ..restore();
    }
  }

  @override
  bool shouldRepaint(TransformEntryExample3Painter oldDelegate) => false;
}

// ============================================================================

class _TransformEntryExample4 extends StatefulWidget {
  @override
  State<_TransformEntryExample4> createState() => _TransformEntryExample4State();
}

class _TransformEntryExample4State extends State<_TransformEntryExample4> {
  final _intervals = List.generate(5, (index) {
    final begin = lerpDouble(0.2, 0.0, index / 4)!;
    return Interval(begin, begin + 0.8);
  });
  List<Widget> _children = [];
  double _rotation = 0;

  @override
  Widget build(BuildContext context) {
    return _ExampleFrame(
      tipText: 'tap anywhere to see orange square moving',
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (d) {
              // timeDilation = 10;
              _rotation += pi;
              double t = 0;
              _children = _intervals.map((interval) {
                t = (t + 0.2).clamp(0, 1);
                return AnimatedTransformEntry(
                  duration: const Duration(milliseconds: 750),
                  transformEntry: TransformEntry.fromOffsets(
                    rotation: _rotation,
                    translate: d.localPosition,
                    anchor: const Offset(50, 50),
                  ),
                  curve: interval,
                  child: SizedBox.fromSize(
                    size: const Size(100, 100),
                    child: Material(
                      color: HSVColor.fromAHSV(1.0, 40, t, 1.0).toColor(),
                      elevation: 4,
                    ),
                  ),
                );
              }).toList();
              setState(() {});
            },
            child: Stack(
              children: _children,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================

const tileSize = 64.0;
class _TransformEntryExample5 extends StatefulWidget {
  @override
  State<_TransformEntryExample5> createState() => _TransformEntryExample5State();
}

class _TransformEntryExample5State extends State<_TransformEntryExample5> {
  final r = Random();
  List<_Tile>? tiles;

  @override
  Widget build(BuildContext context) {
    return _ExampleFrame(
      tipText: 'tap any tile to start animation',
      child: LayoutBuilder(
          builder: (context, constraints) {
            tiles ??= _initialize(constraints).toList();
            return Stack(
              children: [
                const SizedBox.expand(),
                for (int i = 0; i < tiles!.length; i++)
                  AnimatedTransformEntry(
                    duration: const Duration(milliseconds: 1000),
                    transformEntry: TransformEntry.fromOffsets(
                      translate: tiles![i].translation,
                      rotation: tiles![i].rotation,
                      anchor: const Offset(tileSize / 2, tileSize / 2),
                    ),
                    curve: Curves.easeInOut,
                    child: SizedBox.fromSize(
                      size: const Size.square(tileSize),
                      child: CustomPaint(
                        foregroundPainter: _TransformEntryExample5Painter(
                          tiles![i].color, tiles![i].useCenter0, tiles![i].useCenter1,
                        ),
                        child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                // timeDilation = 10;
                                tiles![i].rotation = tiles![i].rotation == 0? pi / 2 : 0;
                                final idx = r.nextInt(tiles!.length);
                                if (idx != i) {
                                  _swap(tiles![i], tiles![idx]);
                                }
                              });
                            },
                            child: const SizedBox.expand()),
                      ),
                    ),
                  ),
              ],
            );
          }
      ),
    );
  }

  Iterable<_Tile> _initialize(BoxConstraints constraints) sync* {
    for (int y = 0; y < (constraints.maxHeight / tileSize).ceil(); y++) {
      for (int x = 0; x < (constraints.maxWidth / tileSize).ceil(); x++) {
        final translation = Offset(tileSize * x + tileSize / 2, tileSize * y + tileSize / 2);
        final rotation = r.nextBool()? pi / 2 : 0.0;
        final color = r.nextBool()? const Color(0xff006600) : const Color(0xffaa0000);

        final b = r.nextDouble() < 0.125;
        yield _Tile(translation, rotation, color, b, b);

        // yield _Tile(translation, rotation, color, false, false);
      }
    }
  }

  void _swap(_Tile tile0, _Tile tile1) {
    final translation0 = tile0.translation;
    final rotation0 = tile0.rotation;

    tile0
      ..translation = tile1.translation
      ..rotation = tile1.rotation;
    tile1
      ..translation = translation0
      ..rotation = rotation0;
  }
}

class _Tile {
  _Tile(this.translation, this.rotation, this.color, this.useCenter0, this.useCenter1);

  Offset translation;
  double rotation;
  final Color color;
  final bool useCenter0;
  final bool useCenter1;
}

class _TransformEntryExample5Painter extends CustomPainter {
  _TransformEntryExample5Painter(this._color, this._useCenter0, this._useCenter1);

  final Color _color;
  final bool _useCenter0;
  final bool _useCenter1;
  final _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = size.shortestSide / 2;
    _paint.color = _color;

    // canvas
    //   ..drawArc(Rect.fromCircle(center: rect.center, radius: radius), 0, pi / 2, _useCenter0, _paint)
    //   ..drawArc(Rect.fromCircle(center: rect.center, radius: radius), pi, pi / 2, _useCenter0, _paint);

    canvas
      ..drawArc(Rect.fromCircle(center: rect.topLeft, radius: radius), 0, pi / 2, _useCenter0, _paint)
      ..drawArc(Rect.fromCircle(center: rect.bottomRight, radius: radius), pi, pi / 2, _useCenter1, _paint);
  }

  @override
  bool shouldRepaint(_TransformEntryExample5Painter oldDelegate) => false;
}