import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'titem.g.dart';

@JsonSerializable()
class TransformPlayerRecorder {
  final String? name;
  final String imageAssetPath;
  final List<TransformItem> transforms;

  TransformPlayerRecorder({
    this.name,
    required this.imageAssetPath,
    required this.transforms,
  });

  factory TransformPlayerRecorder.fromJson(Map<String, dynamic> data) => _$TransformPlayerRecorderFromJson(data);

  Map<String, dynamic> toJson() => _$TransformPlayerRecorderToJson(this);

  @override
  bool operator ==(Object other) => other is TransformPlayerRecorder && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

@JsonSerializable()
class TransformItem {
  final String? name;
  final List<double> matrix; // see Matrix.storage, and Float32List.toList etc
  double scale;
  double top;
  double left;
  final int startAtMs;
  final List<CalloutConfig> callouts;

  TransformItem({
    this.name,
    this.matrix = const [],
    this.scale = 1.0,
    this.top = 0.0,
    this.left = 0.0,
    required this.startAtMs,
    this.callouts = const [],
  });

  factory TransformItem.fromJson(Map<String, dynamic> data) => _$TransformItemFromJson(data);

  @override
  String toString() {
    Matrix4 m4 = Matrix4.fromList(matrix);
    return "${name ?? ''}\n\n${m4.toString()}\nms:$startAtMs";
  }

  Map<String, dynamic> toJson() => _$TransformItemToJson(this);

  @override
  bool operator ==(Object other) => other is TransformItem && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

@JsonSerializable()
class CalloutConfig {
  final String text;
  final double top;
  final double left;
  final double width;
  final double height;
  final int colorValue;
  final int paddingAll;

  CalloutConfig({
    required this.text,
    required this.top,
    required this.left,
    required this.width,
    required this.height,
    required this.colorValue,
    required this.paddingAll,
  });

  factory CalloutConfig.fromJson(Map<String, dynamic> data) => _$CalloutConfigFromJson(data);

  Map<String, dynamic> toJson() => _$CalloutConfigToJson(this);

  @override
  bool operator ==(Object other) => other is CalloutConfig && other.text == text && other.colorValue == colorValue;

  @override
  int get hashCode => text.hashCode;
}
