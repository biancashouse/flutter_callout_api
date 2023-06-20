import 'package:dart_mappable/dart_mappable.dart';
import '../content_nodes.dart';

part 'expanded_node.mapper.dart';

@MappableClass()
class ExpandedNode extends SingleChildNode with ExpandedNodeMappable  {
  int flex;

  ExpandedNode({
    this.flex = 1,
    super.child,
  });

  @override
  List<String> sensibleParents() => const [
        RowNode.FLUTTER_TYPE,
        ColumnNode.FLUTTER_TYPE,
      ];

  @override
  String label() => FLUTTER_TYPE;

  static const String FLUTTER_TYPE = "Expanded";
}
