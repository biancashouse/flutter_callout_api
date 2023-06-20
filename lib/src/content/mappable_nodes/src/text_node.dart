import 'package:dart_mappable/dart_mappable.dart';
import '../content_nodes.dart';

part 'text_node.mapper.dart';

@MappableClass()
class TextNode extends ChildlessNode with TextNodeMappable {
  String text;
  NodeTextStyle? textStyle;

  TextNode({
    required this.text,
    this.textStyle,
  });

  String label() => FLUTTER_TYPE;

  static const String FLUTTER_TYPE = "Text";
}

@MappableClass()
class NodeTextStyle with NodeTextStyleMappable {
  String? fontFamily;
  double? fontSize;
  int? colorValue;

  NodeTextStyle({
    this.fontFamily,
    this.fontSize,
    this.colorValue,
  });
}