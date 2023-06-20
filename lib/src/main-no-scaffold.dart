import 'package:flutter/material.dart';
import 'package:flutter_callout_api/src/useful.dart';
import 'package:flutter_callout_api/src/widget_helper.dart';
import 'package:flutter_callout_api/src/wrapper/app_wrapper.dart';
import 'package:flutter_callout_api/src/wrapper/image_wrapper_manual.dart';
import 'package:flutter_callout_api/src/wrapper/transformable_widget_wrapper.dart';
import 'package:url_strategy/url_strategy.dart';

import 'wrapper/image_wrapper_auto.dart';

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

  static const String _title = 'Flutter Code Sample';

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double testw = 20;
  double testh = 80;

  ScrollController? vsc;
  ScrollController? hsc;

  @override
  void initState() {
    super.initState();

    // hsc = ScrollController();
    vsc = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    print("main build");
    return MaterialAppWrapper(
      initialValueJsonAssetPath: "callout-scripts/sample-test.json",
      localTestingFilePaths: true,
      runningInProduction: false,
      materialAppF: () => MaterialApp(
        home: Material(
          child: Center(
            child: ListView(
              scrollDirection: Axis.vertical,
              controller: vsc,
              children: [
                //_cats(),
                Container(
                  width: testw,
                  height: testh,
                  color: Colors.redAccent,
                ),
                // Container(
                //   width: testw,
                //   height: testh,
                //   color: Colors.redAccent,
                // ),
                _aibo(),
                Container(
                  width: testw,
                  height: testh,
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cats() => ImageWrapperAuto(
        // twName: "main_scaffold_body",
        iwName: "cats",
        // ancestorHScrollController: hsc,
        ancestorHScrollController: hsc,
        ancestorVScrollController: vsc,
        aspectRatio: 3516 / 1534,
        hardEdge: true,
        imageF: () => assetPicWithFadeIn(
          path: 'images/top-cat-gang.png',
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
          fit: BoxFit.contain,
        ),
      );

  Widget _aibo() => ImageWrapperAuto(
        // twName: "main_scaffold_body",
        iwName: "dogs",
        // ancestorHScrollController: hsc,
        ancestorHScrollController: hsc,
        ancestorVScrollController: vsc,
        aspectRatio: 1,
        imageF: () => assetPicWithFadeIn(
          path: 'images/developer-logo-512x512.png',
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
          fit: BoxFit.contain,
        ),
      );
}
