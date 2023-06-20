import '../content_nodes.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'widgetspan_node.mapper.dart';

@MappableClass()
class WidgetSpanNode extends InlineSpanNode  with WidgetSpanNodeMappable {
  final Node child;

  WidgetSpanNode({
    required this.child,
  });

  @override
  List<String> sensibleParents() => const [
    TextSpanNode.FLUTTER_TYPE,
  ];

  @override
  String label() => FLUTTER_TYPE;

  static const String FLUTTER_TYPE = "WidgetSpan";
}
