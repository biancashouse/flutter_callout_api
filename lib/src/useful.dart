import 'dart:async';
import 'dart:developer' as developer;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_platform/universal_platform.dart';
import "package:yaml/yaml.dart";

import 'overlays/overlay_manager.dart';

typedef SetStateF = void Function(VoidCallback f);
typedef PassBlocF = void Function(CAPIBloc);
typedef PassGlobalKeyF = void Function(GlobalKey);

class Useful {
  bool _initialisedWithContext = false;

  // late SharedPreferences _prefs;
  // late LocalStoreHydrated _localStore;
  final Map<String, OverlayManager> _oms = {};
  late BuildContext _cachedContext;
  late MediaQueryData _mqd;
  late _Responsive _responsive;

  Useful._();

  static final instance = Useful._();

  // static SharedPreferences get prefs => instance._prefs;

  //static LocalStoreHydrated get localStore => instance._localStore;

  static OverlayManager get om {
    OverlayManager? om = instance._oms["root"];
    if (om == null) {
      throw ('''
      
You didn't call Useful.instance.initWithContext() !
You'd normally do it like this:

  @override
  void didChangeDependencies() {
    Useful.instance.initWithContext(context, force: true);
    super.didChangeDependencies();
  }
''');
    } else
      return om;
  }

  // static OverlayManager namedOM(String name) => instance._overlays[name]!;

  static BuildContext get cachedContext => instance._cachedContext;

  // This is where you can initialize the resources needed by your app while
  // the splash screen is displayed.
  Future<void> initResponsive() async {
    _responsive = await _Responsive().init();
  }

  // must be called from a widget build
  void initWithContext(BuildContext context, {bool force = false}) {
    if (_initialisedWithContext && !force) return;
    _mqd = MediaQuery.of(_cachedContext = context);
    _initialisedWithContext = true;
    if (!instance._oms.containsKey("root")) instance._oms["root"] = OverlayManager(Overlay.of(context, rootOverlay: true));
  }

  void createOM(BuildContext context, String name) {
    if (instance._oms.containsKey(name)) return;
    instance._oms[name] = OverlayManager(Overlay.of(context));
    if (instance._oms[name] == instance._oms["root"]) {
      print('@!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!@');
      print("Could not find Overlay $name using this context!");
      print('@!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!@');
    }
  }

  // needs a context to get mediaquery, so gets set in the pqge builds [see getScreenSizeAndPossiblyNewOverlayManager()], but for now JIC, give default values

  static double get scrW => instance._mqd.size.width;

  static double get scrH => instance._mqd.size.height;

  // static double get keyboardHeight => instance._mqd.viewInsets.bottom;

  static double get kbdH {
    if (!isIOS && !isAndroid) return 0.0;
    final viewInsets = EdgeInsets.fromWindowPadding(WidgetsBinding.instance.window.viewInsets, WidgetsBinding.instance.window.devicePixelRatio);
    return viewInsets.bottom;
  }

  static Orientation get orientation => instance._mqd.orientation;

  static bool get isPortrait => orientation == Orientation.portrait;

  static bool get isLandscape => orientation == Orientation.landscape;

  static double get shortestSide => instance._mqd.size.shortestSide;

  static double get longestSide => instance._mqd.size.longestSide;

  static bool get narrowWidth => instance._mqd.size.shortestSide < 600 && isPortrait;

  static bool get shortHeight => instance._mqd.size.shortestSide < 600 && isLandscape;

  // The equivalent of the "smallestWidth" qualifier on Android.
  static bool get usePhoneLayout => instance._mqd.size.shortestSide < 600;

  static bool get useTabletLayout => !kIsWeb && instance._mqd.size.shortestSide >= 600;

  static EdgeInsets get viewPadding => instance._mqd.viewPadding;

  static late PackageInfo _packageInfo;

  static String get actualVersion => _packageInfo.version;

  static String get actualBuildNumber => _packageInfo.buildNumber;

  static Future<bool> informUserOfNewVersion() async {
    _packageInfo = await PackageInfo.fromPlatform();
    // decide whether new version loaded
    String? storedVersionAndBuild = await HydratedBloc.storage.read("versionAndBuild");
    String latestVersionAndBuild = '$actualVersion-$actualBuildNumber';
    if (latestVersionAndBuild != (storedVersionAndBuild ?? '')) {
      await HydratedBloc.storage.write('versionAndBuild', latestVersionAndBuild);
      if (storedVersionAndBuild != null) return true;
    }
    return false;
  }

  static debug() {
    developer.log('queryData.size.width = $scrW');
    developer.log('queryData.size.height = $scrH');
    developer.log('queryData.orientation = ${orientation.name}');
  }

  static void afterNextBuildDo(VoidCallback fn, {List<ScrollController>? scrollControllers}) {
    Map<int, double> savedOffsets = {};
    if (scrollControllers != null && scrollControllers.isNotEmpty) {
      for (int i = 0; i < scrollControllers.length; i++) {
        ScrollController sc = scrollControllers[i];
        if (sc.positions.isNotEmpty) {
          savedOffsets[i] = sc.offset;
        }
      }
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (savedOffsets.isNotEmpty) {
          for (int i in savedOffsets.keys) {
            scrollControllers![i].jumpTo(savedOffsets[i]!);
            // scrollControllers![i].animateTo(savedOffsets[i]!, duration: Duration(milliseconds: 500), curve: Curves.easeIn);
          }
        }
        fn.call();
      },
    );
  }

  // void _saveScrollOffsets() {
  //   if (editingPageState?.vScrollController.positions.isNotEmpty ?? false) {
  //     _vScrollControllerOffset = editingPageState?.vScrollController.offset;
  //   }
  //   if (editingPageState?.hScrollController.positions.isNotEmpty ?? false) {
  //     _hScrollControllerOffset = editingPageState?.hScrollController.offset;
  //   }
  //   if (editingPageState != null && editingPageState!.itemScrollController.hasClients) {
  //     commentsAutoScrollControllerOffset = editingPageState!.itemScrollController.offset;
  //   }
  // }
  //
  // void restoreScrollOffsetsAfterNextBuild() {
  //   _saveScrollOffsets();
  //   Useful.afterNextBuildDo(() {
  //     print('restoreScrollOffsetsAfterNextBuild');
  //     if (_vScrollControllerOffset != null && (editingPageState?.vScrollController.hasClients ?? false)) {
  //       editingPageState?.vScrollController.jumpTo(_vScrollControllerOffset!);
  //     }
  //     if (_hScrollControllerOffset != null && (editingPageState?.hScrollController.hasClients ?? false)) {
  //       editingPageState?.hScrollController.jumpTo(_hScrollControllerOffset!);
  //     }
  //     if (commentsAutoScrollControllerOffset != null && (editingPageState?.itemScrollController.hasClients ?? false)) {
  //       editingPageState?.itemScrollController.jumpTo(commentsAutoScrollControllerOffset!);
  //     }
  //   });
  // }

  static void afterNextBuildPassBlocAndDo(CAPIBloc bloc, PassBlocF fn) => WidgetsBinding.instance.addPostFrameCallback(
        (_) {
      fn.call(bloc);
    },
  );

  static void afterNextBuildPassGlobalKeyAndDo(GlobalKey gk, PassGlobalKeyF fn) => WidgetsBinding.instance.addPostFrameCallback(
        (_) {
      fn.call(gk);
    },
  );

  // static void afterNextBuildDoAsync(VoidCallback fn) => WidgetsBinding.instance.addPostFrameCallback(
  //       (_) async {
  //         fn.call();
  //       },
  //     );

  static Future afterMsDelayDo(int millis, VoidCallback fn) async => Future.delayed(Duration(milliseconds: millis), () {
        fn.call();
      });

  static Future afterMsDelayPassBlocAndDo(int millis, CAPIBloc bloc, PassBlocF fn) async => Future.delayed(Duration(milliseconds: millis), () {
        fn.call(bloc);
      });

  // static Future afterMsDelayDoAsync(int millis, VoidCallback fn) async => Future.delayed(Duration(milliseconds: millis), () async {
  //       fn.call();
  //     });

  static bool get isDesktopSized {
    return !isIOS && !isAndroid && scrW > 1023;
  }

  static bool get isWeb => kIsWeb;

  static bool get isAndroid => UniversalPlatform.isAndroid;

  static bool get isIOS => UniversalPlatform.isIOS;

  static bool get isMac => UniversalPlatform.isMacOS;

  static bool get isWindows => UniversalPlatform.isWindows;

  static bool get isFuchsia => UniversalPlatform.isFuchsia;

  static String? get deviceInfo => instance._responsive._deviceInfo;

  static PlatformEnum? get platform => instance._responsive._platform;

  static const double LARGEST_PHONE_WIDTH = 400.0;

  /// given a Rect, returns most appropriate alignment between target and callout
  static Alignment calcTargetAlignment(Rect wrapperRect, final Rect targetRect) {
    // Rect? wrapperRect = findGlobalRect(widget.key as GlobalKey);

    Rect screenRect = Rect.fromLTWH(0, 0, Useful.scrW, Useful.scrH);
    wrapperRect = screenRect;
    Offset wrapperC = wrapperRect.center;
    Offset targetRectC = targetRect.center;
    double x = (targetRectC.dx - wrapperC.dx) / (wrapperRect.width / 2);
    double y = (targetRectC.dy - wrapperC.dy) / (wrapperRect.height / 2);
    // keep away from sides
    if (x < -0.75)
      x = -1.0;
    else if (x > 0.75) x = 1.0;
    if (y < -0.75)
      y = -1.0;
    else if (y > 0.75) y = 1.0;
    print("$x, $y");
    return Alignment(x, y);
  }

  static Future<String> getPubspecYamlStringValue(final String name) async {
    final yamlString = await rootBundle.loadString('pubspec.yaml');
    final parsedYaml = loadYaml(yamlString);
    final String ver = parsedYaml[name];
    return ver;
  }

  static Offset? findGlobalPos(GlobalKey key) {
    BuildContext? cxt = key.currentContext;
    RenderObject? renderObject = cxt?.findRenderObject();
    return (renderObject as RenderBox).localToGlobal(Offset.zero);
  }
}

enum PlatformEnum { android, ios, web, windows, osx, fuchsia, linux }

class _Responsive {
  static final _Responsive instance = _Responsive._();
  String? _deviceInfo;
  PlatformEnum? _platform;

  // private, named constructor
  _Responsive._();

  factory _Responsive() => instance;

  Future<_Responsive> init() async {
    try {
      if (kIsWeb) {
        instance._deviceInfo = 'web browser';
        instance._platform = PlatformEnum.web;
      } else if (UniversalPlatform.isAndroid) {
        AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
        instance._deviceInfo = info.brand; //'${info.manufacturer} ${info.model}';
        instance._platform = PlatformEnum.android;
      } else if (UniversalPlatform.isIOS) {
        IosDeviceInfo info = await DeviceInfoPlugin().iosInfo;
        instance._deviceInfo = info.model; //'${info.model}';
        instance._platform = PlatformEnum.ios;
      } else if (UniversalPlatform.isWindows) {
        instance._deviceInfo = 'Windows';
        instance._platform = PlatformEnum.windows;
      }
    } on Exception {
      instance._deviceInfo = 'not-android-nor-ios-nor-windows';
    }
    return instance;
  }

  // static var o, w, h;
  // static void mq(BuildContext theCtx) {
  //   o = MediaQuery.of(theCtx).orientation;
  //   w = MediaQuery.of(theCtx).size.width;
  //   h = MediaQuery.of(theCtx).size.height;
  // }
  //
  // static double maxW(BuildContext ctx, int maxPixels) {
  //   mq(ctx);
  //   return min(w, maxPixels.toDouble());
  // }
  //
  // static double screenW(BuildContext ctx) {
  //   mq(ctx);
  //   return w;
  // }
  //
  // static double screenH(BuildContext ctx) {
  //   mq(ctx);
  //   return h;
  // }

  // static Size screenSize(BuildContext ctx) => MediaQuery.of(ctx).size;

  static bool isCloseToTopOrBottom(Offset position, Size screenSize) {
    return position.dy <= 88.0 || (screenSize.height - position.dy) <= 88.0;
  }

  static bool isOnTopHalfOfScreen(Offset position, Size screenSize) {
    return position.dy < (screenSize.height / 2.0);
  }

  static bool isOnLeftHalfOfScreen(Offset position, Size screenSize) {
    return position.dx < (screenSize.width / 2.0);
  }

//  static bool isCloseToTopOrBottom(BuildContext ctx, Offset position) {
//    return position.dy <= 88.0 || (screenH(ctx) - position.dy) <= 88.0;
//  }
//
//  static bool isOnTopHalfOfScreen(BuildContext ctx, Offset position) {
//    return position.dy < (screenH(ctx) / 2.0);
//  }
//
//  bool isOnLeftHalfOfScreen(BuildContext ctx, Offset position) {
//    return position.dx < (screenW(ctx) / 2.0);
//  }

// // Determine if we should use mobile layout or not. The
// // number 600 here is a common breakpoint for a typical
// // 7-inch tablet.
//   static bool usePhoneLayout(BuildContext theCtx) {
//     // The equivalent of the "smallestWidth" qualifier on Android.
//     var shortestSide = MediaQuery.of(theCtx).size.shortestSide;
//     return shortestSide < 600;
//   }

// static bool narrowWidth(BuildContext theCtx) {
//   var q = MediaQuery.of(theCtx);
//   var shortestSide = q.size.shortestSide;
//   return shortestSide < 600 && q.orientation == Orientation.portrait;
// }
//
// static bool shortHeight(BuildContext theCtx) {
//   var q = MediaQuery.of(theCtx);
//   var shortestSide = q.size.shortestSide;
//   return shortestSide < 600 && q.orientation == Orientation.landscape;
// }

// Determine if we should use mobile layout or not. The
// number 600 here is a common breakpoint for a typical
// 7-inch tablet.
//   static bool usePhoneLayout(BuildContext theCtx) {
//     // The equivalent of the "smallestWidth" qualifier on Android.
//     var shortestSide = MediaQuery.of(theCtx).size.shortestSide;
//     return shortestSide < 600;
//   }
//
//   static bool useTabletLayout(BuildContext theCtx) {
//     var shortestSide = MediaQuery.of(theCtx).size.shortestSide;
//     return !kIsWeb && shortestSide >= 600;
//   }
}
