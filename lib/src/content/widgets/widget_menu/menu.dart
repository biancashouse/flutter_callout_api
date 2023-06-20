import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/content/bloc/node_editor_bloc.dart';
import 'package:flutter_callout_api/src/content/features.dart';
import 'package:flutter_callout_api/src/content/mappable_nodes/content_nodes.dart';
import 'package:flutter_callout_api/src/content/widgets/widget_menu/easy_color_picker.dart';
import 'package:flutter_callout_api/src/content/widgets/widget_menu/trash_mi.dart';

import 'copy_mi.dart';
import 'cut_mi.dart';

typedef DoubleCallback = void Function(double value);
typedef IntCallback = void Function(int value);
typedef MainAxisAlignmentCallback = void Function(NodeMainAxisAlignment value);

const List<Color> colors = [
  Colors.white,
  Colors.black,
  Colors.grey,
  Colors.deepPurple,
  Colors.deepPurpleAccent,
  Colors.purple,
  Colors.purpleAccent,
  Colors.pinkAccent,
  Colors.pink,
  Colors.red,
  Colors.redAccent,
  Colors.orange,
  Colors.amberAccent,
  Colors.yellow,
  Colors.yellowAccent,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.lightGreenAccent,
  Colors.greenAccent,
  Colors.lightBlueAccent,
  Colors.cyan,
  Colors.lightBlue,
  Colors.blue,
];

class NodeMenu extends StatefulWidget {
  final Node? nodeParent;
  final Node node;
  final int nodeRootIndex;
  final Axis direction;

  const NodeMenu({required this.node, this.nodeParent, required this.nodeRootIndex, this.direction = Axis.vertical, super.key});

  static Future<Callout> showNodeMenu(NodeEditorBloc bloc, NodeMenu menu, TargetKeyFunc targetGKF) async {
    Useful.om.removeAll();

    Callout callout = Callout(
        feature: ContentFeature.POPUP_NODE_MENU.index,
        targetGKF: targetGKF,
        contents: () => menu,
        barrierOpacity: .1,
        arrowType: ArrowType.THIN,
        arrowColor: Colors.blueAccent,
        color: Colors.transparent,
        alwaysReCalcSize: true,
        initialTargetAlignment: Alignment.centerRight,
        initialCalloutAlignment: Alignment.centerLeft,
        toDelta: -30.0,
        separation: 260,
        onBarrierTappedF: () {
          bloc.add(const NodeEditorEvent.clearSelection());
          Useful.om.removeAll(exceptToast: true);
        });

    callout.show();

    return callout;
  }

  @override
  State<NodeMenu> createState() => _NodeMenuState();
}

class _NodeMenuState extends State<NodeMenu> {
  final TextEditingController widthC = TextEditingController();
  final TextEditingController heightC = TextEditingController();
  final TextEditingController paddingC = TextEditingController();
  final TextEditingController flexC = TextEditingController();
  final TextEditingController topC = TextEditingController();
  final TextEditingController leftC = TextEditingController();
  final TextEditingController bottomC = TextEditingController();
  final TextEditingController rightC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Flex(
        direction: widget.direction,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: getMenuItems(),
      ),
    );
  }

  // used by callout creator i.o.t. save calculating the height
  double menuHeight() {
    int result = 0;

    // copy node
    result++;

    // cut node
    result++;

    return result * (kIsWeb ? 48 : 68.0);
  }

  List<Widget> getMenuItems() {
    final List<Widget> menuItems = [];

    if (widget.node is PaddingNode) {
      PaddingNode node = widget.node as PaddingNode;
      addPaddingMenuItems(menuItems, node);
    }

    if (widget.node is ContainerNode) {
      ContainerNode node = widget.node as ContainerNode;
      addContainerMenuItems(menuItems, node);
    }

    if (widget.node is AlignNode) {
      AlignNode node = widget.node as AlignNode;
      addAlignMenuItems(menuItems, node);
    }

    if (widget.node is ExpandedNode) {
      ExpandedNode node = widget.node as ExpandedNode;
      addExpandedMenuItems(menuItems, node);
    }

    if (widget.node is FlexibleNode) {
      FlexibleNode node = widget.node as FlexibleNode;
      addFlexibleMenuItems(menuItems, node);
    }

    if (widget.node is PositionedNode) {
      PositionedNode node = widget.node as PositionedNode;
      addPositionedMenuItems(menuItems, node);
    }

    if (widget.node is SizedBoxNode) {
      SizedBoxNode node = widget.node as SizedBoxNode;
      addSizedBoxMenuItems(menuItems, node);
    }

    if (widget.node is RowNode) {
      RowNode node = widget.node as RowNode;
      addFlexMenuItems(menuItems, node);
    }

    if (widget.node is ColumnNode) {
      ColumnNode node = widget.node as ColumnNode;
      addFlexMenuItems(menuItems, node);
    }

    menuItems.add(CopyNodeMI(widget.node));

    menuItems.add(CutNodeMI(widget.node));

    menuItems.add(TrashNodeMI(widget.node));

    return menuItems.map((Widget mi) => boxChild(child: mi)).toList();
  }

  void addPaddingMenuItems(final List<Widget> menuItems, final PaddingNode node) {
    paddingC.text = node.padding.toString();
    menuItems.add(
      inputDouble(
        tC: paddingC,
        name: 'padding',
        onChangeF: (val) => node.padding = val,
      ),
    );
  }

  void addContainerMenuItems(final List<Widget> menuItems, final ContainerNode node) {
    menuItems.add(
      Container(
        color: Colors.black12,
        width: 280,
        child: EasyColorPicker(
            selected: Color(node.colorValue ?? Colors.white.value),
            colors: colors,
            onChanged: (color) => setState(() => node.colorValue = color.value)),
      ),
    );
    widthC.text = node.width == null ? '' : node.width.toString();
    menuItems.add(
      inputDouble(
        tC: widthC,
        name: 'width',
        onChangeF: (val) => node.width = val,
      ),
    );
    heightC.text = node.height == null ? '' : node.height.toString();
    menuItems.add(
      inputDouble(
        tC: heightC,
        name: 'height',
        onChangeF: (val) => node.height = val,
      ),
    );
    paddingC.text = node.padding == null ? '' : node.padding.toString();
    menuItems.add(
      inputDouble(
        tC: paddingC,
        name: 'padding',
        onChangeF: (val) => node.padding = val,
      ),
    );
  }

  void addAlignMenuItems(final List<Widget> menuItems, final AlignNode node) {
    menuItems.add(SizedBox(
      width: 320,
      height: 160,
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.8,
        children: NodeAlignment.values
            .toList()
            .map(
              (na) => IconButton(
                onPressed: () {
                  setState(() {
                    node.alignment = na;
                  });
                },
                icon: Center(
                    child: Text(
                  na.name,
                  style: TextStyle(color: node.alignment.index == na.index ? Colors.black : Colors.grey),
                )),
              ),
            )
            .toList(),
      ),
    ));
  }

  void addExpandedMenuItems(final List<Widget> menuItems, final ExpandedNode node) {
    flexC.text = node.flex.toString();
    menuItems.add(
      inputInt(
        tC: flexC,
        name: 'flex',
        onChangeF: (val) => node.flex = val,
      ),
    );
  }

  void addFlexibleMenuItems(final List<Widget> menuItems, final FlexibleNode node) {
    flexC.text = node.flex.toString();
    menuItems.add(
      inputInt(
        tC: flexC,
        name: 'flex',
        onChangeF: (val) => node.flex = val,
      ),
    );
  }

  void addPositionedMenuItems(final List<Widget> menuItems, final PositionedNode node) {
    topC.text = node.top == null ? '' : node.top.toString();
    menuItems.add(
      inputDouble(
        tC: topC,
        name: 'top',
        onChangeF: (val) => node.top = val,
      ),
    );
    leftC.text = node.left == null ? '' : node.top.toString();
    menuItems.add(
      inputDouble(
        tC: leftC,
        name: 'left',
        onChangeF: (val) => node.top = val,
      ),
    );
    bottomC.text = node.bottom == null ? '' : node.top.toString();
    menuItems.add(
      inputDouble(
        tC: bottomC,
        name: 'bottom',
        onChangeF: (val) => node.top = val,
      ),
    );
    rightC.text = node.right == null ? '' : node.top.toString();
    menuItems.add(
      inputDouble(
        tC: rightC,
        name: 'right',
        onChangeF: (val) => node.top = val,
      ),
    );
  }

  void addSizedBoxMenuItems(final List<Widget> menuItems, final SizedBoxNode node) {
    widthC.text = node.width == null ? '' : node.width.toString();
    menuItems.add(
      inputDouble(
        tC: widthC,
        name: 'width',
        onChangeF: (val) => node.width = val,
      ),
    );
    heightC.text = node.height == null ? '' : node.height.toString();
    menuItems.add(
      inputDouble(
        tC: heightC,
        name: 'height',
        onChangeF: (val) => node.height = val,
      ),
    );
  }

  void addFlexMenuItems(final List<Widget> menuItems, FlexNode node) {
    menuItems.add(Container(
      color: Colors.green.shade50,
      padding: EdgeInsets.all(6.0),
      child: const Text(
        "MainAxisAlignment",
        textAlign: TextAlign.center,
      ),
    ));
    menuItems.addAll(
      NodeMainAxisAlignment.values.map((v) {
        return RadioListTile<NodeMainAxisAlignment>(
          dense: true,
          value: v,
          groupValue: node.mainAxisAlignment,
          tileColor: Colors.green.shade50,
          title: Text(v.name),
          toggleable: true,
          onChanged: (newValue) {
            setState(() {
              node.mainAxisAlignment = newValue;
            });
          },
        );
      }),
    );
    menuItems.add(Container(
      color: Colors.blue.shade50,
      padding: EdgeInsets.all(6.0),
      child: const Text(
        "MainAxisSize",
        textAlign: TextAlign.center,
      ),
    ));
    menuItems.addAll(
      NodeMainAxisSize.values.map((v) {
        return RadioListTile<NodeMainAxisSize>(
          dense: true,
          value: v,
          groupValue: node.mainAxisSize,
          tileColor: Colors.blue.shade50,
          title: Text(v.name),
          toggleable: true,
          onChanged: (newValue) {
            setState(() {
              node.mainAxisSize = newValue;
            });
          },
        );
      }),
    );
  }

  TextField inputDouble({
    required TextEditingController tC,
    required String name,
    required DoubleCallback onChangeF,
  }) =>
      TextField(
        controller: tC,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: name,
        ),
        onChanged: (s) {
          double value = double.parse(tC.text);
          onChangeF.call(value);
        },
      );

  TextField inputInt({
    required TextEditingController tC,
    required String name,
    required IntCallback onChangeF,
  }) =>
      TextField(
        controller: tC,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: name,
        ),
        onChanged: (s) {
          if (!s.contains('.')) {
            int value = int.parse(tC.text);
            onChangeF.call(value);
          }
        },
      );
}
