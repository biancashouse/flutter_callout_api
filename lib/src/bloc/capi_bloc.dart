import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/model/target_config.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundpool/soundpool.dart';

import 'capi_event.dart';
import 'capi_state.dart';

class CAPIBloc extends Bloc<CAPIEvent, CAPIState> {
  CAPIBloc() : super(CAPIState()) {
    on<InitApp>((event, emit) => _initApp(event, emit));
    // on<InitTW>((event, emit) => _initTW(event, emit));
    on<SuspendAndCopyToJson>((event, emit) => _suspendAndCopyToJson(event, emit));
    on<Resume>((event, emit) => _resume(event, emit));
    on<CopyToClipboard>((event, emit) => _copyToClipboard(event, emit));
    on<RecordMatrix>((event, emit) => _recordMatrix(event, emit));
    on<TargetMoved>((event, emit) => _targetMoved(event, emit));
    on<BtnMoved>((event, emit) => _btnMoved(event, emit));
    // on<NewTargetManual>((event, emit) => _newTargetManual(event, emit));
    on<NewTargetAuto>((event, emit) => _newTargetAuto(event, emit));
    // on<ListViewRefreshed>((event, emit) => _listViewRefreshed(event, emit));
    on<DeleteTarget>((event, emit) => _deleteTarget(event, emit));
    on<SelectTarget>((event, emit) => _selectTarget(event, emit));
    on<HideTargetsDuringPlayExcept>((event, emit) => _hideTargetsExcept(event, emit));
    on<UnhideTargets>((event, emit) => _unhideTargets(event, emit));
    // on<ChangedOrder>((event, emit) => _changedOrder(event, emit));
    on<ClearSelection>((event, emit) => _clearSelection(event, emit));
    on<StartPlayingList>((event, emit) => _startPlayingList(event, emit));
    on<PlayNextInList>((event, emit) => _playNextInList(event, emit));
    on<ChangedCalloutPosition>((event, emit) => _changedCalloutPosition(event, emit));
    on<ChangedCalloutDuration>((event, emit) => _changedCalloutDuration(event, emit));
    on<ChangedCalloutTextAlign>((event, emit) => _changedCalloutTextAlign(event, emit));
    on<ChangedCalloutTextStyle>((event, emit) => _changedCalloutTextStyle(event, emit));
    on<ChangedTargetRadius>((event, emit) => _changedTargetRadius(event, emit));
    on<ChangedTransformScale>((event, emit) => _changedTransformScale(event, emit));
    on<ChangedHelpContentType>((event, emit) => _changedHelpContentType(event, emit));
  }

  static Soundpool? _soundpool;
  static int? _shutterSoundId;
  static int? _plopSoundId;
  static int? _whooshSoundId;
  static int? _errorSoundId;

  // lazy load
  static Future<void> possiblyLoadSounds(CAPIState capiState) async {
    if (_soundpool == null && capiState.initialValueJsonAssetPath != null) {
      await _readSoundFiles(capiState.initialValueJsonAssetPath!, capiState.localTestingFilePaths);
    }
  }

  Future<void> _initApp(InitApp event, emit) async {
    if (state.initialValueJsonAssetPath == null) {
      // json config source file asset
      late Map<String, TargetConfig>? targetMap;
      late Map<String, List<TargetConfig>>? imageTargetListMap;
      String configFileS = await rootBundle.loadString(event.initialValueJsonAssetPath, cache: false);
      CAPIModel model = CAPIModel.fromJson(json.decode(configFileS));
      int configFileTS = model.timestamp ?? 0;
      targetMap = _parseTargets(model);
      imageTargetListMap = _parseImageTargets(model);
      // check for local storage version having a later timestamp than the asset
      var dir = kIsWeb ? HydratedStorage.webStorageDirectory : await getTemporaryDirectory();
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: dir,
      );
      bool USE_LOCAL_STORAGE = false;
      String? localStorageConfigS = await HydratedBloc.storage.read("callout-api-config");
      if (USE_LOCAL_STORAGE && localStorageConfigS != null) {
        CAPIModel model = CAPIModel.fromJson(json.decode(localStorageConfigS));
        int localStorageConfigTS = model.timestamp ?? 0;
        if (localStorageConfigTS < configFileTS) {
          targetMap = _parseTargets(model);
          imageTargetListMap = _parseImageTargets(model);
        }
      }
      emit(
        state.copyWith(
          targetMap: targetMap,
          imageTargetListMap: imageTargetListMap,
          localTestingFilePaths: event.localTestingFilePaths,
        ),
      );
    }
  }

// Future<void> _initTW(InitTW event, emit) async {
//   Map<String, GlobalKey> newIVGKMap = {}..addAll(state.ivGKMap);
//   newIVGKMap[event.wName] = event.ivGK;
//   Map<String, GlobalKey> newIVChildGKMap = {}..addAll(state.ivChildGKMap);
//   newIVChildGKMap[event.wName] = event.ivChildGK;
//   emit(state.copyWith(
//     ivGKMap: newIVGKMap,
//     ivChildGKMap: newIVChildGKMap,
//   ));
// }

  Future<void> _suspendAndCopyToJson(SuspendAndCopyToJson event, emit) async {
    print("bloc _suspend (${event.wName})");
    Map<String, bool> newSuspendedMap = Map.of(state.suspendedMap);
    newSuspendedMap[event.wName] = true;

    // indicate copy to clipboard
    playWhooshSound();

    // update localstorage
    CAPIModel model = CAPIModel(DateTime.now().millisecondsSinceEpoch, state.targetMap, state.imageTargetListMap);
    String jsonS = jsonEncode(model.toJson());
    await HydratedBloc.storage.write('callout-api-config', jsonS);

    emit(state.copyWith(
      selectedTarget: null,
      suspendedMap: newSuspendedMap,
      timestamp: model.timestamp,
    ));
  }

  void _resume(event, emit) {
    Map<String, bool> newSuspendedMap = {};
    newSuspendedMap[event.wName] = false;
    emit(state.copyWith(
      suspendedMap: newSuspendedMap,
    ));
  }

// void _listViewRefreshed(event, emit) {
//   emit(state.copyWith(
//     force: state.force + 1,
//   ));
// }

  void _startPlayingList(StartPlayingList event, emit) {
    List<TargetConfig> newPlayList = [];
    if (event.playList == null) {
      if (state.aTargetIsSelected()) {
        newPlayList = [state.selectedTarget!];
      } else {
        newPlayList = List.of(state.imageTargetListMap[event.iwName]!);
      }
    } else {
      // playlist supplied as list ints
      newPlayList = event.playList!.map((i) => state.imageTargetListMap[event.iwName]![i]).toList();
    }
    emit(state.copyWith(
      playList: newPlayList,
    ));
  }

  void _playNextInList(PlayNextInList event, emit) {
    List<TargetConfig> newPlayList = [];
    if (state.playList.isNotEmpty) {
      newPlayList = state.playList.sublist(1);
      emit(state.copyWith(
        playList: newPlayList,
      ));
    }
  }

  Future<void> _copyToClipboard(event, emit) async {
    playWhooshSound();
    CAPIModel model = CAPIModel(DateTime.now().millisecondsSinceEpoch, state.targetMap, state.imageTargetListMap);
    await Clipboard.setData(ClipboardData(text: jsonEncode(model.toJson())));
  }

// update current scale, translate and selected target
  void _recordMatrix(RecordMatrix event, emit) {
    if (state.aTargetIsSelected()) {
      TargetConfig updatedTC = state.selectedTarget!;
      updatedTC.setRecordedMatrix(event.newMatrix);
      Map<String, List<TargetConfig>> newimageTargetListMap = _addOrUpdateimageTargetListMap(event.wName, updatedTC);
      emit(state.copyWith(
        imageTargetListMap: newimageTargetListMap,
        force: state.force + 1,
        // lastUpdatedTC: updatedTC,
      ));
    }
  }

// update current scale, translate and selected target
  void _targetMoved(TargetMoved event, emit) {
    TargetConfig updatedTC = event.tc;
    updatedTC.setTargetStackPosPc(event.newGlobalPos.translate(
      event.tc.getScale() * event.targetRadius,
      event.tc.getScale() * event.targetRadius,
    ));
    Map<String, List<TargetConfig>> newimageTargetListMap = _addOrUpdateimageTargetListMap(event.tc.wName, updatedTC);
    emit(state.copyWith(
      imageTargetListMap: newimageTargetListMap,
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
    Map<String, List<TargetConfig>> newimageTargetListMap = _addOrUpdateimageTargetListMap(event.tc.wName, updatedTC);
    emit(state.copyWith(
      imageTargetListMap: newimageTargetListMap,
      force: state.force + 1,
    ));
  }

  // void _newTargetManual(NewTargetManual event, emit) {
  //   TargetConfig newItem = TargetConfig(
  //     uid: Random().nextInt(100),
  //     twName: event.wName,
  //   );
  //   newItem.init(
  //     this,
  //     GlobalKey(debugLabel: "Target: ${1 + (state.imageTargetListMap[event.wName] ?? []).length}"),
  //     FocusNode(),
  //   );
  //   newItem.setRecordedMatrix(Matrix4.identity());
  //   newItem.setTargetStackPosPc(event.newGlobalPos);
  //   newItem.btnLocalLeftPc = newItem.targetLocalPosLeftPc;
  //   newItem.btnLocalTopPc = newItem.targetLocalPosTopPc;
  //   Map<String, List<TargetConfig>> newimageTargetListMap = _addOrUpdateimageTargetListMap(event.wName, newItem);
  //   // select new item
  //   int index = (newimageTargetListMap[event.wName] ?? []).indexOf(newItem);
  //   Map<String, int> newSelectionMap = Map.of(state.selectedTargetIndexMap);
  //   if (index > -1) {
  //     newSelectionMap[event.wName] = index;
  //   }
  //   emit(state.copyWith(
  //     imageTargetListMap: newimageTargetListMap,
  //     selectedTargetIndexMap: newSelectionMap,
  //     // lastUpdatedTC: newItem,
  //   ));
  // }

  void _newTargetAuto(NewTargetAuto event, emit) {
    TargetConfig newItem = TargetConfig(
      uid: Random().nextInt(100),
      wName: event.wName,
    );
    newItem.init(
      this,
      GlobalKey(debugLabel: "Target: ${1 + (state.imageTargetListMap[event.wName] ?? []).length}"),
      FocusNode(),
      FocusNode(),
    );
    newItem.setTargetStackPosPc(event.newGlobalPos);
    newItem.btnLocalLeftPc = newItem.targetLocalPosLeftPc;
    newItem.btnLocalTopPc = newItem.targetLocalPosTopPc;
    Map<String, List<TargetConfig>> newImageTargetListMap = _addOrUpdateimageTargetListMap(event.wName, newItem);
    emit(state.copyWith(
      imageTargetListMap: newImageTargetListMap,
      // selectedTarget: newItem,
      newestTarget: newItem,
    ));
  }

  void _deleteTarget(DeleteTarget event, emit) {
    List<TargetConfig> newList = List.of(state.imageTargetListMap[event.tc.wName] ?? []);
    try {
      TargetConfig oldTc = newList.firstWhere((theTc) => theTc.uid == event.tc.uid);
      int oldTcIndex = newList.indexOf(oldTc);
      newList.removeAt(oldTcIndex);
      Map<String, List<TargetConfig>> newimageTargetListMap = Map.of(state.imageTargetListMap);
      newimageTargetListMap[event.tc.wName] = newList;
      emit(state.copyWith(
        imageTargetListMap: newimageTargetListMap,
        selectedTarget: null,
      ));
    } catch (e) {
      print("\nUnable to remove tc !\n");
    }
  }

  Future<void> _selectTarget(SelectTarget event, emit) async {
    emit(state.copyWith(
      selectedTarget: event.tc,
    ));
  }

  Future<void> _hideTargetsExcept(HideTargetsDuringPlayExcept event, emit) async {
    emit(state.copyWith(
      hideTargetsWhilePlayingExcept: event.tc,
    ));
  }

  Future<void> _unhideTargets(event, emit) async {
    emit(state.copyWith(
      hideTargetsWhilePlayingExcept: null,
    ));
  }

  // void _changedOrder(ChangedOrder event, emit) {
  //   int newIndex = event.newIndex;
  //   if (event.oldIndex < newIndex) {
  //     newIndex -= 1;
  //   }
  //   List<TargetConfig> newTargetList = List.of(state.imageTargets(event.wName));
  //   final TargetConfig item = newTargetList.removeAt(event.oldIndex);
  //   newTargetList.insert(newIndex, item);
  //   Map<String, List<TargetConfig>> newTargetsMap = Map.of(state.imageTargetListMap);
  //   newTargetsMap[event.wName] = newTargetList;
  //   emit(state.copyWith(
  //     imageTargetListMap: newTargetsMap,
  //   ));
  // }

// void clearSelection({bool reshowAllTargets = true}) {
//   bloc.add(CAPIEvent.clearSelection());
//   if (aTargetIsSelected(widget.iwName)) {
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
    emit(state.copyWith(
      selectedTarget: null,
    ));
  }

// void _clearSelection(ClearSelection event, emit) {
//   if (state.aTargetIsSelected(widget.iwName)) {
//     TargetConfig newTC = state.selectedTarget!.clone();
//     Map<String, List<TargetConfig>> newimageTargetListMap = {}..addAll(state.imageTargetListMap);
//     newTC.setTargetLocalPosPc(
//       event.targetCalloutGlobalPos,
//       state.childMeasuredPositionMap[state.selectedTargetWrapperName]!,
//       state.childMeasuredSizeMap[state.selectedTargetWrapperName]!,
//     );
//     newimageTargetListMap[state.selectedTargetWrapperName]![state.selectedTargetIndex(widget.iwName)] = newTC;
//     emit(state.copyWith(
//       imageTargetListMap: newimageTargetListMap,
//       selectedTarget: null,
//     ));
//   }
// }

// void _playSelection(event, emit) {
//   emit(state.copyWith());
// }

  void _changedCalloutPosition(ChangedCalloutPosition event, emit) {
    TargetConfig tc = event.tc.clone();
    tc.calloutTopPc = event.newPos.dy / Useful.scrH;
    tc.calloutLeftPc = event.newPos.dx / Useful.scrW;
    Map<String, List<TargetConfig>> newimageTargetListMap = _addOrUpdateimageTargetListMap(tc.wName, tc);
    emit(state.copyWith(
      imageTargetListMap: newimageTargetListMap,
      selectedTarget: tc,
      force: state.force + 1,
    ));
  }

  void _changedCalloutDuration(ChangedCalloutDuration event, emit) {
    TargetConfig tc = event.tc.clone();
    tc.calloutDurationMs = event.newDurationMs;
    Map<String, List<TargetConfig>> newimageTargetListMap = _addOrUpdateimageTargetListMap(tc.wName, tc);
    emit(state.copyWith(
      imageTargetListMap: newimageTargetListMap,
      selectedTarget: tc,
      force: state.force + 1,
    ));
  }

  void _changedCalloutTextAlign(ChangedCalloutTextAlign event, emit) {
    TargetConfig tc = event.tc.clone();
    tc.setTextAlign(event.newTextAlign);
    Map<String, List<TargetConfig>> newimageTargetListMap = _addOrUpdateimageTargetListMap(tc.wName, tc);
    emit(state.copyWith(
      imageTargetListMap: newimageTargetListMap,
      selectedTarget: tc,
      force: state.force + 1,
    ));
  }

  void _changedCalloutTextStyle(ChangedCalloutTextStyle event, emit) {
    TargetConfig tc = event.tc.clone();
    tc.setTextStyle(event.newTextStyle);
    Map<String, List<TargetConfig>> newimageTargetListMap = _addOrUpdateimageTargetListMap(tc.wName, tc);
    emit(state.copyWith(
      imageTargetListMap: newimageTargetListMap,
      selectedTarget: tc,
      force: state.force + 1,
    ));
  }

  void _changedTargetRadius(ChangedTargetRadius event, emit) {
    TargetConfig tc = event.tc.clone();
    tc.radius = event.newRadius;
    Map<String, List<TargetConfig>> newimageTargetListMap = _addOrUpdateimageTargetListMap(tc.wName, tc);
    emit(state.copyWith(
      imageTargetListMap: newimageTargetListMap,
      selectedTarget: tc,
      force: state.force + 1,
    ));
  }

  void _changedTransformScale(ChangedTransformScale event, emit) {
    TargetConfig tc = event.tc.clone();
    tc.transformScale = event.newScale;
    Map<String, List<TargetConfig>> newimageTargetListMap = _addOrUpdateimageTargetListMap(tc.wName, tc);
    emit(state.copyWith(
      imageTargetListMap: newimageTargetListMap,
      selectedTarget: tc,
      force: state.force + 1,
    ));
  }

  void _changedHelpContentType(ChangedHelpContentType event, emit) {
    TargetConfig tc = event.tc.clone();
    tc.usingText = !event.useImage;
    Map<String, List<TargetConfig>> newimageTargetListMap = _addOrUpdateimageTargetListMap(tc.wName, tc);
    emit(state.copyWith(
      imageTargetListMap: newimageTargetListMap,
      selectedTarget: tc,
      force: state.force + 1,
    ));
  }

  void _kbdHChanged(event, emit) {
    emit(state.copyWith(
      force: state.force + 1,
    ));
  }

  // // emits new state containing the new measurement
  // void _measuredIV(MeasuredIV event, emit) {
  //   Map<String, Rect> newIVRectMap = {};
  //   newIVRectMap = Map.of(state.ivRectMap);
  //   newIVRectMap[event.wName] = event.ivRect;
  //   // if (state.ivRectMap[event.wName]?.size != event.ivRect.size) {
  //   emit(state.copyWith(
  //     ivRectMap: newIVRectMap,
  //   ));
  //   // }
  // }

  Map<String, List<TargetConfig>> _addOrUpdateimageTargetListMap(final String iwName, final TargetConfig tc) {
    // replace or append tc in copy of its list
    List<TargetConfig> newList = List.of(state.imageTargetListMap[iwName] ?? []);
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
    Map<String, List<TargetConfig>> newimageTargetListMap = Map.of(state.imageTargetListMap);
    newimageTargetListMap[iwName] = newList;
    return newimageTargetListMap;
  }

// void _refreshToolCallouts() {
//   // Callout.moveToByFeature(CAPI.BUTTONS_CALLOUT.feature(), buttonsCalloutInitialPos());
//   Callout? listViewCallout = Useful.om.findCallout(CAPI.TARGET_LISTVIEW_CALLOUT.feature());
//   Callout.moveToByFeature(
//       CAPI.TARGET_LISTVIEW_CALLOUT.feature(), targetListCalloutInitialPos(widget.child is Scaffold, listViewCallout?.calloutH ?? 200));
//   bool? b = tseGK.currentState?.minimise;
//   Callout.moveToByFeature(CAPI.STYLES_CALLOUT.feature(), stylesCalloutInitialPos(b ?? true));
// }

  Map<String, List<TargetConfig>> _parseImageTargets(CAPIModel model) {
    Map<String, List<TargetConfig>> imageTargetListMap = {};
    try {
      for (String iwName in model.imageTargetListMap?.keys ?? []) {
        List<TargetConfig>? targets = model.imageTargetListMap?[iwName];
        if (targets != null && targets.isNotEmpty) {
          for (int i = 0; i < targets.length; i++) {
            targets[i].init(
              this,
              GlobalKey(debugLabel: "target-$i"),
              FocusNode(),
              FocusNode(),
            );
          }
          // targets.sort((a, b) => a.calloutDurationMs.compareTo(b.calloutDurationMs));
          imageTargetListMap[iwName] = targets;
        }
      }
    } catch (e) {
      print("_parseImageTargets(): ${e.toString()}");
      rethrow;
    }
    return imageTargetListMap;
  }

  Map<String, TargetConfig> _parseTargets(CAPIModel model) {
    Map<String, TargetConfig> targetMap = {};
    try {
      for (String iwName in model.targetMap?.keys ?? []) {
        TargetConfig tc = model.targetMap![iwName]!;
        tc.init(
          this,
          GlobalKey(debugLabel: iwName),
          FocusNode(),
          FocusNode(),
        );
        targetMap[iwName] = tc;
      }
    } catch (e) {
      print("_parseImageTargets(): ${e.toString()}");
      rethrow;
    }
    return targetMap;
  }

  static Future<void> _readSoundFiles(final String path, final bool localTestingFilePaths) async {
    _soundpool = Soundpool.fromOptions(
        options: const SoundpoolOptions(
      streamType: StreamType.notification,
    ));
    var asset = await rootBundle.load(localTestingFilePaths
        ? "lib/src/sounds/178186__snapper4298__camera-click-nikon.wav"
        : "packages/flutter_callout_api/lib/src/sounds/178186__snapper4298__camera-click-nikon.wav");
    _shutterSoundId = await _soundpool?.load(asset);
    asset = await rootBundle.load(localTestingFilePaths
        ? "lib/src/sounds/447910__breviceps__plop.wav"
        : "packages/flutter_callout_api/lib/src/sounds/447910__breviceps__plop.wav");
    _plopSoundId = await _soundpool?.load(asset);
    asset = await rootBundle.load(localTestingFilePaths
        ? "lib/src/sounds/394415__inspectorj__bamboo-swing-a1.wav"
        : "packages/flutter_callout_api/lib/src/sounds/394415__inspectorj__bamboo-swing-a1.wav");
    _whooshSoundId = await _soundpool?.load(asset);
    asset = await rootBundle.load(localTestingFilePaths
        ? "lib/src/sounds/250048__kwahmah-02__sits6.wav"
        : "packages/flutter_callout_api/lib/src/sounds/250048__kwahmah-02__sits6.wav");
    _errorSoundId = await _soundpool?.load(asset);
  }

  Future<void> playShutterSound() async {
    await CAPIBloc.possiblyLoadSounds(state);
    if (_soundpool != null && _shutterSoundId != null) await _soundpool!.play(_shutterSoundId!);
  }

  Future<void> playPlopSound() async {
    await CAPIBloc.possiblyLoadSounds(state);
    if (_soundpool != null && _plopSoundId != null) await _soundpool!.play(_plopSoundId!);
  }

  Future<void> playWhooshSound() async {
    await CAPIBloc.possiblyLoadSounds(state);
    if (_soundpool != null && _whooshSoundId != null) await _soundpool!.play(_whooshSoundId!);
  }

  Future<void> playErrorSound(state) async {
    await CAPIBloc.possiblyLoadSounds(state);
    if (_soundpool != null && _errorSoundId != null) await _soundpool!.play(_errorSoundId!);
  }

  TargetConfig? selectedTC() => state.selectedTarget;

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
}
