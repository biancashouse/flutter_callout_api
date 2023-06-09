// import 'package:flutter_callout_api/src/blink.dart';
// import 'package:flutter_callout_api/src/overlays/callouts/callout.dart';
// import 'package:flutter_callout_api/src/useful.dart';
// import 'package:flutter_callout_api/src/wrapper/app_wrapper.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
// import 'package:flutter_callout_api/src/bloc/capi_event.dart';
// import 'package:flutter_callout_api/src/callout_text_editor.dart';
// import 'package:flutter_callout_api/src/styles/styles_picker.dart';
// import 'package:flutter_callout_api/src/wrapper/buttons/copy_button.dart';
// import 'package:flutter_callout_api/src/wrapper/buttons/play_button_manual.dart';
// import 'package:flutter_callout_api/src/wrapper/image_wrapper_manual.dart';
//
// import '../../callout_api.dart';
// import '../model/target_config.dart';
// import '../wrapper/transformable_widget_wrapper.dart';
// import '../wrapper/widget_wrapper.dart';
//
// void refreshListViewCallout(final String iwName) => Useful.om.refreshCalloutByFeature(CAPI.TARGET_LISTVIEW_CALLOUT.feature(iwName), () {});
// //
// // void hideListViewCallout(final String iwName) => Useful.om.hideCalloutByFeature(CAPI.TARGET_LISTVIEW_CALLOUT.feature(iwName));
// //
// // void unhideListViewCallout(final String iwName) => Useful.om.unhideCalloutByFeature(CAPI.TARGET_LISTVIEW_CALLOUT.feature(iwName));
// //
// void removeListViewCallout(final String iwName) => Useful.om.remove(CAPI.TARGET_LISTVIEW_CALLOUT.feature(iwName), true);
//
// class CCTargetListViewContents extends StatelessWidget {
//   final ImageWrapperManualState parent;
//
//   const CCTargetListViewContents(this.parent, {super.key});
//
//   static double targetListH(final ImageWrapperManualState parent) => parent.bloc.state.imageTargets(parent.widget.iwName).length * 40;
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       children: <Widget>[
//         if (parent.bloc.state.imageTargetListMap.isNotEmpty)
//           SizedBox.fromSize(
//             size: Size(180, targetListH(parent)),
//             child: ReorderableListView(
//               onReorder: (int oldIndex, int newIndex) {
//                 ImageWrapperManualState.hideAllTargets(bloc: parent.bloc, iwName: parent.widget.iwName);
//                 parent.bloc.add(CAPIEvent.changedOrder(iwName: parent.widget.iwName, oldIndex: oldIndex, newIndex: newIndex));
//                 Useful.afterNextBuildDo(() {
//                   Useful.afterMsDelayDo(200, () {
//                     ImageWrapperManualState.showAllTargets(bloc: parent.bloc, iwName: parent.widget.iwName);
//                   });
//                 });
//               },
//               children: [
//                 // for (String iwName in state.imageTargetListMap.keys)
//                 for (int index = 0; index < (parent.bloc.state.imageTargetListMap[parent.widget.iwName]?.length ?? 0); index++)
//                   TargetItemView(
//                     key: UniqueKey(),
//                     parent,
//                     parent.bloc.state.imageTargetListMap[parent.widget.iwName]![index],
//                     index,
//                   ),
//               ],
//             ),
//           ),
//         Divider(
//           color: Colors.white,
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           child: PlayButton(parent),
//         ),
//         CopyButton(parent.widget.iwName),
//         // Spacer(),
//         // SuspendButton(parent.widget.iwName),
//       ],
//     );
//   }
// }
//
// class TargetItemView extends StatelessWidget {
//   final ImageWrapperManualState parent;
//   final TargetConfig tc;
//   final int index;
//
//   const TargetItemView(this.parent, this.tc, this.index, {super.key});
//
//   static Widget indexAvatar(TargetConfig tc, int index, bool isNotSelected) {
//     Color selectedColor = tc.calloutColorValue == Colors.white.value ? Colors.grey : Colors.white;
//     return SizedBox(
//       width: 120,
//       height: 30,
//       child: Blink(
//         bgColor: Colors.yellowAccent,
//         dontAnimate: !isNotSelected,
//         child: Row(
//           mainAxisSize: MainAxisSize.max,
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Expanded(
//               child: Container(
//                 decoration: ShapeDecoration(
//                   color: Color(tc.calloutColorValue ?? 128),
//                   shape: RoundedRectangleBorder(
//                     side: BorderSide(color: !isNotSelected ? selectedColor : Colors.grey, width: !isNotSelected ? 4 : 1),
//                     borderRadius: const BorderRadius.all(Radius.circular(8)),
//                   ),
//                 ),
//                 child: SizedBox(
//                   width: 160,
//                   child: Center(
//                       child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4.0),
//                     child: Text(
//                       ' ${tc.calloutDurationMs} ',
//                       style: TextStyle(color: Color(tc.textColorValue ?? 128), fontSize: 14),
//                     ),
//                   )),
//                 ),
//               ),
//             ),
//             IconButton(
//               onPressed: () {
//                 CAPIBloc.showStartTimeCallout(tc);
//               },
//               icon: Icon(
//                 Icons.timer,
//                 color: Colors.white,
//               ),
//               iconSize: 24,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dismissible(
//       direction: DismissDirection.horizontal,
//       key: UniqueKey(),
//       onDismissed: (_) async {
//         if (parent.bloc.state.aTargetIsSelected(parent.widget.iwName)) {
//           await clearSelection(parent, tappedTc: parent.bloc.state.selectedTarget(parent.widget.iwName)!);
//         }
//         ImageWrapperManualState.hideAllTargets(bloc: parent.bloc, iwName: parent.widget.iwName);
//         await Future.delayed(Duration(milliseconds: 300));
//         ImageWrapperManualState.showAllTargets(bloc: parent.bloc, iwName: parent.widget.iwName);
//         tc.bloc.add(CAPIEvent.deleteTarget(tc: tc));
//         Useful.afterNextBuildDo(() {
//           if (!tc.bloc.state.aTargetIsSelected(tc.twName)) {
//             Useful.afterMsDelayDo(200, () {
//               ImageWrapperManualState.showAllTargets(bloc: parent.bloc, iwName: parent.widget.iwName);
//             });
//           }
//         });
//       },
//       child: SizedBox(
//         child: InkWell(
//           onTap: () async {
//             if (tc.bloc.state.aTargetIsSelected(tc.twName)) {
//               // TransformableBodyWrapperState? swState = CAPIState.twGKMap[parent.widget.twName]?.currentState;
//               // swState?.resetTransform();
//               if (tc.uid != tc.bloc.state.selectedTarget(tc.twName)!.uid) {
//                 // tapped a different item to selected one
//                 removeTextEditorCallout();
//                 await clearSelection(parent, tappedTc: tc);
//                 ImageWrapperManualState.hideAllTargets(bloc: parent.bloc, iwName: parent.widget.iwName);
//                 tc.bloc.add(CAPIEvent.selectTarget(tc: tc));
//                 // Rect? rect = findGlobalRect(tc.gk());
//                 // if (rect != null) {
//                 //   Alignment ta = WidgetWrapper.calcTargetAlignment(rect);
//                 //   swState?.applyTransform(3.0, 3.0, ta);
//                 // }
//               } else {
//                 // tapped selected item - deselect
//                 await clearSelection(parent, tappedTc: tc);
//                 ImageWrapperManualState.hideAllTargets(bloc: parent.bloc, iwName: parent.widget.iwName);
//                 await Future.delayed(Duration(milliseconds: 300));
//                 ImageWrapperManualState.showAllTargets(bloc: parent.bloc, iwName: parent.widget.iwName);
//               }
//             } else {
//               // TransformableBodyWrapperState? swState = CAPIState.twGKMap[parent.widget.twName]?.currentState;
//               // Rect? rect = findGlobalRect(tc.gk());
//               // if (swState != null && rect != null) {
//               //   Alignment ta = WidgetWrapper.calcTargetAlignment(rect);
//               //   swState.applyTransform(3.0, 3.0, ta);
//               // }
//
//               tc.bloc.add(CAPIEvent.selectTarget(tc: tc));
//               ImageWrapperManualState.hideAllTargets(
//                   bloc: parent.bloc, iwName: parent.widget.iwName, exception: tc.bloc.state.selectedTargetIndex(tc.twName));
//             }
//           },
//           onDoubleTap: () {
//             // showStartTimeCallout(tc, tc.focusNode, tc.gk);
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(4.0),
//             child: TargetItemView.indexAvatar(tc, index, tc.bloc.state.selectedTargetIndex(tc.twName) == index),
//           ),
//         ),
//       ),
//     );
//   }
//
//   static Future<void> clearSelection(final ImageWrapperManualState parent, {required TargetConfig tappedTc}) async {
//     // Useful.om.remove(CAPI.ANY_TOAST.feature(), true);
//     removeTextEditorCallout();
//     removeStylesCallout();
//
//     // // for selected item, save (convert) current callout pos + transfrom matrix back to normal coords
//     TargetConfig selectedTc = parent.bloc.state.selectedTarget(parent.widget.iwName)!;
//     //   parent.bloc.state.CC_TARGET_RADIUS(parent.widget.iwName),
//     //   parent.bloc.state.CC_TARGET_RADIUS(parent.widget.iwName),
//     // ));
//
//     selectedTc.bloc.add(CAPIEvent.clearSelection(iwName: tappedTc.twName));
//   }
// }
//
// const double TARGET_LISTVIEW_CALLOUT_W = kIsWeb ? 180 : 140;
//
// void createAndShowTargetListCallout(final ImageWrapperManualState parent) {
//   // if (!state.imageTargetListMap.containsKey(iwName)) return;
//
//   double calloutH() {
//     double h = 300;
//     List<TargetConfig> list = parent.bloc.state.imageTargetListMap[parent.widget.iwName] ?? [];
//     h += list.length * 30;
//     // print("h(${bloc.state.selectedTargetIndex(widget.iwName)}) = $h");
//     return h;
//   }
//
//   Rect? ivRect = CAPIState.wwRect(parent.widget.iwName);
//
//   if (ivRect == null) return;
//
//   Offset targetListCalloutInitialPos = Offset(ivRect.right, ivRect.top - 40);
//
//   // Offset initialPos = stackMeasuredGlobalPos?.translate(-calloutW, stackMeasuredSize!.height - calloutH) ?? Offset.zero;
//   Callout(
//     feature: CAPI.TARGET_LISTVIEW_CALLOUT.feature(parent.widget.iwName),
//     color: Colors.transparent,
//     widthF: () => TARGET_LISTVIEW_CALLOUT_W,
//     heightF: () => calloutH(),
//     // resizeableV: true,
//     // dragHandle: const Icon(Icons.drag_indicator, color: Colors.grey,),
//     dragHandle: Container(
//       color: Colors.white12,
//       width: TARGET_LISTVIEW_CALLOUT_W,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Divider(
//             indent: 6,
//             endIndent: 6,
//             height: 10,
//             thickness: 2,
//             color: Colors.purpleAccent.withOpacity(.3),
//           ),
//           Divider(
//             indent: 6,
//             endIndent: 6,
//             height: 10,
//             thickness: 2,
//             color: Colors.purpleAccent.withOpacity(.3),
//           ),
//           Divider(
//             indent: 6,
//             endIndent: 6,
//             height: 10,
//             thickness: 2,
//             color: Colors.purpleAccent.withOpacity(.3),
//           ),
//           Divider(
//             indent: 6,
//             endIndent: 6,
//             height: 10,
//             thickness: 2,
//             color: Colors.purpleAccent.withOpacity(.3),
//           ),
//           Divider(
//             indent: 6,
//             endIndent: 6,
//             height: 10,
//             thickness: 2,
//             color: Colors.purpleAccent.withOpacity(.3),
//           ),
//         ],
//       ),
//     ),
//     dragHandleHeight: 50,
//     contents: () => Container(
//       padding: const EdgeInsets.all(12),
//       decoration: const ShapeDecoration(
//         color: Colors.purpleAccent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(10)),
//           side: BorderSide(color: Colors.black12),
//         ),
//       ),
//       child: CCTargetListViewContents(parent),
//     ),
//     initialCalloutPos: targetListCalloutInitialPos,
//     ignoreCalloutResult: true,
//     arrowType: ArrowType.NO_CONNECTOR,
//     // onExpiredF: () {
//     //   // Useful.afterMsDelayDo(500, () {
//     //   //   createAndShowTargetListCallout(bloc);
//     //   // });
//     // },
//   ).show(
//     notUsingHydratedStorage: true,
//   );
// }
