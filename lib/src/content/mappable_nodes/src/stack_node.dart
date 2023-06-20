import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import '../content_nodes.dart';

part 'stack_node.mapper.dart';

@MappableClass()
class StackNode extends MultiChildNode with StackNodeMappable {
  StackNode({
    required super.children,
  });

  @override
  String label() => FLUTTER_TYPE;

  static const String FLUTTER_TYPE = "Stack";
}

@MappableEnum()
enum NodeAlignment {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight;

  Alignment toFlutterAlignment(NodeAlignment value) {
    return switch (value) {
      NodeAlignment.topLeft => Alignment.topLeft,
      NodeAlignment.topCenter => Alignment.topCenter,
      NodeAlignment.topRight => Alignment.topRight,
      NodeAlignment.centerLeft => Alignment.centerLeft,
      NodeAlignment.center => Alignment.center,
      NodeAlignment.centerRight => Alignment.centerRight,
      NodeAlignment.bottomLeft => Alignment.bottomLeft,
      NodeAlignment.bottomCenter => Alignment.bottomCenter,
      NodeAlignment.bottomRight => Alignment.bottomRight,
    };
  }
}
