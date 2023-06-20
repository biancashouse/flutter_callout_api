import 'package:dart_mappable/dart_mappable.dart';
import '../content_nodes.dart';

part 'textspan_node.mapper.dart';

@MappableClass()
class TextSpanNode extends InlineSpanNode with TextSpanNodeMappable {
  String? text;
  NodeTextStyle? textStyle;
  List<InlineSpanNode>? children;

  TextSpanNode({
    this.text,
    this.textStyle,
    this.children,
  });

  @override
  String label() => FLUTTER_TYPE;

  static const String FLUTTER_TYPE = "TextSpan";
}
