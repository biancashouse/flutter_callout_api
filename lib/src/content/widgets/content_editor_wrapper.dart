import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_event.dart';
import 'package:flutter_callout_api/src/content/bloc/node_editor_bloc.dart';
import 'package:flutter_callout_api/src/content/mappable_nodes/content_nodes.dart';
import 'package:flutter_callout_api/src/content/widgets/node_widget.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '../content_editor_main.dart';

typedef ContentEditorFunc = MaterialApp Function(TreeController<Node> treeC);

// sample content data
List<Node> roots = [
  // root 1
  ContainerNode(
    colorValue: Colors.red.value,
    child: ColumnNode(
      mainAxisSize: NodeMainAxisSize.max,
      mainAxisAlignment: NodeMainAxisAlignment.space_around,
      children: [
        CenterNode(
          child: ContainerNode(
            colorValue: Colors.red.value,
            child: PositionedNode(
              child: RowNode(
                children: [
                  TextNode(text: "Spank"),
                  TextNode(text: "Monkey"),
                ],
              ),
            ),
          ),
        ),
        CenterNode(
          child: SizedBoxNode(),
        )
      ],
    ),
  ),

  // root 2
  StackNode(children: [
    TextNode(text: "Blah blah"),
    RowNode(children: []),
  ]),
];

/// this widget must enclose your MaterialApp, or CupertinoApp or WidgetsApp
/// so that the CAPIBloc becomes available to overlays, which are placed into
/// the app's overlay and not in your widget tree as you might have expected.
class ContentEditorWrapper extends StatefulWidget {
  final String initialValueJsonAssetPath;
  final bool localTestingFilePaths;
  final bool runningInProduction;
  final ContentEditorFunc contentEditorF;

  ContentEditorWrapper({
    required this.initialValueJsonAssetPath,
    this.localTestingFilePaths = false,
    this.runningInProduction = false,
    required this.contentEditorF,
    super.key,
  });

  @override
  State<ContentEditorWrapper> createState() => _ContentEditorWrapperState();
}

class _ContentEditorWrapperState extends State<ContentEditorWrapper> {
  late NodeEditorBloc nodeEditorBloc;
  late final treeController;

  double? _prevScrW;
  double? _prevScrH;

  @override
  void initState() {
    // stored in the bloc
    treeController = TreeController<Node>(roots: roots, childrenProvider: childrenProvider);
    nodeEditorBloc = NodeEditorBloc(treeC: treeController);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        return NotificationListener<SizeChangedLayoutNotification>(
          onNotification: (SizeChangedLayoutNotification notification) {
            print("_CAPIAppWrapperState onNotification: ${notification.toString()}");
            // MaterialAppWrapper.iwSizeMap = {};
            bool screenSizeChanged = false;
            if ((_prevScrW ?? 0) != Useful.scrW) {
              _prevScrW = Useful.scrW;
              screenSizeChanged = true;
            }
            if (!screenSizeChanged || (_prevScrH ?? 0) != Useful.scrH) {
              _prevScrH = Useful.scrH;
              screenSizeChanged = true;
            }
            return screenSizeChanged;
          },
          child: SizeChangedLayoutNotifier(
            child: BlocProvider<NodeEditorBloc>(
              create: (BuildContext context) => nodeEditorBloc,
              child: widget.contentEditorF.call(treeController),
            ),
          ),
        );
      });
}

extension ExtendedOffset on Offset {
  String toFlooredString() {
    return '(${dx.floor()}, ${dy.floor()})';
  }
}
