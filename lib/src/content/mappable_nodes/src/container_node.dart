import 'package:dart_mappable/dart_mappable.dart';
import '../content_nodes.dart';

part 'container_node.mapper.dart';

@MappableClass()
class ContainerNode extends SingleChildNode with ContainerNodeMappable {
   int? colorValue;
   double? padding;
   double? width;
   double? height;


  ContainerNode({
    this.colorValue,
    this.padding,
    this.width,
    this.height,
    super.child,
  });

  @override
  String label() => FLUTTER_TYPE;

  static const String FLUTTER_TYPE = "Container";
}
