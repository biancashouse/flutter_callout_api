import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/content/bloc/node_editor_bloc.dart';
import 'package:flutter_callout_api/src/content/widgets/node_widget.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import 'mappable_nodes/content_nodes.dart';

class MinimalTreeView extends StatefulWidget {
  const MinimalTreeView({super.key});

  @override
  State<MinimalTreeView> createState() => _MinimalTreeViewState();
}

class _MinimalTreeViewState extends State<MinimalTreeView> {
  @override
  void didChangeDependencies() {
    Useful.instance.initWithContext(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    NodeEditorBloc bloc = BlocProvider.of<NodeEditorBloc>(context);
    return BlocBuilder<NodeEditorBloc, NodeEditorState>(
        builder: (context, state) {
          return TreeView<Node>(
            treeController: bloc.state.treeC,
            nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
              return TreeIndentation(
                entry: entry,
                child: NodeWidget(treeController: bloc.state.treeC, entry: entry),
              );
            },
          );
        });
  }
}
