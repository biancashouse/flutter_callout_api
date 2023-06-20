part of 'node_editor_bloc.dart';

@freezed
class NodeEditorState with _$NodeEditorState {
  const NodeEditorState._();

  factory NodeEditorState({
    // required NodeEditorUndoRedoStack ur,
    required TreeController<Node> treeC,
    Node? selectedNode,
    @Default(false) bool showAdders,
    Node? nodeParent,
    @Default(0) int nodeRootIndex,
    double? nodeVPos,
    double? nodeVScroll,
    int? movedNodeId,
    int? nodeBeingDeletedKey,
    Node? lastAddedNode,
    String? jsonClipboard,
    String? jsonClipboardForMove,
    @Default(true) bool showClipboardContent,
    @Default(0) int force,
  }) = _NodeEditorState;

  // FlowchartM? get clipboard => jsonClipboard != null ?  FlowchartM.fromJsonString(jsonClipboard!) : null;
  // FlowchartM? get clipboardForMove => jsonClipboardForMove != null ? FlowchartM.fromJsonString(jsonClipboardForMove!) : null;

// void clearUR() => ur.clear();
  //
  // bool get canUndo => ur.undoQ.isNotEmpty;
  //
  // bool get canRedo => ur.redoQ.isNotEmpty;
  //
  // int get undoCount => ur.undoQ.length;
  //
  // int get redoCount => ur.redoQ.length;
}
