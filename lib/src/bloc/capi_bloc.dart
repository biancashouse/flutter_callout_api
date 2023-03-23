import 'dart:convert';
import 'dart:math';

import 'package:flutter_callout_api/src/list/number_input.dart';
import 'package:flutter_callout_api/src/model/target_config.dart';
import 'package:flutter_callout_api/src/overlays/callouts/callout.dart';
import 'package:flutter_callout_api/src/useful.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundpool/soundpool.dart';

import 'capi_event.dart';
import 'capi_state.dart';

class CAPIBloc extends Bloc<CAPIEvent, CAPIState> {
  CAPIBloc() : super(CAPIState()) {
    on<InitApp>((event, emit) => _initApp(event, emit));
    // on<InitTW>((event, emit) => _initTW(event, emit));
    on<Suspend>((event, emit) => _suspend(event, emit));
    on<Resume>((event, emit) => _resume(event, emit));
    on<CopyToClipboard>((event, emit) => _copyToClipboard(event, emit));
    on<RecordMatrix>((event, emit) => _recordMatrix(event, emit));
    on<TargetMoved>((event, emit) => _targetMoved(event, emit));
    on<BtnMoved>((event, emit) => _btnMoved(event, emit));
    on<NewTarget>((event, emit) => _newTarget(event, emit));
    // on<ListViewRefreshed>((event, emit) => _listViewRefreshed(event, emit));
    on<DeleteTarget>((event, emit) => _deleteTarget(event, emit));
    on<SelectTarget>((event, emit) => _selectTarget(event, emit));
    on<ChangedOrder>((event, emit) => _changedOrder(event, emit));
    on<ClearSelection>((event, emit) => _clearSelection(event, emit));
    on<StartPlaying>((event, emit) => _startPlaying(event, emit));
    on<PlayNext>((event, emit) => _playNext(event, emit));
    on<ChangedCalloutDuration>((event, emit) => _changedCalloutDuration(event, emit));
    on<ChangedCalloutTextAlign>((event, emit) => _changedCalloutTextAlign(event, emit));
    on<ChangedCalloutTextStyle>((event, emit) => _changedCalloutTextStyle(event, emit));
  }

  static Soundpool? _soundpool;
  static int? _shutterSoundId;
  static int? _plopSoundId;
  static int? _whooshSoundId;
  static int? _errorSoundId;

  Future<void> _initApp(InitApp event, emit) async {
    if (_soundpool == null) {
      await _readSoundFiles(event.initialValueJsonAssetPath, event.localTestingFilePaths);
      Map<String, List<TargetConfig>> wtMap = await _readJsonFile(event.initialValueJsonAssetPath);
      emit(state.copyWith(
        wtMap: wtMap,
        localTestingFilePaths: event.localTestingFilePaths,
      ));
    }
  }

// Future<void> _initTW(InitTW event, emit) async {
//   Map<String, GlobalKey> newIVGKMap = {}..addAll(state.ivGKMap);
//   newIVGKMap[event.wwName] = event.ivGK;
//   Map<String, GlobalKey> newIVChildGKMap = {}..addAll(state.ivChildGKMap);
//   newIVChildGKMap[event.wwName] = event.ivChildGK;
//   emit(state.copyWith(
//     ivGKMap: newIVGKMap,
//     ivChildGKMap: newIVChildGKMap,
//   ));
// }

  void _suspend(Suspend event, emit) {
    print("bloc _suspend (${event.wwName})");
    Map<String, bool> newSuspendedMap = Map.of(state.suspendedMap);
    newSuspendedMap[event.wwName] = true;
    Map<String, int> newSelectionMap = Map.of(state.selectedTargetIndexMap);
    newSelectionMap[event.wwName] = -1;
    emit(state.copyWith(
      selectedTargetIndexMap: newSelectionMap,
      suspendedMap: newSuspendedMap,
    ));
  }

  void _resume(event, emit) {
    Map<String, bool> newSuspendedMap = {};
    newSuspendedMap[event.wwName] = false;
    emit(state.copyWith(
      suspendedMap: newSuspendedMap,
    ));
  }

// void _listViewRefreshed(event, emit) {
//   emit(state.copyWith(
//     force: state.force + 1,
//   ));
// }

  void _startPlaying(StartPlaying event, emit) {
    Map<String, List<TargetConfig>> newPlayListMap = {};
    if (event.playList == null) {
      if (state.aTargetIsSelected(event.wwName)) {
        newPlayListMap[event.wwName] = [state.selectedTarget(event.wwName)!];
      } else {
        newPlayListMap[event.wwName] = List.of(state.wtMap[event.wwName]!);
      }
    } else {
      // playlist supplied as list ints
      newPlayListMap[event.wwName] = event.playList!.map((i) => state.wtMap[event.wwName]![i]).toList();
    }
    emit(state.copyWith(
      playListMap: newPlayListMap,
    ));
  }

  void _playNext(PlayNext event, emit) {
    Map<String, List<TargetConfig>> newPlayListMap = {};
    if (state.playList(event.wwName).isNotEmpty) {
      newPlayListMap[event.wwName] = state.playList(event.wwName).sublist(1);
      emit(state.copyWith(
        playListMap: newPlayListMap,
      ));
    }
  }

  Future<void> _copyToClipboard(event, emit) async {
    playWhooshSound();
    CAPIModel model = CAPIModel(state.wtMap);
    await Clipboard.setData(ClipboardData(text: jsonEncode(model.toJson())));
  }

// update current scale, translate and selected target
  void _recordMatrix(RecordMatrix event, emit) {
    if (state.aTargetIsSelected(event.wwName)) {
      TargetConfig updatedTC = state.selectedTarget(event.wwName)!;
      updatedTC.setRecordedMatrix(event.newMatrix);
      Map<String, List<TargetConfig>> newwtMap = _addOrUpdatewtMap(event.wwName, updatedTC);
      emit(state.copyWith(
        wtMap: newwtMap,
        force: state.force + 1,
        // lastUpdatedTC: updatedTC,
      ));
    }
  }

// update current scale, translate and selected target
  void _targetMoved(TargetMoved event, emit) {
    TargetConfig updatedTC = event.tc;
    updatedTC.setTargetStackPosPc(event.newGlobalPos.translate(
      state.CAPI_TARGET_RADIUS(event.tc.wwName),
      state.CAPI_TARGET_RADIUS(event.tc.wwName),
    ));
    Map<String, List<TargetConfig>> newwtMap = _addOrUpdatewtMap(event.tc.wwName, updatedTC);
    emit(state.copyWith(
      wtMap: newwtMap,
      force: state.force + 1,
    ));
  }

// update current scale, translate and selected target
  void _btnMoved(BtnMoved event, emit) {
    TargetConfig updatedTC = event.tc;
    updatedTC.setBtnStackPosPc(event.newGlobalPos.translate(
      state.CAPI_TARGET_BTN_RADIUS,
      state.CAPI_TARGET_BTN_RADIUS,
    ));
    Map<String, List<TargetConfig>> newwtMap = _addOrUpdatewtMap(event.tc.wwName, updatedTC);
    emit(state.copyWith(
      wtMap: newwtMap,
      force: state.force + 1,
    ));
  }

  void _newTarget(NewTarget event, emit) {
    TargetConfig newItem = TargetConfig(
      uid: Random().nextInt(100),
      wwName: event.wwName,
    );
    newItem.init(
      this,
      GlobalKey(debugLabel: "Target: ${1 + (state.wtMap[event.wwName] ?? []).length}"),
      FocusNode(),
    );
    newItem.setRecordedMatrix(Matrix4.identity());
    newItem.setTargetStackPosPc(event.newGlobalPos);
    newItem.btnLocalLeftPc = newItem.targetLocalPosLeftPc;
    newItem.btnLocalTopPc = newItem.targetLocalPosTopPc;
    Map<String, List<TargetConfig>> newwtMap = _addOrUpdatewtMap(event.wwName, newItem);
    // select new item
    int index = (newwtMap[event.wwName] ?? []).indexOf(newItem);
    Map<String, int> newSelectionMap = Map.of(state.selectedTargetIndexMap);
    if (index > -1) {
      newSelectionMap[event.wwName] = index;
    }
    emit(state.copyWith(
      wtMap: newwtMap,
      selectedTargetIndexMap: newSelectionMap,
      // lastUpdatedTC: newItem,
    ));
  }

  void _deleteTarget(DeleteTarget event, emit) {
    List<TargetConfig> newList = List.of(state.wtMap[event.tc.wwName] ?? []);
    try {
      TargetConfig oldTc = newList.firstWhere((theTc) => theTc.uid == event.tc.uid);
      int oldTcIndex = newList.indexOf(oldTc);
      newList.removeAt(oldTcIndex);
      Map<String, List<TargetConfig>> newwtMap = Map.of(state.wtMap);
      newwtMap[event.tc.wwName] = newList;
      Map<String, int> newSelectionMap = Map.of(state.selectedTargetIndexMap);
      newSelectionMap[event.tc.wwName] = -1;
      emit(state.copyWith(
        wtMap: newwtMap,
        selectedTargetIndexMap: newSelectionMap,
      ));
    } catch (e) {
      print("\nUnable to remove tc !\n");
    }
  }

  Future<void> _selectTarget(SelectTarget event, emit) async {
    int index = (state.wtMap[event.tc.wwName] ?? []).indexOf(event.tc);
    if (index > -1) {
      Map<String, int> newSelectionMap = Map.of(state.selectedTargetIndexMap);
      newSelectionMap[event.tc.wwName] = index;
      emit(state.copyWith(
        selectedTargetIndexMap: newSelectionMap,
      ));
    }
  }

  void _changedOrder(ChangedOrder event, emit) {
    int newIndex = event.newIndex;
    if (event.oldIndex < newIndex) {
      newIndex -= 1;
    }
    List<TargetConfig> newTargetList = List.of(state.targets(event.wwName));
    final TargetConfig item = newTargetList.removeAt(event.oldIndex);
    newTargetList.insert(newIndex, item);
    Map<String, List<TargetConfig>> newTargetsMap = Map.of(state.wtMap);
    newTargetsMap[event.wwName] = newTargetList;
    emit(state.copyWith(
      wtMap: newTargetsMap,
    ));
  }

// void clearSelection({bool reshowAllTargets = true}) {
//   bloc.add(CAPIEvent.clearSelection());
//   if (aTargetIsSelected(widget.wwName)) {
//     transformationController.removeListener(_onChangeTransformation);
//     Useful.om.removeCalloutByFeature(CAPI.ANY_TOAST.feature(featureSeed), true);
//     targetListGK.currentState?.setState(() {
//       //measureIVchild();
//       Callout? targetCallout = Useful.om.findCallout(CAPI.TARGET_CALLOUT.feature((featureSeed), selectedTargetIndex));
//       if (targetCallout != null) {
//         selectedTarget!.setTargetLocalPosPc(Offset(targetCallout.left!, targetCallout.top!));
//         print("final callout pos (${targetCallout.left},${targetCallout.top})");
//         print("targetGlobalPos now: ${selectedTarget!.targetGlobalPos()}");
//       }
//       ivScale = 1.0;
//       ivTranslate = Offset.zero;
//       print("new child local pos (${selectedTarget!.childLocalPosLeftPc},${selectedTarget!.childLocalPosTopPc})");
//       // selectedTarget!.childLocalPosLeftPc = savedChildLocalPosPc!.dx;
//       // selectedTarget!.childLocalPosTopPc = savedChildLocalPosPc!.dy;
//       print("previous child local pos (${savedChildLocalPosPc!.dx},${savedChildLocalPosPc!.dy})");
//       int saveSelection = selectedTargetIndex;
//       selectedTargetIndex = -1;
//       transformationController.value = Matrix4.identity();
//       removeTextEditorCallout(this, selectedTargetIndex);
//       removeTargetCallout(this, saveSelection);
//     });
//   }
//   if (reshowAllTargets)
//     // show all targets unselected
//     Useful.afterMsDelayDo(500, () {
//       showAllTargets();
//       // for (var tc in targets) {
//       //   showDraggableTargetCallout(this, tc, onReadyF: () {});
//       // }
//     });
// }

  void _clearSelection(ClearSelection event, emit) {
    Map<String, int> newSelectionMap = Map.of(state.selectedTargetIndexMap);
    newSelectionMap.remove(event.wwName);
    emit(state.copyWith(
      selectedTargetIndexMap: newSelectionMap,
    ));
  }

// void _clearSelection(ClearSelection event, emit) {
//   if (state.aTargetIsSelected(widget.wwName)) {
//     TargetConfig newTC = state.selectedTarget!.clone();
//     Map<String, List<TargetConfig>> newwtMap = {}..addAll(state.wtMap);
//     newTC.setTargetLocalPosPc(
//       event.targetCalloutGlobalPos,
//       state.childMeasuredPositionMap[state.selectedTargetWrapperName]!,
//       state.childMeasuredSizeMap[state.selectedTargetWrapperName]!,
//     );
//     newwtMap[state.selectedTargetWrapperName]![state.selectedTargetIndex(widget.wwName)] = newTC;
//     emit(state.copyWith(
//       wtMap: newwtMap,
//       selectedTarget: null,
//     ));
//   }
// }

// void _playSelection(event, emit) {
//   emit(state.copyWith());
// }

  void _changedCalloutDuration(ChangedCalloutDuration event, emit) {
    emit(state.copyWith());
  }

  void _changedCalloutTextAlign(ChangedCalloutTextAlign event, emit) {
    emit(state.copyWith());
  }

  void _changedCalloutTextStyle(ChangedCalloutTextStyle event, emit) {
    emit(state.copyWith());
  }

  // // emits new state containing the new measurement
  // void _measuredIV(MeasuredIV event, emit) {
  //   Map<String, Rect> newIVRectMap = {};
  //   newIVRectMap = Map.of(state.ivRectMap);
  //   newIVRectMap[event.wwName] = event.ivRect;
  //   // if (state.ivRectMap[event.wwName]?.size != event.ivRect.size) {
  //   emit(state.copyWith(
  //     ivRectMap: newIVRectMap,
  //   ));
  //   // }
  // }

  Map<String, List<TargetConfig>> _addOrUpdatewtMap(final String wwName, final TargetConfig tc) {
    // replace or append tc in copy of its list
    List<TargetConfig> newList = List.of(state.wtMap[wwName] ?? []);
    try {
      TargetConfig oldTc = newList.firstWhere((theTc) => theTc.uid == tc.uid);
      int oldTcIndex = newList.indexOf(oldTc);
      if (oldTcIndex == -1) {
        newList.add(tc);
      } else {
        newList[oldTcIndex] = tc;
      }
    } catch (e) {
      newList.add(tc);
    }
    // replace the list containing the tc
    Map<String, List<TargetConfig>> newwtMap = Map.of(state.wtMap);
    newwtMap[wwName] = newList;
    return newwtMap;
  }

// void _refreshToolCallouts() {
//   // Callout.moveToByFeature(CAPI.BUTTONS_CALLOUT.feature(), buttonsCalloutInitialPos());
//   Callout? listViewCallout = Useful.om.findCallout(CAPI.TARGET_LISTVIEW_CALLOUT.feature());
//   Callout.moveToByFeature(
//       CAPI.TARGET_LISTVIEW_CALLOUT.feature(), targetListCalloutInitialPos(widget.child is Scaffold, listViewCallout?.calloutH ?? 200));
//   bool? b = tseGK.currentState?.minimise;
//   Callout.moveToByFeature(CAPI.STYLES_CALLOUT.feature(), stylesCalloutInitialPos(b ?? true));
// }

  Future<Map<String, List<TargetConfig>>> _readJsonFile(final String path) async {
    Map<String, List<TargetConfig>> wtMap = {};
    try {
      String jsonS = await rootBundle.loadString(path);
      Map<String, dynamic> data = await json.decode(jsonS);
      CAPIModel ccModel = CAPIModel.fromJson(data);
      for (String wwName in ccModel.wtMap?.keys ?? []) {
        List<TargetConfig>? targets = ccModel.wtMap?[wwName];
        if (targets != null && targets.isNotEmpty) {
          for (int i = 0; i < targets.length; i++) {
            targets[i].init(
              this,
              GlobalKey(debugLabel: "target-$i"),
              FocusNode(),
            );
          }
          // targets.sort((a, b) => a.calloutDurationMs.compareTo(b.calloutDurationMs));
          wtMap[wwName] = targets;
        }
      }
    } catch (e) {
      print("${path} not found (have you updated pubspec?)");
      rethrow;
    }
    return wtMap;
  }

  Future<void> _readSoundFiles(final String path, final bool localTestingFilePaths) async {
    _soundpool = Soundpool.fromOptions(
        options: const SoundpoolOptions(
      streamType: StreamType.notification,
    ));
    var asset = await rootBundle.load(localTestingFilePaths
        ? "lib/src/sounds/178186__snapper4298__camera-click-nikon.wav"
        : "packages/callout_api/lib/src/sounds/178186__snapper4298__camera-click-nikon.wav");
    _shutterSoundId = await _soundpool?.load(asset);
    asset = await rootBundle.load(
        localTestingFilePaths ? "lib/src/sounds/447910__breviceps__plop.wav" : "packages/callout_api/lib/src/sounds/447910__breviceps__plop.wav");
    _plopSoundId = await _soundpool?.load(asset);
    asset = await rootBundle.load(localTestingFilePaths
        ? "lib/src/sounds/394415__inspectorj__bamboo-swing-a1.wav"
        : "packages/callout_api/lib/src/sounds/394415__inspectorj__bamboo-swing-a1.wav");
    _whooshSoundId = await _soundpool?.load(asset);
    asset = await rootBundle.load(
        localTestingFilePaths ? "lib/src/sounds/250048__kwahmah-02__sits6.wav" : "packages/callout_api/lib/src/sounds/250048__kwahmah-02__sits6.wav");
    _errorSoundId = await _soundpool?.load(asset);
  }

  Future<void> playShutterSound() async {
    if (_soundpool != null && _shutterSoundId != null) await _soundpool!.play(_shutterSoundId!);
  }

  Future<void> playPlopSound() async {
    if (_soundpool != null && _plopSoundId != null) await _soundpool!.play(_plopSoundId!);
  }

  Future<void> playWhooshSound() async {
    if (_soundpool != null && _whooshSoundId != null) await _soundpool!.play(_whooshSoundId!);
  }

  Future<void> playErrorSound() async {
    if (_soundpool != null && _errorSoundId != null) await _soundpool!.play(_errorSoundId!);
  }

// static Offset m4ToTranslation(Matrix4 m) {
//   math.Vector3 translation = math.Vector3.zero();
//   math.Quaternion rotation = math.Quaternion.identity();
//   math.Vector3 scale = math.Vector3.zero();
//   m.decompose(translation, rotation, scale);
//   return Offset(translation.x, translation.y);
// }
//
// static double m4ToScale(Matrix4 m) {
//   math.Vector3 translation = math.Vector3.zero();
//   math.Quaternion rotation = math.Quaternion.identity();
//   math.Vector3 scale = math.Vector3.zero();
//   m.decompose(translation, rotation, scale);
//   return scale.b;
// }

  static Future<void> showStartTimeCallout(final TargetConfig tc) async {
    TextEditingController teC = TextEditingController()..text = tc.calloutDurationMs.toString();
    Callout startTimeEditorCallout = Callout(
      feature: CAPI.START_TIME_CALLOUT.feature(),
      focusNode: tc.focusNode(),
      targetGKF: () => tc.gk(),
      contents: () => NumberInput(
          icon: const Icon(
            Icons.timer,
            size: 32,
          ),
          label: "show callout for (ms)",
          controller: teC,
          focusNode: tc.focusNode(),
          onChanged: (s) {
            tc.calloutDurationMs = int.parse(s);
// tc.bloc.state.wtMap[tc.wwName]?.sort((a, b) => a.calloutDurationMs.compareTo(b.calloutDurationMs));
          },
          onClosed: () {
            Useful.om.remove(CAPI.START_TIME_CALLOUT.feature(), true);
          }),
      barrierOpacity: 0.0,
// arrowThickness: ArrowThickness.THIN,
      arrowColor: Colors.red,
      separation: 50,
// skipArrow: separation == null,
      modal: false,
      widthF: () => 400,
      heightF: () => 80,
      minHeight: 50,
      containsTextField: true,
      draggable: true,
      color: Colors.white,
    );

    await startTimeEditorCallout.show(
      notUsingHydratedStorage: true,
    );
  }
}
