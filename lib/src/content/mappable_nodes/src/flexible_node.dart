import 'package:dart_mappable/dart_mappable.dart';
import '../content_nodes.dart';

part 'flexible_node.mapper.dart';

@MappableClass()

class FlexibleNode extends SingleChildNode with FlexibleNodeMappable {
  int flex;
  NodeFlexFit flexFit;

  FlexibleNode({
    this.flex = 1,
    this.flexFit = NodeFlexFit.loose,
    super.child,
  });

  @override
  List<String> sensibleParents() => const [
        RowNode.FLUTTER_TYPE,
        ColumnNode.FLUTTER_TYPE,
      ];

  @override
  String label() => FLUTTER_TYPE;

  static const String FLUTTER_TYPE = "Flexible";
}

@MappableEnum()
enum NodeFlexFit {
  tight,
  loose;
}
