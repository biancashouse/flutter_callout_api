import 'package:dart_mappable/dart_mappable.dart';
import '../content_nodes.dart';

part 'center_node.mapper.dart';

@MappableClass()
class CenterNode extends SingleChildNode with CenterNodeMappable {
  CenterNode({
    super.child,
  });

  @override
  String label() => FLUTTER_TYPE;

  static const String FLUTTER_TYPE = "Center";
}
