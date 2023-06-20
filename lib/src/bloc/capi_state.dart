import 'package:flutter/widgets.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/model/target_config.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'capi_state.freezed.dart';
// part 'cc_state.g.dart';

const Duration DEFAULT_TRANSITION_DURATION_MS = Duration(milliseconds: 500);
const Duration ms300 = Duration(milliseconds: 300);

@freezed
class CAPIState with _$CAPIState {
  const CAPIState._();

  /// the following static are actuall all UI-related and span all blocs...
  // can have multiple transformable widgets and preferredSize widgets under the MaterialApp
  // want new sizes to be available immediately after changing, hence not part of bloc, but static (global) instead
  // keys are wrapper name (WidgetWrapper or ImageWrapper)
  static Map<String, GlobalKey> gkMap = {};
  static Map<String, Offset> iwPosMap = {};
  static Map<String, Size> iwSizeMap = {};

  static GlobalKey? gk(String name) => gkMap[name];

  static Size iwSize(String wName) => iwSizeMap[wName] ?? Size.zero;

  static Offset iwPos(String wName) => iwPosMap[wName] ?? Offset.zero;

  static Rect wwRect(String wName) => Rect.fromLTWH(
        iwPos(wName).dx,
        iwPos(wName).dy,
        iwSize(wName).width,
        iwSize(wName).height,
      );

  static List<ScrollController> registeredScrollControllers = [];

  // one per page, each having its own json data file
  // can have multiple (named) target wrappers, hence the maps
  factory CAPIState({
    @Default(false) bool localTestingFilePaths, // because filepaths and fonts accedd differently in own package
    String? initialValueJsonAssetPath, // both come from MaterialAppWrapper widget constructor
    int? timestamp,
    @Default({}) Map<String, TargetConfig> targetMap,
    @Default({}) Map<String, List<TargetConfig>> imageTargetListMap,
    @Default([]) List<TargetConfig> playList,
    @Default({}) Map<String, bool> suspendedMap,
    // current selection
    TargetConfig? hideTargetsWhilePlayingExcept,
    TargetConfig? newestTarget,
    TargetConfig? selectedTarget,
    @Default(0) int force, // hacky way to force a transition
  }) = _CAPIState;

  bool aTargetIsSelected() => selectedTarget != null;

  bool isSuspended(String iwName) => suspendedMap[iwName] ?? true;

  String? resumedWW() {
    for (String key in suspendedMap.keys) {
      if (!(suspendedMap[key] ?? true)) return key;
    }
    return null;
  }

  List<TargetConfig> imageTargets(String iwName) => imageTargetListMap.containsKey(iwName) ? imageTargetListMap[iwName] ?? [] : [];

  TargetConfig? getNewestTarget() => newestTarget;

  int targetIndex(TargetConfig tc) => imageTargetListMap.containsKey(tc.wName) ? imageTargetListMap[tc.wName]!.indexOf(tc) : -1;

  TargetConfig? target(String iwName, int i) => imageTargetListMap.containsKey(iwName) ? imageTargetListMap[iwName]![i] : null;

  int numTargetsOnPage() {
    int numTCs = 0;
    for (List<TargetConfig> list in imageTargetListMap.values) {
      numTCs += list.length;
    }
    return numTCs;
  }

  //avoids listening to the same scrollcontroller more than once for the purpose of refreshing the overlays
  static void registerScrollController(ScrollController sController) {
    if (!registeredScrollControllers.contains(sController)) {
      sController.addListener(() => Useful.om.overlaySetState());
    }
  }

  final double CAPI_TARGET_BTN_RADIUS = 30.0;

  /// total duration is sum(target durations) + transition time for each
// int totalDurationMs() => (imageTargetListMap..map((t) => t.calloutDurationMs).reduce((a, b) => a + b)) + TRANSITION_DURATION_MS * (targets.length + 1);
}
