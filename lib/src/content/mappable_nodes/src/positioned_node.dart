import 'package:dart_mappable/dart_mappable.dart';
import '../content_nodes.dart';

part 'positioned_node.mapper.dart';

@MappableClass()
class PositionedNode extends SingleChildNode with PositionedNodeMappable {
  double? top;
  double? left;
  double? bottom;
  double? right;

  PositionedNode({
    this.top = 0.0,
    this.left = 0.0,
    this.bottom = 0.0,
    this.right = 0.0,
    super.child,
  });

  @override
  List<String> sensibleParents() => const [
        StackNode.FLUTTER_TYPE,
      ];

  @override
  String label() => FLUTTER_TYPE;
  static const String FLUTTER_TYPE = "Positioned";
}
