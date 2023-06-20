import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/content/bloc/node_editor_bloc.dart';
import 'package:flutter_callout_api/src/content/mappable_nodes/content_nodes.dart';

class TrashNodeMI extends StatelessWidget {
  final Node node;

  const TrashNodeMI(this.node);

  @override
  Widget build(BuildContext context) {
    NodeEditorBloc bloc = BlocProvider.of<NodeEditorBloc>(context);

    return TextButton.icon(
      onPressed: () async {
        bloc.add(NodeEditorEvent.deleteNodeTapped());
        Useful.om.removeParentCallout(context, true);
      },
      label: text18('delete this widget'),
      icon: Icon(
        Icons.delete,
        size: 28,
        color: Colors.red,
      ),
    );
  }
}
