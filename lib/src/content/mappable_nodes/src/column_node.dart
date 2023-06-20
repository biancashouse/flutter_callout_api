import 'package:dart_mappable/dart_mappable.dart';
import '../content_nodes.dart';

part 'column_node.mapper.dart';

@MappableClass()
class ColumnNode extends FlexNode with ColumnNodeMappable {

  ColumnNode({
    super.mainAxisAlignment,
    super.mainAxisSize,
    required super.children,
  });

  @override
  String label() => FLUTTER_TYPE;

  static const String FLUTTER_TYPE = "Column";
}

// @MappableEnum()
// enum ContentTreeNodeType {
//   SizedBox,
//   Container,
//   Center,
//   Padding,
//   Card,
//   Text,
//   Flex,
//   Row,
//   Column,
//   Expanded,
//   Flexible,
//   Stack,
//   Positioned,
//   Align,
//   TextSpan,
//   WidgetSpan,
//   ADDER,
//   MOVER,
//   ROOT,
//   UNKNOWN;
//
//   bool isRoot() => this == ROOT;
//
//   bool noChildrenAllowed() => [Text, ADDER, MOVER].contains(this);
//
//   bool singleChildAllowed() => [
//     SizedBox,
//     Container,
//     Center,
//     Padding,
//     Card,
//     Positioned,
//     Align,
//     WidgetSpan,
//   ].contains(this);
//
//   bool canHaveChildren() => [
//     WidgetSpan,
//   ].contains(this);
//
//   bool mustHaveChildren() => [
//     Flex,
//     Row,
//     Column,
//     Stack,
//   ].contains(this);
//
//   int toJson() => index;
//
//   static ContentTreeNodeType fromJson(int value) => ContentTreeNodeType.values.elementAt(value);
// }
