import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/content/bloc/node_editor_bloc.dart';
import 'package:flutter_callout_api/src/content/features.dart';
import 'package:flutter_callout_api/src/content/mappable_nodes/content_nodes.dart';

enum AddAction { addChild, wrapWith, addSiblingBefore, addSiblingAfter }

class WidgetTypeMenu extends StatelessWidget {
  final AddAction action;

  const WidgetTypeMenu({required this.action, super.key});

  static Future<Callout> showNodeMenu(WidgetTypeMenu menu, TargetKeyFunc targetGKF) async {
    Useful.om.removeAll();

    Callout callout = Callout(
        feature: ContentFeature.POPUP_WRAP_WITH_MENU.index,
        targetGKF: targetGKF,
        contents: () => menu,
        barrierOpacity: .1,
        arrowType: ArrowType.THIN,
        arrowColor: Colors.green,
        color: Colors.transparent,
        alwaysReCalcSize: true,
        initialTargetAlignment: Alignment.centerRight,
        initialCalloutAlignment: Alignment.centerLeft,
        toDelta: -30.0,
        separation: 200,
        onBarrierTappedF: () {
          Useful.om.removeAll(exceptToast: true);
        });

    callout.show();

    return callout;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: getMenuItems(),
      ),
    );
  }

  // // used by callout creator i.o.t. save calculating the height
  // double menuHeight() => getMenuItems().length * (kIsWeb ? 48 : 68.0);

  List<Widget> getMenuItems() {
    List<Type> types = SingleChildSubClasses.toList()..addAll(MultiChildSubClasses.toList()..add(TextSpanNode));

    return types.map((Type t) => boxChild(child: WidgetTypeMI(t, action))).toList();
  }
}

class WidgetTypeMI extends StatelessWidget {
  final Type type;
  final AddAction action;

  const WidgetTypeMI(this.type, this.action, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        NodeEditorBloc bloc = BlocProvider.of<NodeEditorBloc>(context);
        NodeEditorEvent event = switch (action) {
          AddAction.wrapWith => NodeEditorEvent.wrapWith(type: type),
          AddAction.addSiblingBefore => NodeEditorEvent.addSiblingBefore(type: type),
          AddAction.addSiblingAfter => NodeEditorEvent.addSiblingAfter(type: type),
          _ => NodeEditorEvent.addChild(type: type)
        };
        bloc.add(event);
        Useful.om.removeParentCallout(context, true);
      },
      child: Text(type.toString()),
    );
  }
}
