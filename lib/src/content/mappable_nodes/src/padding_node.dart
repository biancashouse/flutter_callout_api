import 'package:dart_mappable/dart_mappable.dart';
import '../content_nodes.dart';

part 'padding_node.mapper.dart';

@MappableClass()
class PaddingNode extends SingleChildNode with PaddingNodeMappable {
  double padding;

  PaddingNode({
    this.padding = 8.0,
    super.child,
  });

  @override
  String label() => FLUTTER_TYPE;

  static const String FLUTTER_TYPE = "Padding";
}
