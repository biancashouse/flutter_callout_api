import 'package:dart_mappable/dart_mappable.dart';
import '../content_nodes.dart';

part 'childless_node.mapper.dart';

@MappableClass(discriminatorKey: 'childless', includeSubClasses: [TextNode])
abstract class ChildlessNode extends Node with ChildlessNodeMappable {
  ChildlessNode();
}
