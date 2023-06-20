import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/content/bloc/node_editor_bloc.dart';
import 'package:flutter_callout_api/src/content/mappable_nodes/content_nodes.dart';

class CopyNodeMI extends StatelessWidget {
  final Node node;

  const CopyNodeMI(this.node, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        NodeEditorBloc bloc = BlocProvider.of<NodeEditorBloc>(context);
        if (bloc.state.jsonClipboard != null) {
          bloc.add(NodeEditorEvent.clearClipboard());
          Useful.afterNextBuildDo(() {
            bloc.add(NodeEditorEvent.copyNode(node: node));
          });
        } else {
          bloc.add(NodeEditorEvent.copyNode(node: node));
        }
        Useful.om.removeParentCallout(context, true);
      },
      label: text18('copy this widget...'),
      icon: Icon(
        Icons.copy,
        size: 28,
        color: Colors.blueAccent,
      ),
    );
  }
}
