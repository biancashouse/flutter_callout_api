// import 'dart:async';
//
// import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
// import 'package:flutter_callout_api/src/bloc/capi_event.dart';
// import 'package:flutter_callout_api/src/bloc/capi_state.dart';
// import 'package:flutter_callout_api/src/measuring/find_global_pos.dart';
// import 'package:flutter_callout_api/src/measuring/find_global_rect.dart';
// import 'package:flutter_callout_api/src/measuring/measure_sizebox.dart';
// import 'package:flutter_callout_api/src/overlays/callouts/callout.dart';
// import 'package:flutter_callout_api/src/overlays/callouts/toast.dart';
// import 'package:flutter_callout_api/src/text_editing/text_editor.dart';
// import 'package:flutter_callout_api/src/useful.dart';
// import 'package:flutter_callout_api/src/wrapper/app_wrapper.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_callout_api/src/callout_ivrect.dart';
// import 'package:flutter_callout_api/src/callout_text_editor.dart';
// import 'package:flutter_callout_api/src/list/targetlistviewManual.dart';
// import 'package:flutter_callout_api/src/model/target_config.dart';
// import 'package:flutter_callout_api/src/styles/styles_picker.dart';
// import 'package:flutter_callout_api/src/wrapper/target.dart';
//
// class ImageWrapperManual extends StatefulWidget {
//   final String twName;
//   final String iwName;
//   final Widget child;
//   final ScrollController? ancestorHScrollController;
//   final ScrollController? ancestorVScrollController;
//   final double? suspendButtonLeft;
//   final double? suspendButtonRight;
//   final double? suspendButtonTop;
//   final double? suspendButtonBottom;
//   final double? aspectRatio;
//   final bool hardEdge;
//
//   ImageWrapperManual({
//     required this.twName,
//     required this.iwName,
//     required this.child,
//     this.ancestorHScrollController,
//     this.ancestorVScrollController,
//     this.suspendButtonLeft,
//     this.suspendButtonRight,
//     this.suspendButtonTop,
//     this.suspendButtonBottom,
//     this.aspectRatio,
//     this.hardEdge = true,
//     super.key,
//   });
//
//   @override
//   State<ImageWrapperManual> createState() => ImageWrapperManualState();
// }
//
// class ImageWrapperManualState extends State<ImageWrapperManual> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
//   late TransformationController transformationController;
//   late Animation<Offset> translationAnimation;
//   late Animation<Matrix4> matrix4Animation;
//   late AnimationController aController;
//
//   Offset? savedChildLocalPosPc;
//
//   Timer? showTextCalloutTimer;
//   Timer? ivUpdateDebounceTimer;
//   bool targetCreationInProgress = false;
//
//   double? scrollOffset;
//   Orientation? _lastO;
//
//   CAPIBloc get bloc => BlocProvider.of<CAPIBloc>(context);
//
//   late TargetConfig tcToPlay;
//
//   @override
//   void initState() {
//     super.initState();
//
//     transformationController = TransformationController();
//     aController = AnimationController(vsync: this, duration: DEFAULT_TRANSITION_DURATION_MS);
//
//     matrix4Animation = Matrix4Tween(
//       begin: Matrix4.identity(),
//       end: Matrix4.identity(),
//     ).animate(aController);
//
//     Useful.afterNextBuildDo(() {
//       // register ww with AppWrapper
//       measureIVPos();
//       // widget.ancestorScrollController?.addListener(() {
//       //   if (mounted) {
//       //     scrollOffset = widget.ancestorScrollController?.offset;
//       //     print("scroll: $scrollOffset");
//       //     Rect? rect = measureIV(afterMeasuringF: () {});
//       //     print("IV rect pos: ${rect?.topLeft.toString()}");
//       //   }
//       // });
//     });
//   }
//
//   void measureIVPos() {
//     Offset? globalPos;
//     try {
//       GlobalKey? iwGK = CAPIState.iwGKMap[widget.iwName];
//       if (iwGK != null) {
//         globalPos = findGlobalPos(iwGK);
//         // bool didChange = oldSize != newSize;
//         // if (didChange || force) {
//         //   removeIVRectCallout();
//         //   Useful.afterNextBuildDo(() {
//         //     sizeChangedF?.call(rect.size);
//         //     showIVRectCallout(this);
//         //   });
//         //   bloc.add(CAPIEvent.measuredIV(
//         //     iwName: widget.iwName,
//         //     ivRect: rect,
//         //   ));
//         // }
//       }
//     } catch (e) {
//       // ignore but then don't update pos
//     }
//     if (globalPos != null) {
//       CAPIState.iwPosMap[widget.iwName] = globalPos;
//     }
//   }
//
//   @override
//   void didChangeMetrics() {
//     print("***  didChangeMetrics  ***");
//     measureIVPos();
//   }
//
// // @override
// // void didUpdateWidget(Object oldWidget) {
// //   print("didUpdateWidget");
// // }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     aController.dispose();
//     super.dispose();
//   }
//
//   void onChangeTransformation() {
//     if (!bloc.state.aTargetIsSelected(widget.iwName) || (ivUpdateDebounceTimer?.isActive ?? false)) return;
//
//     ivUpdateDebounceTimer = Timer(const Duration(milliseconds: 50), () {
//       bloc.add(CAPIEvent.recordMatrix(iwName: widget.iwName, newMatrix: transformationController.value));
//       // Useful.afterNextBuildDo(() {
//       //   // removeTextEditorCallout();
//       //   if (bloc.state.aTargetIsSelected(widget.iwName)) {
//       //     Offset newPos = bloc.state
//       //         .selectedTarget(widget.iwName)!
//       //         .targetGlobalPos()
//       //         .translate(-bloc.state.CAPI_TARGET_RADIUS(widget.iwName), -bloc.state.CAPI_TARGET_RADIUS(widget.iwName));
//       // Callout.moveToByFeature(
//       //     CAPI.TARGET_CALLOUT.feature(bloc.state.selectedTarget(widget.iwName)!.iwName, bloc.state.selectedTargetIndex(widget.iwName)), newPos);
//       // }
//       // });
//     });
//   }
//
// // void _onChangeTransformation() {
// //   // print("_onChangeTransformation: ");
// //   if (isEditing && aTargetIsSelected(widget.iwName)) {
// //     selectedTarget!.matrix = transformationController.value.storage.toList();
// //     Matrix4 m = transformationController.value;
// //     math.Vector3 translation = math.Vector3.zero();
// //     math.Quaternion rotation = math.Quaternion.identity();
// //     math.Vector3 scale = math.Vector3.zero();
// //     m.decompose(translation, rotation, scale);
// //     ivScale = scale.b;
// //     ivTranslate = Offset(translation.x, translation.y);
// //   } else {
// //     // playing
// //     Matrix4 m = matrix4Animation.value;
// //     math.Vector3 translation = math.Vector3.zero();
// //     math.Quaternion rotation = math.Quaternion.identity();
// //     math.Vector3 scale = math.Vector3.zero();
// //     m.decompose(translation, rotation, scale);
// //     ivScale = scale.b;
// //     ivTranslate = Offset(translation.x, translation.y);
// //   }
// // }
//
// // void clearSelection({bool reshowAllTargets = true}) {
// //   bloc.add(CAPIEvent.clearSelection());
// //   if (aTargetIsSelected(widget.iwName)) {
// //     transformationController.removeListener(_onChangeTransformation);
// //     targetListGK.currentState?.setState(() {
// //       //measureIVchild();
// //       Callout? targetCallout = Useful.om.findCallout(CAPI.TARGET_CALLOUT.feature((featureSeed), selectedTargetIndex));
// //       if (targetCallout != null) {
// //         selectedTarget!.setTargetLocalPosPc(Offset(targetCallout.left!, targetCallout.top!));
// //         print("final callout pos (${targetCallout.left},${targetCallout.top})");
// //         print("targetGlobalPos now: ${selectedTarget!.targetGlobalPos()}");
// //       }
// //       ivScale = 1.0;
// //       ivTranslate = Offset.zero;
// //       print("new child local pos (${selectedTarget!.childLocalPosLeftPc},${selectedTarget!.childLocalPosTopPc})");
// //       // selectedTarget!.childLocalPosLeftPc = savedChildLocalPosPc!.dx;
// //       // selectedTarget!.childLocalPosTopPc = savedChildLocalPosPc!.dy;
// //       print("previous child local pos (${savedChildLocalPosPc!.dx},${savedChildLocalPosPc!.dy})");
// //       int saveSelection = selectedTargetIndex;
// //       selectedTargetIndex = -1;
// //       transformationController.value = Matrix4.identity();
// //       removeTextEditorCallout(this, selectedTargetIndex);
// //       removeTargetCallout(this, saveSelection);
// //     });
// //   }
// //   if (reshowAllTargets)
// //     // show all targets unselected
// //     Useful.afterMsDelayDo(500, () {
// //       showAllTargets();
// //       // for (var tc in targets) {
// //       //   showDraggableTargetCallout(this, tc, onReadyF: () {});
// //       // }
// //     });
// // }
//
//   BlocListener<CAPIBloc, CAPIState> _suspended() => BlocListener<CAPIBloc, CAPIState>(
//         listenWhen: (CAPIState previous, CAPIState current) {
//           return !previous.isSuspended(widget.iwName) && current.isSuspended(widget.iwName);
//         },
//         listener: (context, state) {
//           removeListViewCallout(widget.iwName);
//           hideAllTargets(bloc: bloc, iwName: widget.iwName);
//           removeTextEditorCallout();
//           removeIVRectCallout();
//         },
//       );
//
// // BlocListener<CAPIBloc, CAPIState> _resumed() => BlocListener<CAPIBloc, CAPIState>(
// //       listenWhen: (CAPIState previous, CAPIState current) {
// //         return previous.suspended(widget.iwName) && !current.suspended(widget.iwName);
// //       },
// //       listener: (context, state) {
// //       },
// //     );
//
//   BlocListener<CAPIBloc, CAPIState> _addedANewTarget() => BlocListener<CAPIBloc, CAPIState>(
//         listenWhen: (CAPIState previous, CAPIState current) {
//           return (current.numTargetsOnPage() != previous.numTargetsOnPage()
//               //&& current.selectedTarget == previous.selectedTarget
//               );
//         },
//         listener: (context, state) {
//           Callout? listViewCallout = Useful.om.findCallout(CAPI.TARGET_LISTVIEW_CALLOUT.feature(widget.iwName));
//           Useful.om.refreshCalloutByFeature(CAPI.TARGET_LISTVIEW_CALLOUT.feature(widget.iwName), () {
//             listViewCallout?.calloutSize = Size(TARGET_LISTVIEW_CALLOUT_W, 200 + CCTargetListViewContents.targetListH(this));
//           });
//         },
//       );
//
//   BlocListener<CAPIBloc, CAPIState> _justSelectedATarget() => BlocListener<CAPIBloc, CAPIState>(
//           // just selected a target
//           listenWhen: (CAPIState previous, CAPIState current) {
//         bool curr = current.aTargetIsSelected(widget.iwName);
//         bool prev = previous.aTargetIsSelected(widget.iwName);
//         bool b = current.aTargetIsSelected(widget.iwName) && !previous.aTargetIsSelected(widget.iwName);
//         return b;
//       }, listener: (context, state) {
//         // Useful.om.removeAllCalloutsExceptFor(exceptions: [
//         //   CAPI.TARGET_LISTVIEW_CALLOUT.feature(),
//         //   CAPI.TARGET_CALLOUT.feature(state.selectedTargetWrapperName, state.selectedTargetInde(widget.wiwName)x)
//         // ]);
//         TargetConfig selectedTc = state.selectedTarget(widget.iwName)!;
//         // savedChildLocalPosPc = Offset(state.selectedTarget!.childLocalPosLeftPc ?? 0, state.selectedTarget!.childLocalPosTopPc ?? 0);
//         Useful.afterNextBuildDo(() {
//           transformationController.value = selectedTc.getRecordedMatrix();
//           transformationController.addListener(onChangeTransformation);
//           showStylesCallout(selectedTc, widget.ancestorHScrollController, widget.ancestorVScrollController);
//           showTextEditorCallout(selectedTc, widget.ancestorHScrollController, widget.ancestorVScrollController);
//           WidgetToast(
//                   feature: CAPI.ANY_TOAST.feature(),
//                   backgroundColor: Colors.purpleAccent,
//                   widthF: () => Useful.scrW * .5,
//                   heightF: () => 150,
//                   gravity: Alignment.bottomCenter,
//                   contents: () => DefaultTextStyle(
//                         style: const TextStyle(fontSize: 24, color: Colors.white),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 18.0),
//                               child: Text("Target ${state.selectedTargetIndex(widget.iwName) + 1} Selected\nyou can now:"),
//                             ),
//                             const Text("- pan and zoom,\n- reposition the target,\n- reposition the callout"),
//                           ],
//                         ),
//                       ),
//                   gotitAxis: Axis.horizontal,
//                   onGotitPressedF: () {})
//               .show(removeAfterMs: SECS(20), notUsingHydratedStorage: true);
//         });
//       });
//
// // BlocListener<CAPIBloc, CAPIState> _justClearedSelection() => BlocListener<CAPIBloc, CAPIState>(
// //       // just cleared selection
// //       listenWhen: (CAPIState previous, CAPIState current) {
// //         return !current.aTargetIsSelected(widget.iwName) && previous.aTargetIsSelected(widget.iwName);
// //       },
// //       // stop listening to transformationcontroller
// //       listener: (context, state) {
// //         transformationController.value = Matrix4.identity();
// //         transformationController.removeListener(_onChangeTransformation);
// //         Useful.om.removeCalloutByFeature(CAPI.ANY_TOAST.feature(), true);
// //         removeTextEditorCallout();
// //         removeStylesCallout();
// //         removeAllTargets(state, widget.iwName);
// //         // refresh the deselected target
// //         if (!state.suspended(widget.iwName) && state.lastUpdatedTC != null) {
// //           int i = state.imageTargetListMap[state.lastUpdatedTC!.iwName]?.indexOf(state.lastUpdatedTC!) ?? -1;
// //           if (i > -1) {
// //             Offset deselectedPos = state.lastUpdatedTC!.targetGlobalPos();
// //             // Callout.moveToByFeature(CAPI.TARGET_CALLOUT.feature(widget.iwName, i), deselectedPos);
// //             _targetCreationInProgress = true;
// //             removeTargetCallout(widget.iwName, i);
// //             showDraggableTargetCallout(state.lastUpdatedTC!, onReadyF: () {
// //               _targetCreationInProgress = false;
// //             });
// //           }
// //         }
// //       },
// //     );
//
// // BlocListener<CAPIBloc, CAPIState> _getReadyToStartPlaying() => BlocListener<CAPIBloc, CAPIState>(
// //       // start playing a target
// //       listenWhen: (CAPIState previous, CAPIState current) {
// //         return !current.isPlaying && previous.playList.isEmpty && current.playList.isNotEmpty;
// //       },
// //       // stop listening to transformationcontroller
// //       listener: (context, state) async {
// //       },
// //     );
//
//   BlocListener<CAPIBloc, CAPIState> _playATarget() => BlocListener<CAPIBloc, CAPIState>(
//         // start playing a target
//         listenWhen: (CAPIState previous, CAPIState current) {
//           return previous.playList(widget.iwName).length != current.playList(widget.iwName).length;
//         },
//         listener: (context, state) {
//           if (state.playList(widget.iwName).isNotEmpty) {
//             tcToPlay = state.playList(widget.iwName)[0];
//             matrix4Animation = Matrix4Tween(
//               begin: Matrix4.identity(),
//               end: tcToPlay.getRecordedMatrix(),
//             ).animate(aController);
//             aController.forward().then((_) {
//               tcToPlay.visible = true;
//               Callout(
//                 targetGKF: tcToPlay.gk,
//                 feature: CAPI.TEXT_CALLOUT.feature(),
//                 color: tcToPlay.calloutColor(),
//                 widthF: () => tcToPlay.calloutWidth,
//                 heightF: () => tcToPlay.calloutHeight,
//                 contents: () => Padding(
//                   padding: const EdgeInsets.all(TextEditor.CONTENT_PADDING),
//                   child: RichText(
//                     textAlign: tcToPlay.textAlign(),
//                     text: TextSpan(
//                       style: tcToPlay.textStyle(),
//                       text: tcToPlay.text(),
//                     ),
//                   ),
//                 ),
//                 separation: 30,
//                 initialCalloutPos: tcToPlay.getTextCalloutPos(),
//                 onExpiredF: () async {
//                   await aController.reverse();
//                   if (state.playList(widget.iwName).length > 1)
//                     bloc.add(CAPIEvent.playNext(iwName: widget.iwName));
//                   else
//                     _playEnded();
//                 },
//                 ignoreCalloutResult: true,
//                 arrowColor: Color(tcToPlay.calloutColorValue!),
//                 arrowType: tcToPlay.getArrowType(),
//                 animate: tcToPlay.animateArrow,
//               ).show(
//                 removeAfterMs: tcToPlay.calloutDurationMs,
//                 notUsingHydratedStorage: true,
//               );
//             });
//           }
//         },
//       );
//
//   void _playEnded() {
//     bloc.add(CAPIEvent.playNext(iwName: widget.iwName)); //sets playlist empty
//     transformationController.value = Matrix4.identity();
//     transformationController.addListener(onChangeTransformation);
//     // hideAllTargets();
//     onChangeTransformation();
//     // Useful.afterNextBuildDo(() {
//     //   showAllTargets();
//     // });
//     // if (bloc.state.aTargetIsSelected(widget.iwName)) {
//     //   TargetItemView.clearSelection(this, tappedTc: bloc.state.selectedTarget(widget.iwName)!);
//     // }
//     createAndShowTargetListCallout(this);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return NotificationListener<SizeChangedLayoutNotification>(
//       onNotification: (SizeChangedLayoutNotification notification) {
//         print("CAPIWidgetWrapperState on Size Change Notification - ${widget.iwName}");
//         removeIVRectCallout();
//         removeListViewCallout(widget.iwName);
//         ImageWrapperManualState.hideAllTargets(bloc: bloc, iwName: widget.iwName);
//         measureIVPos();
//         if (bloc.state.isSuspended(widget.iwName)) {
//           Useful.afterMsDelayDo(1000, () {
//             measureIVPos();
//             // showIVRectCallout(this);
//             // CAPIWidgetWrapperState.showAllTargets(bloc: bloc, iwName: widget.iwName);
//             // createAndShowTargetListCallout(this);
//           });
//         } else
//           _suspendResumeButtonPressF(forceSuspend: true);
//         return true;
//       },
//       child: SizeChangedLayoutNotifier(
//         child: MultiBlocListener(
//           listeners: [
//             _suspended(),
//             // _resumed(),
//             _addedANewTarget(),
//             _justSelectedATarget(),
//             // _justClearedSelection(),
//             // _getReadyToStartPlaying(),
//             _playATarget(),
//             // _playEnded(),
//           ],
//           child: BlocBuilder<CAPIBloc, CAPIState>(buildWhen: (previous, current) {
//             // suspendws OR resumed OR selection changed
//             return previous.isSuspended(widget.iwName) != current.isSuspended(widget.iwName) ||
//                 previous.selectedTarget(widget.iwName) != current.selectedTarget(widget.iwName) ||
//                 previous.isPlaying != current.isPlaying;
//           }, builder: (context, state) {
//             // print("--- ${widget.iwName} builder");
//             return Material(
//               child: Stack(
//                 clipBehavior: widget.hardEdge ? Clip.hardEdge : Clip.none,
//                 children: [
//                   if (state.isSuspended(widget.iwName) || !CAPIState.iwPosMap.containsKey(widget.iwName))
//                     // NORMAL BUILD ---------------------------------------------
//                     _suspendedBuild(),
//                   // long pressable barrier
//                   // PREVENT ACCIDENTAL APP EVENTS SUCH AS NAVIGATING AWAY
//                   if (!state.isSuspended(widget.iwName) && !state.aTargetIsSelected(widget.iwName))
//                     GestureDetector(
//                       key: CAPIState.iwGKMap[widget.iwName] = GlobalKey(),
//                       // long press creates a new target for this TargetWrapper
//                       onLongPressStart: (LongPressStartDetails details) {
//                         if (!state.aTargetIsSelected(widget.iwName)) {
//                           hideAllTargets(bloc: bloc, iwName: widget.iwName);
//                           bloc.add(
//                             CAPIEvent.newTargetManual(
//                               iwName: widget.iwName,
//                               newGlobalPos: details.globalPosition.translate(
//                                 widget.ancestorHScrollController?.offset ?? 0.0,
//                                 widget.ancestorVScrollController?.offset ?? 0.0,
//                               ),
//                             ),
//                           );
//                           // Useful.afterNextBuildDo(() {
//                           //   TargetConfig? newestTarget = bloc.state.newestTarget(widget.iwName);
//                           //   newestTarget?.setTargetStackPosPc(details.globalPosition);
//                           // });
//                         }
//                       },
//                       child: SizedBox.fromSize(
//                         size: CAPIState.iwSize(widget.iwName),
//                         child: ModalBarrier(
//                           color: !state.isPlaying(widget.iwName) ? Colors.purple.withOpacity(.25) : null,
//                           dismissible: false,
//                         ),
//                       ),
//                     ),
//                   // --
//                   // NORMAL BUILD ---------------------------------------------
//                   // --
//                   //TARGET SELECTED
//                   if (!state.isSuspended(widget.iwName) && state.aTargetIsSelected(widget.iwName))
//                     // only render an IV when a target is selected
//                     _selectedTargetBuild(state),
//                   // --
//                   if (!state.isSuspended(widget.iwName) && !state.aTargetIsSelected(widget.iwName))
//                     // when no selection, render with current (possibly animating) transform
//                     _noSelectionBuild(state),
//                   if (!state.isSuspended(widget.iwName) && !state.aTargetIsSelected(widget.iwName) && !state.isPlaying(widget.iwName))
//                     for (var tc in state.imageTargets(widget.iwName)) buildPositionedDraggableTarget(tc),
//                   if (!state.isSuspended(widget.iwName) && !state.aTargetIsSelected(widget.iwName) && !state.isPlaying(widget.iwName))
//                     for (var tc in state.imageTargets(widget.iwName).where((el) => el.showBtn)) buildPositionedDraggableTargetBtn(tc),
//                   if (!state.isSuspended(widget.iwName) && (state.aTargetIsSelected(widget.iwName)))
//                     buildPositionedDraggableTarget(state.selectedTarget(widget.iwName)!),
//                   if (state.isPlaying(widget.iwName)) buildPositionedTargetForPlay(tcToPlay),
//                   // --
//                   // if (state.suspended(widget.iwName))
//                   Positioned(
//                     left: (widget.suspendButtonLeft == null && widget.suspendButtonRight == null) ? -20 : widget.suspendButtonLeft,
//                     right: widget.suspendButtonRight,
//                     bottom: (widget.suspendButtonTop == null && widget.suspendButtonBottom == null) ? -20 : widget.suspendButtonBottom,
//                     top: widget.suspendButtonTop,
//                     child: CircleAvatar(
//                       backgroundColor: Colors.purpleAccent.withOpacity(!bloc.state.isSuspended(widget.iwName) ? 1.0 : 0.3),
//                       radius: 30,
//                       child: IconButton(
//                         icon: const Icon(
//                           Icons.menu,
//                           color: Colors.white,
//                         ),
//                         onPressed: _suspendResumeButtonPressF,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//             // cannot show any CC functionality until not suspended and have measured the child (i.e. after 1st build)
//           }),
//         ),
//       ),
//     );
//   }
//
//   void _suspendResumeButtonPressF({bool forceSuspend = false}) {
//     if (!forceSuspend && bloc.state.isSuspended(widget.iwName)) {
//       bloc.add(CAPIEvent.resume(iwName: widget.iwName));
//       Useful.afterNextBuildDo(() {
//         removeListViewCallout(widget.iwName);
//         Useful.afterMsDelayDo(200, () {
//           showAllTargets(bloc: bloc, iwName: widget.iwName);
//           createAndShowTargetListCallout(this);
//           showIVRectCalloutManual(this);
//           CAPIState state = bloc.state;
//           print(state.suspendedMap.toString());
//           // possibly reshow targetlistview and targets
//         });
//       });
//     } else {
//       removeListViewCallout(widget.iwName);
//       hideAllTargets(bloc: bloc, iwName: widget.iwName);
//       removeTextEditorCallout();
//       removeIVRectCallout();
//       bloc.add(CAPIEvent.suspend(iwName: widget.iwName));
//     }
//   }
//
//   Positioned buildPositionedDraggableTarget(TargetConfig tc) {
//     return Positioned(
//       top: tc.targetStackPos().dy - tc.radius,
//       left: tc.targetStackPos().dx - tc.radius,
//       child: Draggable(
//         feedback: _draggableTargetBeingDragged(tc),
//         child: _draggableTargetNotBeingDragged(tc),
//         childWhenDragging: Offstage(),
//         onDragUpdate: (DragUpdateDetails details) {
//           Offset newGlobalPos = details.globalPosition.translate(
//             widget.ancestorHScrollController?.offset ?? 0.0,
//             widget.ancestorVScrollController?.offset ?? 0.0,
//           );
//           tc.setTargetStackPosPc(newGlobalPos);
//           // Callout.updateTargetPosByFeature(CAPI.TEXT_CALLOUT.feature(), details.globalPosition);
//           bloc.add(CAPIEvent.targetMoved(tc: tc, newGlobalPos: newGlobalPos));
//         },
//         onDragStarted: () {
//           removeTextEditorCallout();
//         },
//         onDragEnd: (DraggableDetails details) {
//           Offset newGlobalPos = details.offset.translate(
//             widget.ancestorHScrollController?.offset ?? 0.0,
//             widget.ancestorVScrollController?.offset ?? 0.0,
//           );
//           tc.setTargetStackPosPc(newGlobalPos);
//           // Callout.updateTargetPosByFeature(CAPI.TEXT_CALLOUT.feature(), details.offset);
//           bloc.add(CAPIEvent.targetMoved(tc: tc, newGlobalPos: newGlobalPos));
//           Useful.afterNextBuildDo(() {
//             if (bloc.state.aTargetIsSelected(widget.iwName))
//               showTextEditorCallout(
//                 tc,
//                 widget.ancestorHScrollController,
//                 widget.ancestorVScrollController,
//               );
//           });
//         },
//       ),
//     );
//   }
//
//   Widget _draggableTargetNotBeingDragged(tc) {
//     return SizedBox(
//       width: tc.radius * 2,
//       height: tc.radius * 2,
//       child: Stack(
//         children: [
//           Positioned(
//             top: tc.radius,
//             left: tc.radius,
//             child: SizedBox(
//               key: tc.gk(),
//               width: 1,
//               height: 1,
//             ),
//           ),
//           Align(
//             alignment: Alignment.topLeft,
//             child: IntegerCircleAvatar(
//               tc,
//               num: bloc.state.targetIndex(tc) + 1,
//               bgColor: Colors.yellow.withOpacity(.2),
//               radius: tc.radius,
//               textColor: Colors.white,
//               fontSize: 18,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _draggableTargetBeingDragged(tc) {
//     return SizedBox(
//       width: tc.radius * 2,
//       height: tc.radius * 2,
//       child: Target(
//         radius: tc.radius,
//       ),
//     );
//   }
//
//   Positioned buildPositionedDraggableTargetBtn(TargetConfig tc) {
//     return Positioned(
//       top: tc.btnStackPos().dy - bloc.state.CAPI_TARGET_BTN_RADIUS,
//       left: tc.btnStackPos().dx - bloc.state.CAPI_TARGET_BTN_RADIUS,
//       child: Draggable(
//         childWhenDragging: Offstage(),
//         feedback: IntegerCircleAvatar(
//           tc,
//           num: bloc.state.targetIndex(tc) + 1,
//           bgColor: tc.calloutColor(),
//           radius: bloc.state.CAPI_TARGET_BTN_RADIUS,
//           textColor: Color(tc.textColorValue ?? Colors.white.value),
//           fontSize: 14,
//         ),
//         child: IntegerCircleAvatar(
//           tc,
//           num: bloc.state.targetIndex(tc) + 1,
//           bgColor: tc.calloutColor(),
//           radius: bloc.state.CAPI_TARGET_BTN_RADIUS,
//           textColor: Color(tc.textColorValue ?? Colors.white.value),
//           fontSize: 14,
//         ),
//         onDragUpdate: (DragUpdateDetails details) {
//           Offset newGlobalPos = details.globalPosition.translate(
//             widget.ancestorHScrollController?.offset ?? 0.0,
//             widget.ancestorVScrollController?.offset ?? 0.0,
//           );
//           tc.setBtnStackPosPc(newGlobalPos);
//           bloc.add(CAPIEvent.btnMoved(tc: tc, newGlobalPos: newGlobalPos));
//         },
//         onDragEnd: (DraggableDetails details) {
//           Offset newGlobalPos = details.offset.translate(
//             widget.ancestorHScrollController?.offset ?? 0.0,
//             widget.ancestorVScrollController?.offset ?? 0.0,
//           );
//           tc.setBtnStackPosPc(newGlobalPos);
//           bloc.add(CAPIEvent.btnMoved(tc: tc, newGlobalPos: newGlobalPos));
//         },
//       ),
//     );
//   }
//
//   Positioned buildPositionedTargetForPlay(TargetConfig tc) {
//     double radius = tc.radius*tc.getScale();
//     return Positioned(
//       top: tc.targetStackPos().dy-radius,
//       left: tc.targetStackPos().dx-radius,
//       child: Container(
//         decoration: BoxDecoration(color: FUCHSIA_X.withOpacity(.2), shape: BoxShape.circle),
//         //color:Colors.pink.withOpacity(.2),
//         key: tc.gk(),
//         width: radius*2,
//         height: radius*2,
//       ),
//     );
//   }
//
//   Widget _suspendedBuild() => MeasureSizeBox(
//         key: CAPIState.iwGKMap[widget.iwName] = GlobalKey(),
//         onSizedCallback: (Size size) {
//           CAPIState.iwSizeMap[widget.iwName] = size;
//           // print("MeasureSizeBox => ${size.toString()}");
//         },
//         child: widget.aspectRatio != null
//             ? AspectRatio(
//                 aspectRatio: widget.aspectRatio!,
//                 child: widget.child,
//               )
//             : widget.child,
//       );
//
//   Widget _selectedTargetBuild(CAPIState state) {
//     TargetConfig st = state.selectedTarget(widget.iwName)!;
//     print("_selectedTargetBuild");
//     print("recordedScale      ${st.recordedScale}");
//     print("recordedTranslateX ${st.getTranslate().dx}");
//     print("recordedTranslateY ${st.getTranslate().dy}");
//     return InteractiveViewer(
//       key: CAPIState.iwGKMap[widget.iwName] = GlobalKey(),
//       scaleEnabled: state.aTargetIsSelected(widget.iwName),
//       //selectedTarget != -1,
//       panEnabled: state.aTargetIsSelected(widget.iwName),
//       //selectedTarget != -1,
//       minScale: .25,
//       maxScale: 8,
//       transformationController: transformationController,
//       onInteractionStart: (_) {
//         showTextCalloutTimer?.cancel();
//         if (state.aTargetIsSelected(widget.iwName)) {
//           removeTextEditorCallout();
//         }
//       },
//       child: IgnorePointer(
//         child: widget.aspectRatio != null
//             ? AspectRatio(
//                 aspectRatio: widget.aspectRatio!,
//                 child: widget.child,
//               )
//             : widget.child,
//       ),
//     );
//   }
//
//   Widget _noSelectionBuild(state) {
//     // print("_noSelectionBuild");
//     return SizedBox.fromSize(
//       size: CAPIState.iwSize(widget.iwName),
//       child: AnimatedBuilder(
//         animation: aController,
//         builder: (BuildContext context, _) {
//           return Transform(
//             transform: matrix4Animation.value,
//             // transform: matrix4Animation.value,
//             child: IgnorePointer(
//               child: widget.child,
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   static void hideAllTargets({required CAPIBloc bloc, required String iwName, final int? exception}) {
//     List<TargetConfig> list = bloc.state.imageTargets(iwName);
//     for (int i = 0; i < list.length; i++) {
//       if (i != exception) bloc.state.target(iwName, i)?.visible = false;
//     }
//   }
//
//   static void showAllTargets({required CAPIBloc bloc, required String iwName}) {
//     if (!bloc.state.aTargetIsSelected(iwName)) {
//       for (TargetConfig tc in bloc.state.imageTargets(iwName)) {
//         tc.visible = true;
//       }
//     }
//   }
// }
//
// class IntegerCircleAvatar extends StatelessWidget {
//   final TargetConfig tc;
//   final int? num;
//   final Color textColor;
//   final Color bgColor;
//   final bool selected;
//   final double radius;
//   final double fontSize;
//
//   const IntegerCircleAvatar(this.tc,
//       {this.num, required this.textColor, required this.bgColor, required this.radius, required this.fontSize, this.selected = false, super.key});
//
//   @override
//   Widget build(BuildContext context) => CircleAvatar(
//         backgroundColor: Colors.grey.withOpacity(.25),
//         radius: radius,
//         child: CircleAvatar(
//           foregroundColor: textColor,
//           backgroundColor: bgColor,
//           radius: radius,
//           child: tc.bloc.state.aTargetIsSelected(tc.twName) ? null : Text('${num}', style: TextStyle(color: textColor, fontSize: fontSize)),
//         ),
//       );
// }
