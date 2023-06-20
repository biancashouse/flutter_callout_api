import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/src/content/mappable_nodes/content_nodes.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'node_editor_bloc.freezed.dart';

part 'node_editor_event.dart';

part 'node_editor_state.dart';

class NodeEditorBloc extends Bloc<NodeEditorEvent, NodeEditorState> {
  bool get deleteInProgress => state.nodeBeingDeletedKey != null;

  bool get aNodeIsSelected => state.selectedNode != null;

  NodeEditorBloc({required TreeController<Node> treeC}) : super(NodeEditorState(treeC: treeC)) {
    on<ClearUR>((event, emit) => _clearUR(event, emit));
    on<SelectNode>((event, emit) => _selectNode(event, emit));
    on<WrapWith>((event, emit) => _wrapWith(event, emit));
    on<AddChild>((event, emit) => _addChild(event, emit));
    on<AddSiblingBefore>((event, emit) => _addSiblingBefore(event, emit));
    on<AddSiblingAfter>((event, emit) => _addSiblingAfter(event, emit));
    on<ClearSelection>((event, emit) => _clearSelection(event, emit));
    on<DeleteNodeTapped>((event, emit) => _deleteNodeTapped(event, emit));
    on<AddNode>((event, emit) => _addNode(event, emit));
    on<CreateSnippet>((event, emit) => _createSnippet(event, emit));
    on<ClearClipboard>((event, emit) => _clearClipboard(event, emit));
    on<CopyNode>((event, emit) => _copyNode(event, emit));
    on<CutNode>((event, emit) => _cutNode(event, emit));
    on<PasteNode>((event, emit) => _pasteNode(event, emit));
    on<CreateUndo>((event, emit) => _createUndo(event, emit));
    on<Undo>((event, emit) => _undo(event, emit));
    on<Redo>((event, emit) => _redo(event, emit));
  }

  void _selectNode(SelectNode event, emit) {
    emit(state.copyWith(
      movedNodeId: null,
      selectedNode: event.node,
      showAdders: event.showAdders,
      nodeParent: event.nodeParent,
      nodeRootIndex: event.nodeRootIndex,
      lastAddedNode: null,
      force: state.force + 1,
    ));
  }

  void _clearSelection(event, emit) {
    emit(state.copyWith(
      movedNodeId: null,
      selectedNode: null,
      nodeParent: null,
      lastAddedNode: null,
      force: state.force + 1,
    ));
  }

  Future<void> _deleteNodeTapped(DeleteNodeTapped event, emit) async {
    // // state.ur.createUndo(flowchart: state.flowchart);
    // await Future.delayed(Duration(milliseconds: 500));
    emit(state.copyWith(
      nodeBeingDeletedKey: state.selectedNode!.key,
      force: state.force + 1,
    ));
    await Future.delayed(Duration(milliseconds: 1000));
    print(state.treeC.roots.first.toMap());
    // possibly remove from parent
    if (state.nodeParent != null) {
      if (state.nodeParent is SingleChildNode) {
        (state.nodeParent as SingleChildNode).child = null;
      } else if (state.nodeParent is MultiChildNode) {
        (state.nodeParent as MultiChildNode).children.remove(state.selectedNode);
      }
    } else {
      state.treeC.roots.toList().remove(state.selectedNode);
    }
    state.treeC.rebuild();
    print("--------------");
    print(state.treeC.roots.first.toMap());
    emit(state.copyWith(
      nodeBeingDeletedKey: null,
      // ur: state.ur,
      force: state.force + 1,
    ));
  }

  Future<void> _cutNode(CutNode event, emit) async {
    String cutJson = event.node.toJson();
    if (state.nodeParent != null) {
      if (state.nodeParent is SingleChildNode) {
        (state.nodeParent as SingleChildNode).child = null;
      } else if (state.nodeParent is MultiChildNode) {
        (state.nodeParent as MultiChildNode).children.remove(state.selectedNode);
      }
    } else {
      state.treeC.roots.toList().remove(state.selectedNode);
    }
    state.treeC.rebuild();
    emit(state.copyWith(
      jsonClipboard: cutJson,
      // ur: state.ur,
      force: state.force + 1,
    ));
  }

  Future<void> _copyNode(CopyNode event, emit) async {
    emit(state.copyWith(
      jsonClipboard: event.node.toJson(),
      force: state.force + 1,
    ));
  }

  void _clearClipboard(event, emit) {
    emit(state.copyWith(
      jsonClipboard: null,
      force: state.force + 1,
    ));
  }

  void _wrapWith(WrapWith event, emit) {
    Node newNode = switch (event.type) {
      SizedBoxNode => SizedBoxNode(child: state.selectedNode),
      ContainerNode => ContainerNode(child: state.selectedNode),
      CenterNode => CenterNode(child: state.selectedNode),
      ExpandedNode => ExpandedNode(child: state.selectedNode),
      FlexibleNode => FlexibleNode(child: state.selectedNode),
      PaddingNode => PaddingNode(child: state.selectedNode),
      PositionedNode => PositionedNode(child: state.selectedNode),
      WidgetSpanNode => WidgetSpanNode(child: state.selectedNode!),
      AlignNode => AlignNode(child: state.selectedNode, alignment: NodeAlignment.topLeft),
      ColumnNode => ColumnNode(children: [state.selectedNode!]),
      RowNode => RowNode(children: [state.selectedNode!]),
      StackNode => StackNode(children: [state.selectedNode!]),
      TextSpanNode => TextSpanNode(children: [state.selectedNode as InlineSpanNode]),
      _ => throw(Exception("_wrapWith() missing ${event.type.toString()}")),
    };

    // // attach new parent at select node's pos in the tree...
    // if selected node is actually a root node, make newNode the new root
    if (state.nodeParent == null) {
      List<Node> roots = List.of(state.treeC.roots);
      roots[state.nodeRootIndex] = newNode;
      state.treeC.roots = roots;
    } else {
      //
      if (state.nodeParent is SingleChildNode) {
        (state.nodeParent as SingleChildNode).child = newNode;
      } else if (state.nodeParent is MultiChildNode) {
        int i = (state.nodeParent as MultiChildNode).children.indexOf(state.selectedNode!);
        (state.nodeParent as MultiChildNode).children[i] = newNode;
      }
    }
    state.treeC
      ..expand(newNode)
      ..rebuild();
    emit(state.copyWith(
      movedNodeId: null,
      selectedNode: newNode,
      nodeParent: state.nodeParent,
      nodeRootIndex: state.nodeRootIndex,
      lastAddedNode: newNode,
      force: state.force + 1,
    ));
  }

  void _addChild(AddChild event, emit) {
    Node newNode = switch (event.type) {
      SizedBoxNode => SizedBoxNode(),
      ContainerNode => ContainerNode(),
      CenterNode => CenterNode(),
      ExpandedNode => ExpandedNode(),
      FlexibleNode => FlexibleNode(),
      PaddingNode => PaddingNode(),
      PositionedNode => PositionedNode(),
      AlignNode => AlignNode(alignment: NodeAlignment.topLeft),
      ColumnNode => ColumnNode(children: []),
      RowNode => RowNode(children: []),
      StackNode => StackNode(children: []),
      TextSpanNode => TextSpanNode(children: []),
      WidgetSpanNode => WidgetSpanNode(),
      _ => throw(Exception("_addChild() missing ${event.type.toString()}")),
    };

    if (state.selectedNode is SingleChildNode) {
      (state.selectedNode as SingleChildNode).child = newNode;
    } else if (state.selectedNode is MultiChildNode) {
      (state.selectedNode as MultiChildNode).children = [newNode];
    } else if (state.selectedNode is TextSpanNode) {
      (state.selectedNode as TextSpanNode).children = [newNode];
    }
    state.treeC
      ..expand(state.selectedNode!)
      ..rebuild();
    emit(state.copyWith(
      movedNodeId: null,
      lastAddedNode: newNode,
      force: state.force + 1,
    ));
  }

  void _addSiblingBefore(AddSiblingBefore event, emit) {
    int i = (state.nodeParent as MultiChildNode).children.indexOf(state.selectedNode!);
    _addSiblingAt(event.type, emit, i);
  }

  void _addSiblingAfter(AddSiblingAfter event, emit) {
    int i = (state.nodeParent as MultiChildNode).children.indexOf(state.selectedNode!);
    _addSiblingAt(event.type, emit, i + 1);
  }

  void _addSiblingAt(Type nodeType, emit, int i) {
    Node newNode = switch (nodeType) {
      SizedBoxNode => SizedBoxNode(),
      ContainerNode => ContainerNode(),
      CenterNode => CenterNode(),
      ExpandedNode => ExpandedNode(),
      FlexibleNode => FlexibleNode(),
      PaddingNode => PaddingNode(),
      PositionedNode => PositionedNode(),
      AlignNode => AlignNode(alignment: NodeAlignment.topLeft),
      ColumnNode => ColumnNode(children: []),
      RowNode => RowNode(children: []),
      StackNode => StackNode(children: []),
      TextSpanNode => TextSpanNode(children: []),
      _ => throw(Exception("_addSiblingAt() missing ${nodeType.toString()}")),
    };

    (state.nodeParent as MultiChildNode).children.insert(i, newNode);

    state.treeC.rebuild();
    emit(state.copyWith(
      selectedNode: newNode,
      lastAddedNode: newNode,
      force: state.force + 1,
    ));
  }

  // void _updateNodeTxt(UpdateNodeTxt event, emit) {
  // if (event.node != null) {
  //   if (event.node!.txt != event.theNewTxt) {
  //     event.node!.setTxt(event.theNewTxt);
  //   }
  // } else if (event.isBeginNode && state.flowchart.beginTxt != event.theNewTxt) {
  //   state.flowchart.beginTxt = event.theNewTxt;
  //   //developer.log('new beginTxt size is ${fbe.txtSize.width} ${fbe.txtSize.height}');
  // } else if (event.isEndNode && state.flowchart.endTxt != event.theNewTxt) {
  //   state.flowchart.endTxt = event.theNewTxt;
  // }
  // emit(state.copyWith(
  //   force: state.force + 1,
  // ));
  // }

  Future<void> _addNode(AddNode event, emit) async {
    // state.ur.createUndo(flowchart: state.flowchart);
    // Node? addedNode = _addPickedNodeType(state.flowchart, event.droppedNodeType, adder2InsertBefore: event.adder2InsertBefore);
    // state.flowchart.removeInsertersAndMovers();
    // // dragend not called!
    // // state.flowchart.nodeTypeDragInProgress = false;
    // emit(state.copyWith(
    //   lastAddedNode: addedNode,
    //   ur: state.ur,
    //   force: state.force + 1,
    // ));
    // await Future.delayed(Duration(milliseconds: 50));
    // emit(state.copyWith(
    //   lastAddedNode: null,
    //   selectedNodeId: addedNode?.id,
    //   force: state.force + 1,
    // ));
  }

  void _createSnippet(CreateSnippet event, emit) {
    // state.ur.createUndo(node: state.node);
    // event.functionNode.flowchartLinkRef = event.node.id;
    // event.functionNode.setTxt(event.flowchart.beginTxt);
    // emit(state.copyWith(
    //   ur: state.ur,
    //   force: state.force + 1,
    // ));
  }

  Future<void> _pasteNode(PasteNode event, emit) async {
    //   state.ur.createUndo(flowchart: state.flowchart);
    //   String? parentListType = event.adder.parentListType;
    //   Node? parentNode = event.adder.parentNode;
    //   Node? nodeBeingPasted = App.bloc.state.clipboard?.nodes[0];
    //   if (nodeBeingPasted != null) {
    //     Node clonedNode = await Node.clone(nodeBeingPasted, parentNode, state.flowchart);
    //     clonedNode
    //       ..parentNode = parentNode
    //       ..parentListType = parentListType;
    //     // update every pasted node's parentFlowchart
    //     Node.updateChildrensParentFlowchart(clonedNode, state.flowchart);
    //     NodeEditorBloc.addNodeBefore(state.flowchart, theNodeBeingInserted: clonedNode, nodeToInsertBefore: event.adder);
    //     state.flowchart.removeInsertersAndMovers();
    //     // dragend not called!
    //     // state.flowchart.nodeTypeDragInProgress = false;
    //   }
    //   emit(
    //     state.copyWith(
    //       ur: state.ur,
    //       force: state.force + 1,
    //     ),
    //   );
  }

  void _createUndo(CreateUndo event, emit) {
    // event.flowchart.removeInsertersAndMovers();
    // state.ur.createUndo(flowchart: event.flowchart, pushClone: false);
    // //App.bloc.add(AppEvent.clipboardChanged());
    // if (!event.skipEmit) {
    //   emit(
    //     state.copyWith(
    //       ur: state.ur,
    //       force: state.force + 1,
    //     ),
    //   );
    // }
  }

  void _undo(Undo event, emit) {
    // Node prevFlowchart = state.canUndo ? state.ur.undo(skipRedo: event.skipRedo)! : state.flowchart;
    // prevFlowchart.removeInsertersAndMovers(force: true);
    // emit(
    //   state.copyWith(
    //     ur: state.ur,
    //     flowchart: prevFlowchart,
    //     force: state.force + 1,
    //   ),
    // );
  }

  void _redo(Redo event, emit) {
    // Node prevFlowchart = state.canRedo ? state.ur.redo()! : state.flowchart;
    // emit(
    //   state.copyWith(
    //     ur: state.ur,
    //     flowchart: prevFlowchart,
    //     force: state.force + 1,
    //   ),
    // );
  }

  void _clearUR(ClearUR event, emit) {
    // state.ur.clear();
    // emit(
    //   state.copyWith(
    //     ur: state.ur,
    //     force: state.force + 1,
    //   ),
    // );
  }

  // Node? _addPickedNodeType(Node fbe, NodeTypeEnum thePickedNodeType, {Node? adder2InsertBefore}) {
//     Node? newNode;
//     String? parentListType = adder2InsertBefore != null ? adder2InsertBefore.parentListType : ROOT_STEPS;
//     Node? parentNode = adder2InsertBefore != null ? adder2InsertBefore.parentNode : ROOT_STEP;
//     // int key = DateTime.now().millisecondsSinceEpoch;
//
//     switch (thePickedNodeType) {
//       case NodeTypeEnum.none:
//         break;
//       case NodeTypeEnum.Action:
//         newNode = Node(fbe, randomKey())
//           ..setTxt(ACTION)
// //          ..txtWForScreen = initialNodeWidth(ACTION)
//           ..shape = ACTION;
//         break;
//       case NodeTypeEnum.FuncCall:
//         Map<String, List<Node>> map = {FUNC_CALL_STEPS: []};
//         newNode = Node(fbe, randomKey())
//           ..setTxt(FUNC_CALL)
// //          ..txtWForScreen = initialNodeWidth(FUNC_CALL)
//           ..shape = FUNC_CALL
//           ..childNodeLists = SplayTreeMap<String, List<Node>>.from(map);
//         break;
//       case NodeTypeEnum.AsyncFuncCall:
//         Map<String, List<Node>> map = {SUCCEED_STEPS: [], FAIL_STEPS: []};
//         newNode = Node(fbe, randomKey())
//           ..setTxt(ASYNC_FUNC_CALL)
// //          ..txtWForScreen = initialNodeWidth(ASYNC_FUNC_CALL)
//           ..shape = ASYNC_FUNC_CALL
//           ..childNodeLists = SplayTreeMap<String, List<Node>>.from(map);
//         break;
// //       case NodeTypeEnum.AwaitFuncCall:
// //         newNode = Node(fbe, randomKey())
// //           ..setTxtAndCalcSize(AWAIT_FUNC_CALL)
// // //          ..txtWForScreen = initialNodeWidth(AWAIT_FUNC_CALL)
// //           ..shape = AWAIT_FUNC_CALL;
// //         break;
//       case NodeTypeEnum.Loop:
//         Map<String, List<Node>> map = {LOOP_STEPS: []};
//         newNode = Node(fbe, randomKey())
//           ..setTxt(LOOP)
// //          ..txtWForScreen = initialNodeWidth(LOOP)
//           ..shape = LOOP
//           ..childNodeLists = SplayTreeMap<String, List<Node>>.from(map);
//         break;
//       case NodeTypeEnum.Decision:
//         Map<String, List<Node>> map = {TRUE_STEPS: [], FALSE_STEPS: []};
//         newNode = Node(fbe, randomKey())
//           ..setTxt(DECISION)
// //          ..txtWForScreen = initialNodeWidth(DECISION)
//           ..shape = DECISION
//           ..childNodeLists = SplayTreeMap<String, List<Node>>.from(map);
//         break;
// //       case AdderMenuEnum.Switch:
// //         Map<String, List<Node>> map = {'1 default': []};
// //         newNode = Node(fbe, randomKey())
// //           ..setTxtAndCalcSize(SWITCH)
// // //          ..txtWForScreen = initialNodeWidth(SWITCH)
// //           ..shape = SWITCH
// //           ..childNodeLists = SplayTreeMap<String, List<Node>>.from(map)
// //           ..setCaseNameWidth('1 default');
// //         break;
//       case NodeTypeEnum.Switch:
//         throw (Exception("Switch TBI"));
//       case NodeTypeEnum.Case:
//         throw (Exception("Case TBI"));
//       case NodeTypeEnum.FuncReturn:
//         newNode = Node(fbe, randomKey())
//           ..setTxt(FUNC_RETURN)
// //          ..txtWForScreen = initialNodeWidth(FUNC_RETURN)
//           ..shape = FUNC_RETURN;
//         break;
//
//     }
//
//     newNode!
//       ..parentNode = parentNode
//       ..parentListType = parentListType
//       ..parentNode?.flowchartLinkRef = null;
//
//     addNodeBefore(fbe, theNodeBeingInserted: newNode, nodeToInsertBefore: adder2InsertBefore);
//
//     return newNode;
//   }

  static addNodeBefore(Node fbe, {Node? theNodeBeingInserted, Node? nodeToInsertBefore}) {
//     // fbe.editingPageState?.editorBloc.ur.createUndo(flowchart: fbe);
//
//     if (nodeToInsertBefore == null) {
//       // for very first node, nodeToInsertBefore will be null
//       fbe.nodes.add(theNodeBeingInserted!);
// //      fbe.nodes.insert(
// //          0,
// //          fbe.createInserterNode(ROOT_STEPS, ROOT_STEP, STEP_ADDER));
//     } else {
//       List<Node> plist = nodeToInsertBefore.getParentList();
//       int index = plist.indexOf(nodeToInsertBefore);
//       if (index > -1) {
//         plist.insert(index, theNodeBeingInserted!);
//         //plist.insert(index, fbe.createInserterOrMoverNode(nodeToInsertBefore.parentListType, nodeToInsertBefore.parentNode, STEP_ADDER));
//         theNodeBeingInserted
//           ..parentNode = nodeToInsertBefore.parentNode
//           ..parentListType = nodeToInsertBefore.parentListType;
//       }
//
// //      fbe.clearNodeSelection();
//
//       // var insertParentF = nodeToInsertBefore.parentFlowchart;
//
//       //fbe.save(repo);
//     }
  }
}
