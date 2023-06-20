import 'package:dart_mappable/dart_mappable.dart';
import '../content_nodes.dart';

part 'sizedbox_node.mapper.dart';

@MappableClass()
class SizedBoxNode extends SingleChildNode with SizedBoxNodeMappable {
  double? width;
  double? height;

  SizedBoxNode({
    this.width,
    this.height,
    super.child,
  });

  @override
  String label() => FLUTTER_TYPE;

  static const String FLUTTER_TYPE = "SizedBox";
}
