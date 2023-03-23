// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'titem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransformPlayerRecorder _$TransformPlayerRecorderFromJson(
        Map<String, dynamic> json) =>
    TransformPlayerRecorder(
      name: json['name'] as String?,
      imageAssetPath: json['imageAssetPath'] as String,
      transforms: (json['transforms'] as List<dynamic>)
          .map((e) => TransformItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TransformPlayerRecorderToJson(
        TransformPlayerRecorder instance) =>
    <String, dynamic>{
      'name': instance.name,
      'imageAssetPath': instance.imageAssetPath,
      'transforms': instance.transforms,
    };

TransformItem _$TransformItemFromJson(Map<String, dynamic> json) =>
    TransformItem(
      name: json['name'] as String?,
      matrix: (json['matrix'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      top: (json['top'] as num?)?.toDouble() ?? 0.0,
      left: (json['left'] as num?)?.toDouble() ?? 0.0,
      startAtMs: json['startAtMs'] as int,
      callouts: (json['callouts'] as List<dynamic>?)
              ?.map((e) => CalloutConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TransformItemToJson(TransformItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'matrix': instance.matrix,
      'scale': instance.scale,
      'top': instance.top,
      'left': instance.left,
      'startAtMs': instance.startAtMs,
      'callouts': instance.callouts,
    };

CalloutConfig _$CalloutConfigFromJson(Map<String, dynamic> json) =>
    CalloutConfig(
      text: json['text'] as String,
      top: (json['top'] as num).toDouble(),
      left: (json['left'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      colorValue: json['colorValue'] as int,
      paddingAll: json['paddingAll'] as int,
    );

Map<String, dynamic> _$CalloutConfigToJson(CalloutConfig instance) =>
    <String, dynamic>{
      'text': instance.text,
      'top': instance.top,
      'left': instance.left,
      'width': instance.width,
      'height': instance.height,
      'colorValue': instance.colorValue,
      'paddingAll': instance.paddingAll,
    };
