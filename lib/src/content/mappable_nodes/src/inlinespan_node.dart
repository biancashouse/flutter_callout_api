import 'package:dart_mappable/dart_mappable.dart';
import '../content_nodes.dart';

part 'inlinespan_node.mapper.dart';

@MappableClass(discriminatorKey: 'span', includeSubClasses: [TextSpanNode,WidgetSpanNode])
abstract class InlineSpanNode extends Node with InlineSpanNodeMappable {
  InlineSpanNode();
}
