import 'package:dart_mappable/dart_mappable.dart';
import '../content_nodes.dart';

part 'multi_child_node.mapper.dart';

const List<Type> MultiChildSubClasses = [FlexNode, StackNode];

@MappableClass(discriminatorKey: 'multichild', includeSubClasses: MultiChildSubClasses)
abstract class MultiChildNode extends Node with MultiChildNodeMappable {
  List<Node> children;

  MultiChildNode({
    required this.children,
  });
}
