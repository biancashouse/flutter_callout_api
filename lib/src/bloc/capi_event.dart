import 'package:flutter_callout_api/src/model/target_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'capi_event.freezed.dart';

@freezed
class CAPIEvent with _$CAPIEvent {
  const factory CAPIEvent.initApp({
    required String initialValueJsonAssetPath,
    required bool localTestingFilePaths,
  }) = InitApp;

  // const factory CAPIEvent.initTW({
  //   required String iwName,
  //   required GlobalKey ivGK,
  //   required GlobalKey ivChildGK,
  // }) = InitTW;

  const factory CAPIEvent.suspendAndCopyToJson({
    required String wName,
  }) = SuspendAndCopyToJson;

  const factory CAPIEvent.resume({
    required String wName,
  }) = Resume;

  const factory CAPIEvent.copyToClipboard() = CopyToClipboard;

  const factory CAPIEvent.recordMatrix({
    required String wName,
    required Matrix4 newMatrix,
  }) = RecordMatrix;

  const factory CAPIEvent.targetMoved({
    required TargetConfig tc,
    required double targetRadius,
    required Offset newGlobalPos,
  }) = TargetMoved;

  const factory CAPIEvent.btnMoved({
    required TargetConfig tc,
    required Offset newGlobalPos,
  }) = BtnMoved;

  // const factory CAPIEvent.newTargetManual({
  //   required String iwName,
  //   required Offset newGlobalPos,
  // }) = NewTargetManual;

  const factory CAPIEvent.newTargetAuto({
    required String wName,
    required Offset newGlobalPos,
  }) = NewTargetAuto;

  const factory CAPIEvent.deleteTarget({
    required TargetConfig tc,
  }) = DeleteTarget;

  const factory CAPIEvent.selectTarget({
    required TargetConfig tc,
  }) = SelectTarget;

  const factory CAPIEvent.hideTargetsDuringPlayExcept({
    required TargetConfig tc,
}) = HideTargetsDuringPlayExcept;

  const factory CAPIEvent.unhideTargets(
) = UnhideTargets;

  const factory CAPIEvent.clearSelection({
    required String wName,
  }) = ClearSelection;

  // const factory CAPIEvent.measuredIV({
  //   required String iwName,
  //   required Rect ivRect,
  // }) = MeasuredIV;

  const factory CAPIEvent.overrideTargetGK({
    required String wName,
    required int index,
    required GlobalKey gk,
  }) = OverrideTargetGK;

  const factory CAPIEvent.startPlayingList({
    required String iwName,
    List<int>? playList,
  }) = StartPlayingList;

  const factory CAPIEvent.playNextInList({
    required String wName,
  }) = PlayNextInList;

  const factory CAPIEvent.changedCalloutPosition({
    required TargetConfig tc,
    required Offset newPos,
  }) = ChangedCalloutPosition;

  const factory CAPIEvent.changedCalloutDuration({
    required TargetConfig tc,
    required int newDurationMs,
  }) = ChangedCalloutDuration;

  const factory CAPIEvent.changedCalloutTextAlign({
    required TargetConfig tc,
    required TextAlign newTextAlign,
  }) = ChangedCalloutTextAlign;

  const factory CAPIEvent.changedCalloutTextStyle({
    required TargetConfig tc,
    required TextStyle newTextStyle,
  }) = ChangedCalloutTextStyle;

  const factory CAPIEvent.changedTargetRadius({
    required TargetConfig tc,
    required double newRadius,
  }) = ChangedTargetRadius;

  const factory CAPIEvent.changedTransformScale({
    required TargetConfig tc,
    required double newScale,
  }) = ChangedTransformScale;

  const factory CAPIEvent.changedHelpContentType({
    required TargetConfig tc,
    required bool useImage,
  }) = ChangedHelpContentType;

// const factory CAPIEvent.changedOrder({
  //   required String iwName,
  //   required int oldIndex,
  //   required int newIndex,
  // }) = ChangedOrder;
}
