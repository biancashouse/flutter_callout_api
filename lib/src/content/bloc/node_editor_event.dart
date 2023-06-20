part of 'node_editor_bloc.dart';

@freezed
class NodeEditorEvent with _$NodeEditorEvent {
  const factory NodeEditorEvent.clearUR() = ClearUR;

  const factory NodeEditorEvent.forceRefresh() = ForceRefresh;

  const factory NodeEditorEvent.selectNode({
    required Node node,
    Node? nodeParent,
    required int nodeRootIndex,
    required bool showAdders,
  }) = SelectNode;

  const factory NodeEditorEvent.wrapWith({
    required Type type,
  }) = WrapWith;

  const factory NodeEditorEvent.addChild({
    required Type type,
  }) = AddChild;

  const factory NodeEditorEvent.addSiblingBefore({
    required Type type,
  }) = AddSiblingBefore;

  const factory NodeEditorEvent.addSiblingAfter({
    required Type type,
  }) = AddSiblingAfter;

  const factory NodeEditorEvent.clearSelection() = ClearSelection;

  const factory NodeEditorEvent.showAddersOrMovers({
    required Node tappedNode,
    required double tappedNodeVPos,
    required double tappedNodeVScroll,
    required String moverOrAdder,
  }) = ShowAddersOrMovers;

  const factory NodeEditorEvent.tappedEditorScaffoldBody({
    Node? movedNode,
  }) = TappedEditorScaffoldBody;

  const factory NodeEditorEvent.deleteNodeTapped() = DeleteNodeTapped;

  const factory NodeEditorEvent.addNode({
    required Node adder2InsertBefore,
  }) = AddNode;

  const factory NodeEditorEvent.copyNode({
    required Node node,
  }) = CopyNode;

  const factory NodeEditorEvent.cutNode({
    required Node node,
  }) = CutNode;

  const factory NodeEditorEvent.pasteNode({
    required Node adder,
  }) = PasteNode;

  const factory NodeEditorEvent.clearClipboard() = ClearClipboard;

  const factory NodeEditorEvent.createSnippet({
    required String name,
    required Node node,
  }) = CreateSnippet;

  const factory NodeEditorEvent.createUndo({
    required Node node,
    @Default(false) bool skipEmit,
  }) = CreateUndo;

  const factory NodeEditorEvent.undo({
    @Default(false) bool skipRedo,
  }) = Undo;

  const factory NodeEditorEvent.redo() = Redo;
}
