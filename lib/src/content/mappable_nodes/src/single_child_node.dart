import 'package:dart_mappable/dart_mappable.dart';
import '../content_nodes.dart';

part 'single_child_node.mapper.dart';

const List<Type> SingleChildSubClasses = [
  SizedBoxNode,
  ContainerNode,
  CenterNode,
  ExpandedNode,
  FlexibleNode,
  PaddingNode,
  PositionedNode,
  AlignNode,
];

@MappableClass(discriminatorKey: 'singlechild', includeSubClasses: SingleChildSubClasses)
abstract class SingleChildNode extends Node with SingleChildNodeMappable {
  Node? child;

  SingleChildNode({this.child});
}
