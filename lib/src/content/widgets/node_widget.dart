import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/content/bloc/node_editor_bloc.dart';
import 'package:flutter_callout_api/src/content/mappable_nodes/content_nodes.dart';
import 'package:flutter_callout_api/src/content/widgets/widget_menu/menu.dart';
import 'package:flutter_callout_api/src/content/widgets/widget_menu/widget_type_menu.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

typedef Adder<Node> = void Function({Node? parentNode, required Node selectedNode, required Node newNode});

class NodeWidget extends StatefulWidget {
  final TreeController<Node> treeController;
  final TreeEntry<Node> entry;
  final bool onClipboard;

  const NodeWidget({super.key, required this.treeController, required this.entry, this.onClipboard = false});

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  GlobalKey? nodeGK;

  @override
  void didChangeDependencies() {
    Useful.instance.initWithContext(context);
    super.didChangeDependencies();
  }

  int nearestRootIndex(TreeEntry<Node> entry) {
    TreeEntry<Node> rootEntry = entry;
    while (rootEntry.parent != null) {
      rootEntry = rootEntry.parent!;
    }
    int rootIndex = widget.treeController.roots.toList().indexOf(rootEntry.node);
    return rootIndex;
  }

  @override
  Widget build(BuildContext context) {
    NodeEditorBloc bloc = BlocProvider.of<NodeEditorBloc>(context);
    return BlocBuilder<NodeEditorBloc, NodeEditorState>(
      builder: (context, state) {
        bool selected = state.selectedNode == widget.entry.node;
        bool somethingIsSelected = state.selectedNode != null;
        bool showingAdders = state.showAdders;
        int deletingNodeKey = state.nodeBeingDeletedKey ?? -1;
        if (selected) {
          nodeGK = GlobalKey();
        } else {
          nodeGK = null;
        }
        TreeEntry<Node>? parentEntry = widget.entry.parent;
        bool badParent = widget.entry.node.sensibleParents().isNotEmpty && !widget.entry.node.sensibleParents().contains(parentEntry?.node.label());
        if (badParent) {
          print("bad ${widget.entry.node.label()}, parent: ${parentEntry?.node.label()}");
          print("sensible parents: ${widget.entry.node.sensibleParents().toString()}");
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selected && showingAdders && parentEntry != null && parentEntry.node is MultiChildNode)
              IconButton(
                  iconSize: 32,
                  tooltip: "add sibling before...",
                  onPressed: () {
                    if (nodeGK?.currentWidget != null) {
                      WidgetTypeMenu.showNodeMenu(
                        WidgetTypeMenu(action: AddAction.addSiblingBefore),
                        () => nodeGK,
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_circle_left, color: Colors.green)),
            GestureDetector(
              onDoubleTap: () {
                if (widget.onClipboard) return;
                widget.treeController.toggleExpansion(widget.entry.node);
              },
              onLongPress: () {
                if (widget.onClipboard) return;
                if (!selected && somethingIsSelected) {
                  bloc.add(const NodeEditorEvent.clearSelection());
                  Useful.afterNextBuildDo(() {
                    _selectThenShowNodeMenu(showAdders: false);
                  });
                } else {
                  _selectThenShowNodeMenu(showAdders: false);
                }
              },
              onTap: () {
                if (widget.onClipboard) return;
                if (!selected && somethingIsSelected) {
                  bloc.add(const NodeEditorEvent.clearSelection());
                  Useful.afterNextBuildDo(() {
                    _select(showAdders: true);
                  });
                } else {
                  _select(showAdders: true);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(top:4.0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: deletingNodeKey == widget.entry.node.key ? Colors.red : Colors.white,
                              border: Border.all(color: selected ? Colors.brown : Colors.grey, width: selected ? 3 : 1),
                              borderRadius: const BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (selected && showingAdders)
                                  const SizedBox(
                                    width: 50,
                                    height: 30,
                                  ),
                                Text(
                                  key: nodeGK,
                                  widget.entry.node.label() ?? "",
                                  textScaleFactor: selected ? 1.5 : 1,
                                  style: TextStyle(
                                    color: badParent ? Colors.orange : null,
                                    fontStyle: widget.entry.node is MultiChildNode && !widget.entry.hasChildren ? FontStyle.italic : FontStyle.normal,
                                  ),
                                ),
                                if (selected && showingAdders && (!(widget.entry.node is ChildlessNode) && (!widget.entry.hasChildren)))
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: IconButton(
                                        iconSize: 32,
                                        tooltip: "add child widget...",
                                        onPressed: () {
                                          if (nodeGK?.currentWidget != null) {
                                            WidgetTypeMenu.showNodeMenu(
                                              WidgetTypeMenu(action: AddAction.addChild),
                                              () => nodeGK,
                                            );
                                          }
                                        },
                                        icon: Transform.rotate(angle: 5 * pi / 4, child: const Icon(Icons.arrow_circle_left, color: Colors.green))),
                                  )
                                else if (selected && showingAdders)
                                  Container(
                                    width: 20,
                                    height: 40,
                                  ),
                              ],
                            ),
                          ),
                          if (selected && showingAdders)
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: IconButton(
                                  iconSize: 32,
                                  tooltip: "wrap with widget...",
                                  onPressed: () {
                                    if (nodeGK?.currentWidget != null) {
                                      WidgetTypeMenu.showNodeMenu(
                                        WidgetTypeMenu(action: AddAction.wrapWith),
                                        () => nodeGK,
                                      );
                                    }
                                    // traverseTree(
                                    //   node: widget.treeController.roots.first,
                                    //   newNode: ContainerNode(),
                                    //   addNodeF: wrapWith,
                                    //   childProvider: widget.treeController.childrenProvider,
                                    //   nodeParent: bloc.state.nodeParent,
                                    //   selectedNode: bloc.state.selectedNode!,
                                    // );
                                  },
                                  icon: Transform.rotate(angle: pi / 4, child: const Icon(Icons.arrow_circle_left, color: Colors.green))),
                            ),
                        ],
                      ),
                    ),
                    if (widget.entry.hasChildren)
                      ExpandIcon(
                        key: GlobalObjectKey(widget.entry.node),
                        isExpanded: widget.entry.isExpanded,
                        onPressed: (_) => widget.treeController.toggleExpansion(widget.entry.node),
                      ),
                  ],
                ),
              ),
            ),
            if (selected && showingAdders && parentEntry != null && parentEntry.node is MultiChildNode)
              IconButton(
                  iconSize: 32,
                  tooltip: "add sibling after...",
                  onPressed: () {
                    if (nodeGK?.currentWidget != null) {
                      WidgetTypeMenu.showNodeMenu(
                        WidgetTypeMenu(action: AddAction.addSiblingAfter),
                        () => nodeGK,
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_circle_left, color: Colors.green)),
          ],
        );
      },
    );
  }

  void _select({required bool showAdders}) {
    NodeEditorBloc bloc = BlocProvider.of<NodeEditorBloc>(context);
    bloc.add(NodeEditorEvent.selectNode(
        node: widget.entry.node, nodeParent: widget.entry.parent?.node, nodeRootIndex: bloc.state.nodeRootIndex, showAdders: showAdders));
  }

  void _selectThenShowNodeMenu({required bool showAdders}) {
    NodeEditorBloc bloc = BlocProvider.of<NodeEditorBloc>(context);
    _select(showAdders: showAdders);
    Useful.afterNextBuildDo(() {
      if (nodeGK?.currentWidget != null) {
        NodeMenu.showNodeMenu(
          bloc,
          NodeMenu(
            node: widget.entry.node,
            nodeParent: widget.entry.parent?.node,
            nodeRootIndex: nearestRootIndex(widget.entry),
          ),
          () => nodeGK,
        );
      }
    });
  }

// bool traverseTree({
//   required Node node,
//   Node? parentNode,
//   int? rootIndex,
//   required Node newNode,
//   required Adder<Node> addNodeF,
//   required ChildrenProvider<Node> childProvider,
//   required Node selectedNode,
//   required Node? nodeParent,
// }) {
//   if (node == selectedNode) {
//     addNodeF.call(parentNode: parentNode, selectedNode: node, newNode: newNode);
//     widget.treeController.rebuild();
//     return true;
//   } else {
//     List<Node> children = childProvider(node).toList();
//     if (children.isEmpty) return false;
//     for (Node child in children) {
//       if (traverseTree(
//         node: child,
//         parentNode: parentNode,
//         newNode: newNode,
//         addNodeF: addNodeF,
//         childProvider: childProvider,
//         selectedNode: selectedNode,
//         nodeParent: nodeParent,
//       )) {
//         return true;
//       }
//     }
//   }
//   return false;
// }
}
