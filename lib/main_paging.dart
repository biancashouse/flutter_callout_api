import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_state.dart';
import 'package:flutter_callout_api/src/model/target_config.dart';
import 'package:flutter_callout_api/src/useful.dart';
import 'package:flutter_callout_api/src/wrapper/transformable_widget_wrapper.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_strategy/url_strategy.dart';

import 'page-bianca.dart';
import 'page-cats.dart';

class AppBlocObserver extends BlocObserver {
  AppBlocObserver();

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) print(change);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition.event);
    CAPIBloc ccBloc = bloc as CAPIBloc;
    CAPIState curr = transition.currentState as CAPIState;
    CAPIState next = transition.nextState as CAPIState;
    TargetConfig? tc = next.selectedTarget;
    // if (tc != null) print()
    // // print("Rel Pos: ${tc?.childLocalPosLeftPc ?? 0.0}, ${tc?.childLocalPosTopPc ?? 0.0}");
    // // print("translate: ${tc?.getTranslate().toString()}  scale: ${tc?.getScale()}");
    // print("playList: ${next.playList.toString()}");
    // for (String iwName in next.imageTargetListMap.keys) {
    //   print("wrapper: $iwName");
    //   for (int i=0; i<(next.imageTargetListMap[iwName]??[]).length; i++) {
    //     print("           ($i)");
    //   }
    // }
    // print("lastupdated is ${next.lastUpdatedTC == null ? 'NULL' : 'not NULL'}");
    // print("ivRect.pos is ${next.ivRectMap[tc?.iwName]}");
  }
}

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Sets the URL strategy of your web app to using paths instead of a leading hash (#).
  // You can safely call this on all platforms, i.e. also when running on mobile or desktop. In that case, it will simply be a noop.
  setPathUrlStrategy();

  Bloc.observer = AppBlocObserver();

  await Useful.instance.initResponsive();

  runApp(SamplePages());
}

class SamplePages extends StatefulWidget {
  @override
  _SamplePagesState createState() => _SamplePagesState();
}

class _SamplePagesState extends State<SamplePages> {
  final controller = PageController(viewportFraction: 1.0, keepPage: true);

  @override
  Widget build(BuildContext context) {
    final pages = [
      CatsPage(),
      BiancaPage(),
    ];

    return MaterialAppWrapper(
      initialValueJsonAssetPath: "callout-scripts/sample-config.json",
      localTestingFilePaths: true,
      runningInProduction: false,
      materialAppF: () => MaterialApp(
        home: TransformableWidgetWrapper(
          twName: "main_scaffold",
          widgetF: () => Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // SizedBox(height: 16),
                    SizedBox.fromSize(
                      size: MediaQuery.of(context).size,
                      child: PageView.builder(
                        controller: controller,
                        // itemCount: pages.length,
                        itemBuilder: (_, index) {
                          return pages[index % pages.length];
                        },
                      ),
                    ),
                    // SmoothPageIndicator(
                    //   controller: controller,
                    //   count: pages.length,
                    //   effect: const WormEffect(
                    //     dotHeight: 16,
                    //     dotWidth: 16,
                    //     type: WormType.thinUnderground,
                    //   ),
                    // ),
                    //
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 16, bottom: 8),
                    //   child: Text(
                    //     'Jumping Dot',
                    //     style: TextStyle(color: Colors.black54),
                    //   ),
                    // ),
                    // Container(
                    //   child: SmoothPageIndicator(
                    //     controller: controller,
                    //     count: pages.length,
                    //     effect: JumpingDotEffect(
                    //       dotHeight: 16,
                    //       dotWidth: 16,
                    //       jumpScale: .7,
                    //       verticalOffset: 15,
                    //     ),
                    //   ),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 16, bottom: 12),
                    //   child: Text(
                    //     'Scrolling Dots',
                    //     style: TextStyle(color: Colors.black54),
                    //   ),
                    // ),
                    // SmoothPageIndicator(
                    //     controller: controller,
                    //     count: pages.length,
                    //     effect: ScrollingDotsEffect(
                    //       activeStrokeWidth: 2.6,
                    //       activeDotScale: 1.3,
                    //       maxVisibleDots: 5,
                    //       radius: 8,
                    //       spacing: 10,
                    //       dotHeight: 12,
                    //       dotWidth: 12,
                    //     )),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 16, bottom: 16),
                    //   child: Text(
                    //     'Customizable Effect',
                    //     style: TextStyle(color: Colors.black54),
                    //   ),
                    // ),
                    // Container(
                    //   // color: Colors.red.withOpacity(.4),
                    //   child: SmoothPageIndicator(
                    //     controller: controller,
                    //     count: pages.length,
                    //     effect: CustomizableEffect(
                    //       activeDotDecoration: DotDecoration(
                    //         width: 32,
                    //         height: 12,
                    //         color: Colors.indigo,
                    //         rotationAngle: 180,
                    //         verticalOffset: -10,
                    //         borderRadius: BorderRadius.circular(24),
                    //         // dotBorder: DotBorder(
                    //         //   padding: 2,
                    //         //   width: 2,
                    //         //   color: Colors.indigo,
                    //         // ),
                    //       ),
                    //       dotDecoration: DotDecoration(
                    //         width: 24,
                    //         height: 12,
                    //         color: Colors.grey,
                    //         // dotBorder: DotBorder(
                    //         //   padding: 2,
                    //         //   width: 2,
                    //         //   color: Colors.grey,
                    //         // ),
                    //         // borderRadius: BorderRadius.only(
                    //         //     topLeft: Radius.circular(2),
                    //         //     topRight: Radius.circular(16),
                    //         //     bottomLeft: Radius.circular(16),
                    //         //     bottomRight: Radius.circular(2)),
                    //         borderRadius: BorderRadius.circular(16),
                    //         verticalOffset: 0,
                    //       ),
                    //       spacing: 6.0,
                    //       // activeColorOverride: (i) => colors[i],
                    //       inActiveColorOverride: (i) => colors[i],
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final colors = const [
  Colors.red,
  Colors.green,
  Colors.greenAccent,
  Colors.amberAccent,
  Colors.blue,
  Colors.amber,
];
