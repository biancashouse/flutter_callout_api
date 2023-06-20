// import 'package:animated_tree_view/animated_tree_view.dart';
// import 'package:flutter_callout_api/callout_api.dart';
// import 'package:flutter_callout_api/src/content/nodes/src/enums.dart';
// import 'utils.dart';
// import 'package:flutter/material.dart';
//
// const double CARD_H = 50;
// const double PADDING = 10;
// const double ICON_SIZE = 32;
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Example Animated Indexed Tree Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHomePage(title: 'Pre populated Indexed TreeView sample'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key, required this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   late IndexedTreeNode<dynamic> rootNode;
//   IndexedTreeNode? selectedNode;
//   late GlobalKey wrapIconGK;
//
//   @override
//   void initState() {
//     rootNode = IndexedTreeNode.root();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: TreeView.indexed(
//           tree: rootNode,
//           expansionBehavior: ExpansionBehavior.none,
//           indentation: const Indentation(style: IndentStyle.roundJoint),
//           shrinkWrap: true,
//           showRootNode: true,
//           builder: _treeItemBuilder,
//           onItemTap: (node) {
//             setState(() {
//               selectedNode = node;
//             });
//           }),
//     );
//   }
//
//   Widget _treeItemBuilder(BuildContext context, IndexedTreeNode<dynamic> node) {
//     int fTypeIndex = node.meta?["fType"] ?? ContentTreeNodeType.UNKNOWN.index;
//     ContentTreeNodeType fType = ContentTreeNodeType.values.elementAt(fTypeIndex);
//     Size measuredTxtSize = calculateTextSize(text: fType.name, style: DefaultTextStyle.of(context).style, numLines: 6, context: context);
//     double cardW = measuredTxtSize.width + 100;
//
//     return node != selectedNode
//         ? SizedBox(
//             width: cardW,
//             height: CARD_H,
//             child: Card(
//               color: colorMapper[node.level.clamp(0, colorMapper.length - 1)]!,
//               child: Center(child: Text(fType.name)),
//             ),
//           )
//         : Container(
//             width: cardW,
//             // color: Colors.red.withOpacity(.1),
//             height: (node.isRoot ? 0: ICON_SIZE) * 4 + CARD_H,
//             child: Stack(
//               children: [
//                 // BEFORE BUTTON
//                 if (node == selectedNode && !node.isRoot)
//                   Align(
//                     alignment: Alignment.topRight,
//                     child: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           IndexedTreeNode newNode = IndexedTreeNode()
//                             ..meta = {}
//                             ..meta?["fType"] = ContentTreeNodeType.SizedBox.index;
//                           int? nodePos = node.parent?.insertBefore(node, newNode);
//                           selectedNode = null;
//                         });
//                       },
//                       icon: const Icon(Icons.arrow_back_outlined, color: Colors.green),
//                       iconSize: ICON_SIZE,
//                     ),
//                   ),
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Container(
//                     color: Colors.blue.withOpacity(.1),
//                     width: cardW,
//                     height: CARD_H + ICON_SIZE,
//                     child: Stack(
//                       children: [
//                         // WRAP BUTTON
//                         if (node == selectedNode && !node.isRoot)
//                           Align(
//                             alignment: Alignment.topLeft,
//                             child: IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   IndexedTreeNode newNode = IndexedTreeNode()
//                                     ..meta = {}
//                                     ..meta?["fType"] = ContentTreeNodeType.Padding.index;
//                                   node.insertBefore(node, newNode);
//                                   node.parent!.children.remove(node);
//                                   newNode.add(node);
//                                   selectedNode = null;
//                                 });
//                               },
//                               icon: const Icon(Icons.turn_sharp_left, color: Colors.green),
//                               iconSize: ICON_SIZE,
//                             ),
//                           ),
//                         // CARD
//                         Align(
//                           alignment: Alignment.centerLeft,
//                           child: Padding(
//                             padding: const EdgeInsets.only(left: ICON_SIZE + PADDING, top: PADDING, bottom: PADDING),
//                             child: Card(
//                               color: colorMapper[node.level.clamp(0, colorMapper.length - 1)]!,
//                               shape: const RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.all(Radius.circular(1306)),
//                               ),
//                               child: Text(fType.name),
//                             ),
//                           ),
//                         ),
//                         // APPEND CHILD BUTTON
//                         if (node == selectedNode)
//                           Align(
//                             alignment: Alignment.bottomRight,
//                             child: IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   IndexedTreeNode newNode = IndexedTreeNode()
//                                     ..meta = {}
//                                     ..meta?["fType"] = ContentTreeNodeType.Container.index;
//                                   node.add(newNode);
//                                   selectedNode = null;
//                                 });
//                               },
//                               icon: const Icon(Icons.subdirectory_arrow_right, color: Colors.green),
//                               iconSize: ICON_SIZE,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // AFTER BUTTON
//                 if (node == selectedNode && !node.isRoot)
//                   Align(
//                     alignment: Alignment.bottomRight,
//                     child: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           IndexedTreeNode newNode = IndexedTreeNode()
//                             ..meta = {}
//                             ..meta?["fType"] = ContentTreeNodeType.Center.index;
//                           int? nodePos = node.parent?.insertAfter(node, newNode);
//                           selectedNode = null;
//                         });
//                       },
//                       icon: const Icon(Icons.arrow_back_outlined, color: Colors.green),
//                       iconSize: ICON_SIZE,
//                     ),
//                   ),
//               ],
//             ),
//           );
//     //
//     // return switch (fType) {
//     //   ContentTreeNodeType.SizedBox => Card(
//     //       color: colorMapper[node.level.clamp(0, colorMapper.length - 1)]!,
//     //       child: Text(fType.name),
//     //     ),
//     //   ContentTreeNodeType.Card => Card(
//     //       color: colorMapper[node.level.clamp(0, colorMapper.length - 1)]!,
//     //       child: Text(fType.name),
//     //     ),
//     //   _ => Icon(Icons.question_mark)
//     // };
//   }
// }
//
// Map<ContentTreeNodeType, NodeChildren> possibleChildren = {ContentTreeNodeType.Text: NodeChildren.none};
