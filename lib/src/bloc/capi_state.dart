import 'package:callout_api/src/model/target_config.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'capi_state.freezed.dart';
// part 'cc_state.g.dart';

const Duration DEFAULT_TRANSITION_DURATION_MS = Duration(milliseconds: 500);
const Duration ms300 = Duration(milliseconds: 300);

@freezed
class CAPIState with _$CAPIState {
  const CAPIState._();

  // one per page, each having its own json data file
  // can have multiple (named) target wrappers, hence the maps
  factory CAPIState({
    @Default(false) bool localTestingFilePaths, // because filepaths and fonts accedd differently in own package
    @Default({}) Map<String, List<TargetConfig>> wtMap,
    @Default({}) Map<String, List<TargetConfig>> playListMap,
    @Default({}) Map<String, bool> suspendedMap,
    @Default({}) Map<String, int> selectedTargetIndexMap,
    // current selection
    TargetConfig? targetPlaying,
    // TargetConfig? lastUpdatedTC, // for debug only
    @Default(0) int force, // hacky way to force a transition
  }) = _CAPIState;

  bool isPlaying(String wwName) => playList(wwName).isNotEmpty;

  bool aTargetIsSelected(String wwName) => (selectedTargetIndexMap[wwName] ?? -1) > -1;

  bool isSuspended(String wwName) => suspendedMap[wwName] ?? true;

  String? resumedWW() {
    for (String key in suspendedMap.keys) {
      if (!(suspendedMap[key] ?? true)) return key;
    }
    return null;
  }

  List<TargetConfig> targets(String wwName) => wtMap.containsKey(wwName) ? wtMap[wwName] ?? [] : [];

  List<TargetConfig> playList(String wwName) => playListMap.containsKey(wwName) ? playListMap[wwName] ?? [] : [];

  TargetConfig? selectedTarget(String wwName) {
    int index = selectedTargetIndex(wwName);
    return (index > -1) ? wtMap[wwName]![index] : null;
  }

  TargetConfig? newestTarget(String wwName) {
    return targets(wwName).last;
  }

  int selectedTargetIndex(String wwName) => selectedTargetIndexMap.containsKey(wwName) ? selectedTargetIndexMap[wwName] ?? -1 : -1;

  int targetIndex(TargetConfig tc) => wtMap.containsKey(tc.wwName) ? wtMap[tc.wwName]!.indexOf(tc) : -1;

  TargetConfig? target(String wwName, int i) => wtMap.containsKey(wwName) ? wtMap[wwName]![i] : null;

  int numTargetsOnPage() {
    int numTCs = 0;
    for (List<TargetConfig> list in wtMap.values) {
      numTCs += list.length;
    }
    return numTCs;
  }

  double CAPI_TARGET_RADIUS(String wwName) => 40;
  final double CAPI_TARGET_BTN_RADIUS = 30.0;

  /// total duration is sum(target durations) + transition time for each
// int totalDurationMs() => (wtMap..map((t) => t.calloutDurationMs).reduce((a, b) => a + b)) + TRANSITION_DURATION_MS * (targets.length + 1);
}
