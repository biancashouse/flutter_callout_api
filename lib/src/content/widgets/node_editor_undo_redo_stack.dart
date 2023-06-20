// import 'dart:collection';
//
// import 'package:flutter_callout_api/src/content/nodes/content_nodes.dart';
//
//
// class NodeEditorUndoRedoStack {
//
//   Queue<Node> undoQ = Queue<Node>();
//   Queue<Node> redoQ = Queue<Node>();
//
//   NodeEditorUndoRedoStack();
//
//   void clear() {
//     undoQ.clear();
//     redoQ.clear();
//   }
//
//   void _pushUndo(Node theF) {
//     undoQ.addFirst(theF);
//   }
//
//   void _pushRedo(Node theF) {
//     redoQ.addFirst(theF);
//   }
//
//   Node? _popUndo() {
//     if (undoQ.isNotEmpty) {
//       Node poppedF = undoQ.removeFirst();
//       return poppedF;
//     } else {
//       return null;
//     }
//   }
//
//   Node? _popRedo() {
//     if (redoQ.isNotEmpty) {
//       return redoQ.removeFirst();
//     } else {
//       return null;
//     }
//   }
//
//   void createUndo({required Node node, bool pushClone = true}) {
//     _pushUndo(pushClone ? node.copyWith() : node);
//     redoQ.clear();
//   }
//
//   // // for the case where created an undo, but user clicked cancel x
//   // void removeLastUndo() {
//   //   _popUndo();
//   // }
//
//   Node? undo({bool skipRedo = false}) {
//     Node? restoredF;
//     if (undoQ.isNotEmpty) {
//       // TODO node.removeInsertersAndMovers();
//       if (!skipRedo) _pushRedo(node);
//       restoredF = _popUndo();
//     }
//     return restoredF;
//   }
//
//   Node? redo() {
//     Node? redidF;
//     if (redoQ.isNotEmpty) {
//       // TODO node.removeInsertersAndMovers();
//       _pushUndo(node);
//       redidF = _popRedo();
//       // TODO if (redidF != null) App.userBloc.state.clipboard(id) = redidF;
//       // developer.log('undoQ: ${undoQs.length}');
//       // developer.log('redoQ: ${redoQs.length}');
//     }
//     return redidF;
//   }
// }
