import 'package:dart_mappable/dart_mappable.dart';
import '../content_nodes.dart';

part 'flex_node.mapper.dart';

@MappableClass(discriminatorKey: 'flex', includeSubClasses: [RowNode, ColumnNode])
abstract class FlexNode extends MultiChildNode with FlexNodeMappable {
  NodeMainAxisAlignment? mainAxisAlignment;
  NodeMainAxisSize? mainAxisSize;

  FlexNode({
    this.mainAxisAlignment,
    this.mainAxisSize,
    required super.children,
  });
}

// ignore: constant_identifier_names
@MappableEnum()
enum NodeAxis {
  h,
  v;
}

// ignore: constant_identifier_names
@MappableEnum()
enum NodeMainAxisAlignment {
  start,
  end,
  center,
  space_between,
  space_around,
  space_evenly;
}

// ignore: constant_identifier_names
@MappableEnum()
enum NodeMainAxisSize {
  min,
  max;
}

