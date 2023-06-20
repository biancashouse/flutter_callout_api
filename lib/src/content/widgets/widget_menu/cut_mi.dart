import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/content/bloc/node_editor_bloc.dart';
import 'package:flutter_callout_api/src/content/mappable_nodes/content_nodes.dart';

class CutNodeMI extends StatelessWidget {
  final Node node;


  const CutNodeMI(this.node, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        NodeEditorBloc bloc = BlocProvider.of<NodeEditorBloc>(context);
        if (bloc.state.jsonClipboard != null) {
          bloc.add(NodeEditorEvent.clearClipboard());
          Useful.afterNextBuildDo(() {
            bloc.add(NodeEditorEvent.cutNode(node: node));
          });
        } else {
          bloc.add(NodeEditorEvent.cutNode(node: node));
        }
        Useful.om.removeParentCallout(context, true);
      },
      label: text18('cut this widget...'),
      icon: Icon(
        Icons.cut,
        size: 28,
        color: Colors.red[700],
      ),
    );
  }
}
