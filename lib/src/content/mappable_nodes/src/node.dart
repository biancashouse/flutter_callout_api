import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_callout_api/src/content/mappable_nodes/content_nodes.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

part 'node.mapper.dart';

@MappableClass(discriminatorKey: 'type', includeSubClasses: [ChildlessNode, SingleChildNode, MultiChildNode, InlineSpanNode])
abstract class Node extends HasKey with NodeMappable {
  List<String> flutterTypes() => const [
        CenterNode.FLUTTER_TYPE,
        PaddingNode.FLUTTER_TYPE,
        ExpandedNode.FLUTTER_TYPE,
        SizedBoxNode.FLUTTER_TYPE,
        ContainerNode.FLUTTER_TYPE,
        SizedBoxNode.FLUTTER_TYPE,
        TextNode.FLUTTER_TYPE,
        RowNode.FLUTTER_TYPE,
        ColumnNode.FLUTTER_TYPE,
        StackNode.FLUTTER_TYPE,
        TextSpanNode.FLUTTER_TYPE,
        WidgetSpanNode.FLUTTER_TYPE,
        PositionedNode.FLUTTER_TYPE,
        AlignNode.FLUTTER_TYPE
      ];

  List<String> sensibleParents() => const [];

  String label();
}

/// Exception when an encoded enum value has no match.
class EnumException implements Exception {
  String cause;

  EnumException(this.cause);
}
