// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CAPIModel _$CAPIModelFromJson(Map<String, dynamic> json) => CAPIModel(
      json['timestamp'] as int?,
      (json['targetMap'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, TargetConfig.fromJson(e as Map<String, dynamic>)),
      ),
      (json['imageTargetListMap'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map((e) => TargetConfig.fromJson(e as Map<String, dynamic>))
                .toList()),
      ),
    );

Map<String, dynamic> _$CAPIModelToJson(CAPIModel instance) => <String, dynamic>{
      'timestamp': instance.timestamp,
      'targetMap': instance.targetMap,
      'imageTargetListMap': instance.imageTargetListMap,
    };

TargetConfig _$TargetConfigFromJson(Map<String, dynamic> json) => TargetConfig(
      uid: json['uid'] as int,
      wName: json['wName'] as String,
      transformScale: (json['transformScale'] as num?)?.toDouble() ?? 1.0,
      transformTranslateX:
          (json['transformTranslateX'] as num?)?.toDouble() ?? 0.0,
      transformTranslateY:
          (json['transformTranslateY'] as num?)?.toDouble() ?? 0.0,
      recordedM4list: (json['recordedM4list'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      recordedScale: (json['recordedScale'] as num?)?.toDouble() ?? 1.0,
      recordedTranslatePCX:
          (json['recordedTranslatePCX'] as num?)?.toDouble() ?? 0.0,
      recordedTranslatePCY:
          (json['recordedTranslatePCY'] as num?)?.toDouble() ?? 0.0,
      radius: (json['radius'] as num?)?.toDouble() ?? 30,
      calloutDurationMs: json['calloutDurationMs'] as int? ?? 1500,
      calloutWidth: (json['calloutWidth'] as num?)?.toDouble() ?? 400,
      calloutHeight: (json['calloutHeight'] as num?)?.toDouble() ?? 85,
      calloutTopPc: (json['calloutTopPc'] as num?)?.toDouble(),
      calloutLeftPc: (json['calloutLeftPc'] as num?)?.toDouble(),
      btnLocalTopPc: (json['btnLocalTopPc'] as num?)?.toDouble(),
      btnLocalLeftPc: (json['btnLocalLeftPc'] as num?)?.toDouble(),
      showBtn: json['showBtn'] as bool? ?? true,
      calloutColorValue: json['calloutColorValue'] as int?,
      usingText: json['usingText'] as bool? ?? true,
      calloutImageUrl: json['calloutImageUrl'] as String?,
      calloutText: json['calloutText'] as String?,
      fontFamily: json['fontFamily'] as String? ?? "OpenSans",
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 24.0,
      fontWeightIndex: json['fontWeightIndex'] as int?,
      italic: json['italic'] as bool? ?? false,
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? 1.0,
      letterHeight: (json['letterHeight'] as num?)?.toDouble() ?? 1.0,
      textAlignment: json['textAlignment'] as String? ?? 'c',
      textColorValue: json['textColorValue'] as int?,
      arrowType: json['arrowType'] as int? ?? 1,
      animateArrow: json['animateArrow'] as bool? ?? false,
    )
      ..targetLocalPosLeftPc =
          (json['targetLocalPosLeftPc'] as num?)?.toDouble()
      ..targetLocalPosTopPc = (json['targetLocalPosTopPc'] as num?)?.toDouble();

Map<String, dynamic> _$TargetConfigToJson(TargetConfig instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'transformScale': instance.transformScale,
      'transformTranslateX': instance.transformTranslateX,
      'transformTranslateY': instance.transformTranslateY,
      'recordedM4list': instance.recordedM4list,
      'recordedScale': instance.recordedScale,
      'recordedTranslatePCX': instance.recordedTranslatePCX,
      'recordedTranslatePCY': instance.recordedTranslatePCY,
      'wName': instance.wName,
      'targetLocalPosLeftPc': instance.targetLocalPosLeftPc,
      'targetLocalPosTopPc': instance.targetLocalPosTopPc,
      'radius': instance.radius,
      'btnLocalTopPc': instance.btnLocalTopPc,
      'btnLocalLeftPc': instance.btnLocalLeftPc,
      'calloutTopPc': instance.calloutTopPc,
      'calloutLeftPc': instance.calloutLeftPc,
      'showBtn': instance.showBtn,
      'calloutWidth': instance.calloutWidth,
      'calloutHeight': instance.calloutHeight,
      'calloutDurationMs': instance.calloutDurationMs,
      'calloutColorValue': instance.calloutColorValue,
      'usingText': instance.usingText,
      'calloutImageUrl': instance.calloutImageUrl,
      'calloutText': instance.calloutText,
      'fontFamily': instance.fontFamily,
      'fontSize': instance.fontSize,
      'fontWeightIndex': instance.fontWeightIndex,
      'italic': instance.italic,
      'letterSpacing': instance.letterSpacing,
      'letterHeight': instance.letterHeight,
      'textColorValue': instance.textColorValue,
      'textAlignment': instance.textAlignment,
      'arrowType': instance.arrowType,
      'animateArrow': instance.animateArrow,
    };
