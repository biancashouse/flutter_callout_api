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
  //   required String wwName,
  //   required GlobalKey ivGK,
  //   required GlobalKey ivChildGK,
  // }) = InitTW;

  const factory CAPIEvent.suspend({
    required String wwName,
  }) = Suspend;

  const factory CAPIEvent.resume({
    required String wwName,
  }) = Resume;

  const factory CAPIEvent.copyToClipboard() = CopyToClipboard;

  const factory CAPIEvent.recordMatrix({
    required String wwName,
    required Matrix4 newMatrix,
  }) = RecordMatrix;

  const factory CAPIEvent.targetMoved({
    required TargetConfig tc,
    required Offset newGlobalPos,
  }) = TargetMoved;

  const factory CAPIEvent.btnMoved({
    required TargetConfig tc,
    required Offset newGlobalPos,
  }) = BtnMoved;

  const factory CAPIEvent.newTarget({
    required String wwName,
    required Offset newGlobalPos,
  }) = NewTarget;

  const factory CAPIEvent.deleteTarget({
    required TargetConfig tc,
  }) = DeleteTarget;

  const factory CAPIEvent.selectTarget({
    required TargetConfig tc,
  }) = SelectTarget;

  const factory CAPIEvent.clearSelection({
    required String wwName,
  }) = ClearSelection;

  // const factory CAPIEvent.measuredIV({
  //   required String wwName,
  //   required Rect ivRect,
  // }) = MeasuredIV;

  const factory CAPIEvent.overrideTargetGK({
    required String wwName,
    required int index,
    required GlobalKey gk,
  }) = OverrideTargetGK;

  const factory CAPIEvent.startPlaying({
    required String wwName,
    List<int>? playList,
  }) = StartPlaying;

  const factory CAPIEvent.playNext({
    required String wwName,
  }) = PlayNext;

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

  const factory CAPIEvent.changedOrder({
    required String wwName,
    required int oldIndex,
    required int newIndex,
  }) = ChangedOrder;
}
