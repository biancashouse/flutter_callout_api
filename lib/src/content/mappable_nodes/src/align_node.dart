import 'package:dart_mappable/dart_mappable.dart';
import '../content_nodes.dart';

part 'align_node.mapper.dart';

@MappableClass()
class AlignNode extends SingleChildNode with AlignNodeMappable {
  NodeAlignment alignment;

  AlignNode({
    required this.alignment,
    super.child,
  });

  @override
  String label() => FLUTTER_TYPE;

  static const String FLUTTER_TYPE = "Align";
}
