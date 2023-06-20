import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/measuring/measure_sizebox.dart';
import 'package:url_strategy/url_strategy.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Sets the URL strategy of your web app to using paths instead of a leading hash (#).
  // You can safely call this on all platforms, i.e. also when running on mobile or desktop. In that case, it will simply be a noop.
  setPathUrlStrategy();

  await Useful.instance.initResponsive();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static const String _title = 'Flutter Measuring Widgets Experiment';

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Useful.afterNextBuildDo(() {
      Callout(
        feature: 987654321,
        contents: () => DottedBorder(
          dashPattern: const [10, 5],
          strokeWidth: 5,
          color: Colors.purpleAccent.withOpacity(.5),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(color:Colors.purple, width: 100,height: 200,),
            ],
          ),
        ),
      ).show(
        notUsingHydratedStorage: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    print("main build");
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,  // IMPORTANT for ensuring callout not behind keyboard
        body: WidgetSizer(
          widget: _contents(),
          onSizedCallback: (size) {
            print("monkey");
          },
        ),
      ),
    );
  }

  Widget _contents() => DottedBorder(
        dashPattern: const [10, 5],
        strokeWidth: 5,
        color: Colors.purpleAccent.withOpacity(.5),
        child: Stack(
          children: [
            Container(
              color: Colors.redAccent,
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        color: Colors.green,
                        width: 100,
                        height: 100,
                      ),
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              color: Colors.yellowAccent[100],
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      text: '\nDesign is the ability to iterate ideas.',
                                      style: TextStyle(
                                        color: Colors.purple,
                                        fontSize: 40,
                                        fontFamily: 'RobotoSlab',
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                  vspacer(10),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.left,
                                        text: TextSpan(
                                          text: 'The more you refine them',
                                          style: TextStyle(
                                            color: Colors.purple,
                                            fontSize: 32,
                                            fontFamily: 'RobotoSlab',
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.left,
                                        text: TextSpan(
                                          text: 'the clearer they become.',
                                          style: TextStyle(
                                            color: Colors.purple,
                                            fontSize: 32,
                                            fontFamily: 'RobotoSlab',
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  vspacer(10),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 50.0, right: 50),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              iconSize: 60,
                              icon: Icon(Icons.close),
                              color: Colors.red[200],
                              onPressed: () {
                                Useful.om.removeAll(exceptToast: true);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class WidgetSizer extends StatefulWidget {
  final Widget widget;
  final ValueChanged<Size> onSizedCallback;

  const WidgetSizer({
    required this.widget,
    required this.onSizedCallback,
    super.key,
  });

  @override
  State<WidgetSizer> createState() => _WidgetSizerState();
}

class _WidgetSizerState extends State<WidgetSizer> {

  @override
  void didChangeDependencies() {
    Useful.instance.initWithContext(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MeasureSizeBox(
      onSizedCallback: (size) {
        widget.onSizedCallback(size);
      },
      child: widget.widget,
    );
  }
}
