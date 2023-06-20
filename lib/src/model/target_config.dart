import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_state.dart';
import 'package:flutter_callout_api/src/overlays/callouts/arrow_type.dart';
import 'package:flutter_callout_api/src/useful.dart';
import 'package:flutter_callout_api/src/wrapper/app_wrapper.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:vector_math/vector_math_64.dart' as math;

part 'target_config.g.dart';

typedef SizeFunc = Size Function();

@JsonSerializable()
class CAPIModel {
  int? timestamp;
  Map<String, TargetConfig>? targetMap;
  Map<String, List<TargetConfig>>? imageTargetListMap;

  CAPIModel(this.timestamp, this.targetMap, this.imageTargetListMap);

  factory CAPIModel.fromJson(Map<String, dynamic> data) => _$CAPIModelFromJson(data);

  Map<String, dynamic> toJson() => _$CAPIModelToJson(this);
}

const List<String> textAlignments = ["l", "c", "r", "j"];

@JsonSerializable()
class TargetConfig {
  int uid;

  double transformScale;
  double transformTranslateX;
  double transformTranslateY;

  // only use this when target selected, or as play to value, otherwise use transient matrix
  List<double> recordedM4list; // see Matrix.storage, and Float32List.toList etc
  double? recordedScale;
  double? recordedTranslatePCX;
  double? recordedTranslatePCY;

  String wName;
  double? targetLocalPosLeftPc;
  double? targetLocalPosTopPc;
  double radius;
  double? btnLocalTopPc;
  double? btnLocalLeftPc;
  double? calloutTopPc;
  double? calloutLeftPc;
  bool showBtn;
  double calloutWidth;
  double calloutHeight;
  int calloutDurationMs;
  int? calloutColorValue;
  bool usingText;
  String? calloutImageUrl;
  String? calloutText;
  String fontFamily;
  double fontSize;
  int? fontWeightIndex;
  bool italic;
  double letterSpacing;
  double letterHeight;
  int? textColorValue;
  String textAlignment;
  int? arrowType;
  bool animateArrow;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late CAPIBloc _bloc;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late GlobalKey _gk;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late GlobalKey _overridingGK;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late FocusNode _textFocusNode;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late FocusNode _imageUrlFocusNode;
  // @JsonKey(includeFromJson: false, includeToJson: false)
  // late Alignment transformAlignment;

  // @JsonKey(includeFromJson: false, includeToJson: false)
  // late Matrix4 _transientMatrix;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Rect _rect = Rect.zero;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool visible = true;

  TargetConfig({
    required this.uid,
    required this.wName,
    this.transformScale = 1.0,
    this.transformTranslateX = 0.0,
    this.transformTranslateY = 0.0,
    this.recordedM4list = const [],
    this.recordedScale = 1.0,
    this.recordedTranslatePCX = 0.0,
    this.recordedTranslatePCY = 0.0,
    this.radius = 30,
    this.calloutDurationMs = 1500,
    this.calloutWidth = 400,
    this.calloutHeight = 85,
    this.calloutTopPc,
    this.calloutLeftPc,
    this.btnLocalTopPc, // initially shown directly over target
    this.btnLocalLeftPc,
    this.showBtn = true,
    this.calloutColorValue,
    this.usingText = true,
    this.calloutImageUrl,
    this.calloutText,
    this.fontFamily = "OpenSans",
    this.fontSize = 24.0,
    this.fontWeightIndex,
    this.italic = false,
    this.letterSpacing = 1.0,
    this.letterHeight = 1.0,
    this.textAlignment = 'c',
    this.textColorValue,
    this.arrowType = 1, // ArrowType.POINTY.index,
    this.animateArrow = false,
  }) {
    textColorValue ??= Colors.blue[900]!.value;
    calloutColorValue ??= Colors.grey.value;
    fontWeightIndex = FontWeight.normal.index;
  }

  // Rect getRect() => _rect;
  //
  // void setRect(Rect value) {
  //   _rect = value;
  // }

  void setRecordedMatrix(Matrix4 newMatrix) {
    recordedM4list = newMatrix.storage;

    math.Vector3 translation = math.Vector3.zero();
    math.Quaternion rotation = math.Quaternion.identity();
    math.Vector3 scale = math.Vector3.zero();
    Matrix4 m4 = newMatrix;
    m4.decompose(translation, rotation, scale);

    var oldScale = recordedScale;
    recordedScale = scale.r;
    print(scale.toString());
    if (oldScale != recordedScale) {
      print("scale changed: $oldScale => $recordedScale");
    }

    Size ivSize = CAPIState.iwSize(wName);
    var oldTranslatePCX = recordedTranslatePCX;
    var oldTranslatePCY = recordedTranslatePCY;
    recordedTranslatePCX = translation.x / ivSize.width;
    recordedTranslatePCY = translation.y / ivSize.height;

    if (oldTranslatePCX != recordedTranslatePCX || oldTranslatePCY != recordedTranslatePCY) {
      print("Translate changed: ($oldTranslatePCX, $oldTranslatePCY) => ($recordedTranslatePCX, $recordedTranslatePCY)");
    }

    // // see if compose from scale and translate % values works
    // math.Vector3 translate = math.Vector3(recordedTranslatePCX * ivSize.width, recordedTranslatePCY * ivSize.height, 0.0);
    // rotation = math.Quaternion.identity();
    // Matrix4 m5 = Matrix4.compose(translate, rotation, scale);
    //
    // // recordedM4List should match result
    // print("=========================================================");
    // print(m5.toString());
    // print("---------------------------------------------------------");
    // print(Matrix4.fromList(recordedM4list).toString());
    // print("=========================================================");
  }

  /// https://gist.github.com/pskink/aa0b0c80af9a986619845625c0e87a67
  Matrix4 composeMatrix({
    double scale = 1,
    double rotation = 0,
    double translateX = 0,
    double translateY = 0,
    double anchorX = 0,
    double anchorY = 0,
  }) {
    final double c = cos(rotation) * scale;
    final double s = sin(rotation) * scale;
    final double dx = translateX - c * anchorX + s * anchorY;
    final double dy = translateY - s * anchorX - c * anchorY;

    //  ..[0]  = c       # x scale
    //  ..[1]  = s       # y skew
    //  ..[4]  = -s      # x skew
    //  ..[5]  = c       # y scale
    //  ..[10] = 1       # diagonal "one"
    //  ..[12] = dx      # x translation
    //  ..[13] = dy      # y translation
    //  ..[15] = 1       # diagonal "one"
    return Matrix4(c, s, 0, 0, -s, c, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
  }

  Matrix4 getRecordedMatrix() {
    // if (recordedM4list.isEmpty) {
    //   return Matrix4.identity();
    // } else {
    Size ivSize = CAPIState.iwSize(wName);
    var translate = getTranslate();
    return composeMatrix(scale: getScale(), translateX: translate.dx, translateY: translate.dy);
    math.Vector3 translateV3 = math.Vector3(translate.dx, translate.dy, 0.0);
    math.Quaternion rotation = math.Quaternion.identity();
    Matrix4 m5 = Matrix4.compose(translateV3, rotation, math.Vector3(getScale(), getScale(), 1));

    // recordedM4List should match result
    print("=========================================================");
    print(m5.toString());
    print("---------------------------------------------------------");
    print(Matrix4.fromList(recordedM4list).toString());
    print("=========================================================");

    return m5;
    // return Matrix4.fromList(recordedM4list);
    // }
  }

  bool playingOrSelected() => _bloc.state.playList.isNotEmpty || (_bloc.state.aTargetIsSelected() && _bloc.state.selectedTarget!.uid == uid);

  double getScale({bool testing = false}) => playingOrSelected() || testing ? transformScale : 1.0;

  Offset getTranslate({bool testing = false}) {
    Size ivSize = CAPIState.iwSize(wName);
    Offset translate = playingOrSelected() || testing ? Offset(transformTranslateX * ivSize.width, transformTranslateY * ivSize.height) : Offset.zero;
    return translate;
  }

// double getRecordedMatrixScale() {
//   math.Vector3 translation = math.Vector3.zero();
//   math.Quaternion rotation = math.Quaternion.identity();
//   math.Vector3 scale = math.Vector3.zero();
//   getRecordedMatrix().decompose(translation, rotation, scale);
//   return scale.b;
// }
//
// Offset getRecordsMatrixTranslate() {
//   math.Vector3 translation = math.Vector3.zero();
//   math.Quaternion rotation = math.Quaternion.identity();
//   math.Vector3 scale = math.Vector3.zero();
//   getRecordedMatrix().decompose(translation, rotation, scale);
//   return Offset(translation.x, translation.y);
// }
//
// double getTransientScale() {
//   math.Vector3 translation = math.Vector3.zero();
//   math.Quaternion rotation = math.Quaternion.identity();
//   math.Vector3 scale = math.Vector3.zero();
//   getTransientMatrix4().decompose(translation, rotation, scale);
//   return scale.b;
// }
//
// Offset getTransientTranslate() {
//   math.Vector3 translation = math.Vector3.zero();
//   math.Quaternion rotation = math.Quaternion.identity();
//   math.Vector3 scale = math.Vector3.zero();
//   getTransientMatrix4().decompose(translation, rotation, scale);
//   return Offset(translation.x, translation.y);
// }

  String text() {
    return calloutText ?? "";
  }

  void setText(String newS) {
    calloutText = newS;
  }

  ArrowType getArrowType() {
    return ArrowType.values[arrowType ?? ArrowType.POINTY.index];
  }

  TextStyle textStyle() => TextStyle(
        color: textColor(),
        backgroundColor: calloutColor(),
        fontSize: fontSize,
        fontFamily: fontFamily,
        package: bloc.state.localTestingFilePaths ? null : 'callout_api',
        height: letterHeight,
        letterSpacing: letterSpacing,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        fontWeight: FontWeight.values[fontWeightIndex ?? FontWeight.normal.index],
      );

  CAPIBloc get bloc => _bloc;

  Color textColor() => textColorValue == null ? Colors.blue[900]! : Color(textColorValue!);

  FocusNode textFocusNode() => _textFocusNode;
  FocusNode imageUrlFocusNode() => _imageUrlFocusNode;

  TextAlign textAlign() {
    switch (textAlignment) {
      case 'r':
        return TextAlign.right;
      case 'c':
        return TextAlign.center;
      case 'j':
        return TextAlign.justify;
      case 'l':
        return TextAlign.left;
      default:
        return TextAlign.left;
    }
  }

  void setTextAlign(TextAlign newTA) {
    switch (newTA) {
      case TextAlign.left:
        textAlignment = 'l';
        break;
      case TextAlign.center:
        textAlignment = 'c';
        break;
      case TextAlign.right:
        textAlignment = 'r';
        break;
      case TextAlign.justify:
        textAlignment = 'j';
        break;
      case TextAlign.start:
        // TODO: Handle this case.
        break;
      case TextAlign.end:
        // TODO: Handle this case.
        break;
    }
  }

// fontSize: tc.fontSize,
// color: tc.textColor(),
// backgroundColor: tc.calloutColor(),
// fontFamily: tc.fontFamily,
// letterSpacing: tc.letterSpacing,
// height: tc.letterHeight,

  void setTextStyle(TextStyle newTS) {
    if (newTS.color != null) {
      textColorValue = newTS.color!.value;
    }
    if (newTS.backgroundColor != null) {
      calloutColorValue = newTS.backgroundColor!.value;
    }
    if (newTS.fontSize != null) {
      fontSize = newTS.fontSize!;
    }
    if (newTS.fontFamily != null) {
      fontFamily = newTS.fontFamily!;
    }
    if (newTS.letterSpacing != null) {
      letterSpacing = newTS.letterSpacing!;
    }
    if (newTS.height != null) {
      letterHeight = newTS.height!;
    }
    if (newTS.fontWeight != null) {
      fontWeightIndex = newTS.fontWeight!.index;
    }
    if (newTS.fontStyle != null) {
      italic = newTS.fontStyle == FontStyle.italic;
    }
  }

  Color calloutColor() => calloutColorValue == null ? Colors.white : Color(calloutColorValue!);

  Offset targetGlobalPos() {
    // iv rect should always be measured
    Offset ivTopLeft = CAPIState.iwPos(wName);
    Size ivSize = CAPIState.iwSize(wName);

    // calc from matrix
    double scale = getScale();
    Offset translate = getTranslate();

    double globalPosX = ivTopLeft.dx + translate.dx + ((targetLocalPosLeftPc ?? 0.0) * ivSize.width * scale);
    double globalPosY = ivTopLeft.dy + translate.dy + ((targetLocalPosTopPc ?? 0.0) * ivSize.height * scale);

    // in prod, target callout will be much smaller
    // if (bloc.state.isPlaying(iwName)) {
    //   globalPosX += bloc.state.CC_TARGET_SIZE_OUTER(!bloc.state.isPlaying(iwName), ivSize) * scale / 2 - bloc.state.CC_TARGET_SIZE(bloc.state.isPlaying(iwName), ivSize) * scale / 2;
    //   globalPosY += bloc.state.CC_TARGET_SIZE_OUTER(!bloc.state.isPlaying(iwName), ivSize) * scale / 2 - bloc.state.CC_TARGET_SIZE(bloc.state.isPlaying(iwName), ivSize) * scale / 2;
    // }
    return Offset(globalPosX, globalPosY);
  }

  Offset btnStackPos() {
    // iv rect should always be measured
    Size ivSize = CAPIState.iwSize(wName);

    double stackPosX = (btnLocalLeftPc ?? 0.0) * ivSize.width;
    double stackPosY = (btnLocalTopPc ?? 0.0) * ivSize.height;

    return Offset(stackPosX, stackPosY);
  }

  Offset targetStackPos() {
    // iv rect should always be measured
    Size ivSize = CAPIState.iwSize(wName);

    double stackPosX = (targetLocalPosLeftPc ?? 0.0) * ivSize.width;
    double stackPosY = (targetLocalPosTopPc ?? 0.0) * ivSize.height;

    return Offset(stackPosX, stackPosY);
  }

  void setTargetStackPosPc(Offset globalPos) {
    // iv rect should always be measured
    Offset ivTopLeft = CAPIState.iwPos(wName);
    Size ivSize = CAPIState.iwSize(wName);

    targetLocalPosTopPc = (globalPos.dy - ivTopLeft.dy) / (ivSize.height);
    targetLocalPosLeftPc = (globalPos.dx - ivTopLeft.dx) / (ivSize.width);
  }

  void setBtnStackPosPc(Offset globalPos) {
    // iv rect should always be measured
    Offset ivTopLeft = CAPIState.iwPos(wName);
    Size ivSize = CAPIState.iwSize(wName);

    btnLocalTopPc = (globalPos.dy - ivTopLeft.dy) / (ivSize.height);
    btnLocalLeftPc = (globalPos.dx - ivTopLeft.dx) / (ivSize.width);
  }

  Offset getTextCalloutPos() => Offset(
        Useful.scrW * (calloutLeftPc ?? .5),
        Useful.scrH * (calloutTopPc ?? .5),
      );

  // setTextCalloutPos(Offset newGlobalPos) {
  //   calloutTopPc = newGlobalPos.dy / Useful.scrH;
  //   calloutLeftPc = newGlobalPos.dx / Useful.scrW;
  // }

  void init(
    CAPIBloc bloc,
    GlobalKey gk,
    FocusNode textFocusNode,
    FocusNode imageUrlFocusNode,
  ) {
    _bloc = bloc;
    _gk = gk;
    _textFocusNode = textFocusNode;
    _imageUrlFocusNode = imageUrlFocusNode;
    // _transientMatrix = Matrix4.identity();
  }

  GlobalKey gk() => _gk;

  GlobalKey generateNewGK() => _gk = GlobalKey();

  factory TargetConfig.fromJson(Map<String, dynamic> data) => _$TargetConfigFromJson(data);

  // @override
  // String toString() {
  //   Matrix4 m4 = recordedM4list.isNotEmpty ? Matrix4.fromList(recordedM4list) : Matrix4.identity();
  //   return "${m4.toString()}";
  // }

  Map<String, dynamic> toJson() => _$TargetConfigToJson(this);

  @override
  bool operator ==(Object other) => other is TargetConfig && other.uid == uid;

  @override
  int get hashCode {
    return uid;
  }

  TargetConfig clone() {
    var cloneJson = this.toJson();
    TargetConfig clonedTC = TargetConfig.fromJson(cloneJson);
    clonedTC._bloc = this._bloc;
    clonedTC._gk = this._gk;
    clonedTC._textFocusNode = this._textFocusNode;
    clonedTC._imageUrlFocusNode = this._imageUrlFocusNode;
    // clonedTC._transientMatrix = this._transientMatrix;
    // clonedTC._rect = this._rect;
    return clonedTC;
  }
}
