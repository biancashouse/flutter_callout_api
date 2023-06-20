import 'package:dart_mappable/dart_mappable.dart';
import '../content_nodes.dart';

part 'row_node.mapper.dart';

@MappableClass()
class RowNode extends FlexNode with RowNodeMappable {

  RowNode({
    super.mainAxisAlignment,
    super.mainAxisSize,
    required super.children,
  });

  @override
  String label() => FLUTTER_TYPE;

  static const String FLUTTER_TYPE = "Row";
}
