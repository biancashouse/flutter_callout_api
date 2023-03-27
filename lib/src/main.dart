import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_state.dart';
import 'package:flutter_callout_api/src/body/images.dart';
import 'package:flutter_callout_api/src/model/target_config.dart';
import 'package:flutter_callout_api/src/useful.dart';
import 'package:flutter_callout_api/src/widget_helper.dart';
import 'package:flutter_callout_api/src/wrapper/app_wrapper.dart';
import 'package:flutter_callout_api/src/wrapper/widget_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_strategy/url_strategy.dart';

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
    TargetConfig? tc = next.selectedTarget("bianca");
    // if (tc != null) print()
    // // print("Rel Pos: ${tc?.childLocalPosLeftPc ?? 0.0}, ${tc?.childLocalPosTopPc ?? 0.0}");
    // // print("translate: ${tc?.getTranslate().toString()}  scale: ${tc?.getScale()}");
    // print("playList: ${next.playList.toString()}");
    // for (String wwName in next.wtMap.keys) {
    //   print("wrapper: $wwName");
    //   for (int i=0; i<(next.wtMap[wwName]??[]).length; i++) {
    //     print("           ($i)");
    //   }
    // }
    // print("lastupdated is ${next.lastUpdatedTC == null ? 'NULL' : 'not NULL'}");
    // print("ivRect.pos is ${next.ivRectMap[tc?.wwName]}");
  }
}

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Sets the URL strategy of your web app to using paths instead of a leading hash (#).
  // You can safely call this on all platforms, i.e. also when running on mobile or desktop. In that case, it will simply be a noop.
  setPathUrlStrategy();

  Bloc.observer = AppBlocObserver();

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
  late double testw;

  @override
  void initState() {
    testw = 20;
  }

  @override
  Widget build(BuildContext context) {
    print("main build");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Callout API sample'),
        ),
        body: Builder(builder: (context) {
          return CAPIAppWrapper(
            initialValueJsonAssetPath: "callout-scripts/sample-config.json",
            localTestingFilePaths: true,
            runningInProduction: false,
            childF: () => Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: testw,
                  color: Colors.redAccent,
                ),
                Expanded(
                  child: CAPIWidgetWrapper(
                    wwName: "cats",
                    aspectRatio: 3516 / 1534,
                    hardEdge: true,
                    child: assetPicWithFadeIn(
                      path: 'images/top-cat-gang.png',
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Container(
                  width: testw += 30,
                  color: Colors.redAccent,
                ),
                Expanded(
                  child: CAPIWidgetWrapper(
                    wwName: "dogs",
                    aspectRatio: 2984 / 1940,
                    child: assetPicWithFadeIn(
                      path: 'images/pepper-and-aibo.png',
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Container(
                  width: testw += 30,
                  color: Colors.redAccent,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
