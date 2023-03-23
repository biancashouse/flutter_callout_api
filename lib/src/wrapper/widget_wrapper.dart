import 'dart:async';

import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_event.dart';
import 'package:flutter_callout_api/src/bloc/capi_state.dart';
import 'package:flutter_callout_api/src/measuring/find_global_pos.dart';
import 'package:flutter_callout_api/src/measuring/find_global_rect.dart';
import 'package:flutter_callout_api/src/measuring/measure_sizebox.dart';
import 'package:flutter_callout_api/src/overlays/callouts/callout.dart';
import 'package:flutter_callout_api/src/overlays/callouts/toast.dart';
import 'package:flutter_callout_api/src/text_editing/text_editor.dart';
import 'package:flutter_callout_api/src/useful.dart';
import 'package:flutter_callout_api/src/wrapper/app_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/src/callout_ivrect.dart';
import 'package:flutter_callout_api/src/callout_text_editor.dart';
import 'package:flutter_callout_api/src/list/targetlistview.dart';
import 'package:flutter_callout_api/src/model/target_config.dart';
import 'package:flutter_callout_api/src/styles/styles_picker.dart';
import 'package:flutter_callout_api/src/wrapper/target.dart';

class CAPIWidgetWrapper extends StatefulWidget {
  final String wwName;
  final Widget child;
  final ScrollController? ancestorScrollController;
  final double? suspendButtonLeft;
  final double? suspendButtonRight;
  final double? suspendButtonTop;
  final double? suspendButtonBottom;
  final double? aspectRatio;
  final bool hardEdge;

  CAPIWidgetWrapper({
    required this.wwName,
    required this.child,
    this.ancestorScrollController,
    this.suspendButtonLeft,
    this.suspendButtonRight,
    this.suspendButtonTop,
    this.suspendButtonBottom,
    this.aspectRatio,
    this.hardEdge = true,
    super.key,
  });

  @override
  State<CAPIWidgetWrapper> createState() => CAPIWidgetWrapperState();
}

class CAPIWidgetWrapperState extends State<CAPIWidgetWrapper> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TransformationController transformationController;
  late Animation<Offset> translationAnimation;
  late Animation<Matrix4> matrix4Animation;
  late AnimationController aController;

  Offset? savedChildLocalPosPc;

  Timer? showTextCalloutTimer;
  Timer? ivUpdateDebounceTimer;
  bool targetCreationInProgress = false;

  double? scrollOffset;
  Orientation? _lastO;

  CAPIBloc get bloc => BlocProvider.of<CAPIBloc>(context);

  late TargetConfig tcToPlay;

  @override
  void initState() {
    super.initState();

    transformationController = TransformationController();
    aController = AnimationController(vsync: this, duration: DEFAULT_TRANSITION_DURATION_MS);

    matrix4Animation = Matrix4Tween(
      begin: Matrix4.identity(),
      end: Matrix4.identity(),
    ).animate(aController);

    Useful.afterNextBuildDo(() {
      // register ww with AppWrapper
      measureIVPos();
      // widget.ancestorScrollController?.addListener(() {
      //   if (mounted) {
      //     scrollOffset = widget.ancestorScrollController?.offset;
      //     print("scroll: $scrollOffset");
      //     Rect? rect = measureIV(afterMeasuringF: () {});
      //     print("IV rect pos: ${rect?.topLeft.toString()}");
      //   }
      // });
    });
  }

  /// return whether IV size has changed
  void measureIVPos() {
    Offset? globalPos;
    try {
      GlobalKey? wwGK = CAPIAppWrapper.wwGKMap[widget.wwName];
      if (wwGK != null) {
        globalPos = findGlobalPos(wwGK);
        // bool didChange = oldSize != newSize;
        // if (didChange || force) {
        //   removeIVRectCallout();
        //   Useful.afterNextBuildDo(() {
        //     sizeChangedF?.call(rect.size);
        //     showIVRectCallout(this);
        //   });
        //   bloc.add(CAPIEvent.measuredIV(
        //     wwName: widget.wwName,
        //     ivRect: rect,
        //   ));
        // }
      }
    } catch (e) {
      // ignore but then don't update pos
    }
    if (globalPos != null) {
      CAPIAppWrapper.wwPosMap[widget.wwName] = globalPos;
    }
  }

  @override
  void didChangeMetrics() {
    print("***  didChangeMetrics  ***");
    measureIVPos();
  }

// void _possiblyRefreshCallouts() {
//   print("_possiblyRefreshCallouts");
//   if (bloc.state.aTargetIsSelected(widget.wwName)) {
//     Useful.afterMsDelayDo(50, () {
//       TargetConfig tc = bloc.state.selectedTarget!;
//       Size scaledSize = bloc.state.scaledIVChildSize(bloc.state.selectedTargetWrapperName!, tc.scale);
//       Offset ivPos = bloc.state.ivPos(bloc.state.selectedTargetWrapperName!);
//       Offset newPos = bloc.state.selectedTarget!.targetGlobalPos(scaledSize, ivPos);
//       Callout.moveToByFeature(CAPI.TARGET_CALLOUT.feature(widget.wwName, bloc.state.selectedTargetIndex(widget.wwName)), newPos);
//       Callout.moveToByFeature(CAPI.TEXT_CALLOUT.feature(), tc.calloutPos());
//     });
//   }
// }

  @override
  void didChangeDependencies() {
    Useful.instance.initWithContext(context, force: true);
    super.didChangeDependencies();
  }

// @override
// void didUpdateWidget(Object oldWidget) {
//   print("didUpdateWidget");
// }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    aController.dispose();
    super.dispose();
  }

  void onChangeTransformation() {
    if (!bloc.state.aTargetIsSelected(widget.wwName) || (ivUpdateDebounceTimer?.isActive ?? false)) return;

    ivUpdateDebounceTimer = Timer(const Duration(milliseconds: 50), () {
      bloc.add(CAPIEvent.recordMatrix(wwName: widget.wwName, newMatrix: transformationController.value));
      // Useful.afterNextBuildDo(() {
      //   // removeTextEditorCallout();
      //   if (bloc.state.aTargetIsSelected(widget.wwName)) {
      //     Offset newPos = bloc.state
      //         .selectedTarget(widget.wwName)!
      //         .targetGlobalPos()
      //         .translate(-bloc.state.CAPI_TARGET_RADIUS(widget.wwName), -bloc.state.CAPI_TARGET_RADIUS(widget.wwName));
      // Callout.moveToByFeature(
      //     CAPI.TARGET_CALLOUT.feature(bloc.state.selectedTarget(widget.wwName)!.wwName, bloc.state.selectedTargetIndex(widget.wwName)), newPos);
      // }
      // });
    });
  }

// void _onChangeTransformation() {
//   // print("_onChangeTransformation: ");
//   if (isEditing && aTargetIsSelected(widget.wwName)) {
//     selectedTarget!.matrix = transformationController.value.storage.toList();
//     Matrix4 m = transformationController.value;
//     math.Vector3 translation = math.Vector3.zero();
//     math.Quaternion rotation = math.Quaternion.identity();
//     math.Vector3 scale = math.Vector3.zero();
//     m.decompose(translation, rotation, scale);
//     ivScale = scale.b;
//     ivTranslate = Offset(translation.x, translation.y);
//   } else {
//     // playing
//     Matrix4 m = matrix4Animation.value;
//     math.Vector3 translation = math.Vector3.zero();
//     math.Quaternion rotation = math.Quaternion.identity();
//     math.Vector3 scale = math.Vector3.zero();
//     m.decompose(translation, rotation, scale);
//     ivScale = scale.b;
//     ivTranslate = Offset(translation.x, translation.y);
//   }
// }

// void clearSelection({bool reshowAllTargets = true}) {
//   bloc.add(CAPIEvent.clearSelection());
//   if (aTargetIsSelected(widget.wwName)) {
//     transformationController.removeListener(_onChangeTransformation);
//     targetListGK.currentState?.setState(() {
//       //measureIVchild();
//       Callout? targetCallout = Useful.om.findCallout(CAPI.TARGET_CALLOUT.feature((featureSeed), selectedTargetIndex));
//       if (targetCallout != null) {
//         selectedTarget!.setTargetLocalPosPc(Offset(targetCallout.left!, targetCallout.top!));
//         print("final callout pos (${targetCallout.left},${targetCallout.top})");
//         print("targetGlobalPos now: ${selectedTarget!.targetGlobalPos()}");
//       }
//       ivScale = 1.0;
//       ivTranslate = Offset.zero;
//       print("new child local pos (${selectedTarget!.childLocalPosLeftPc},${selectedTarget!.childLocalPosTopPc})");
//       // selectedTarget!.childLocalPosLeftPc = savedChildLocalPosPc!.dx;
//       // selectedTarget!.childLocalPosTopPc = savedChildLocalPosPc!.dy;
//       print("previous child local pos (${savedChildLocalPosPc!.dx},${savedChildLocalPosPc!.dy})");
//       int saveSelection = selectedTargetIndex;
//       selectedTargetIndex = -1;
//       transformationController.value = Matrix4.identity();
//       removeTextEditorCallout(this, selectedTargetIndex);
//       removeTargetCallout(this, saveSelection);
//     });
//   }
//   if (reshowAllTargets)
//     // show all targets unselected
//     Useful.afterMsDelayDo(500, () {
//       showAllTargets();
//       // for (var tc in targets) {
//       //   showDraggableTargetCallout(this, tc, onReadyF: () {});
//       // }
//     });
// }

  BlocListener<CAPIBloc, CAPIState> _suspended() => BlocListener<CAPIBloc, CAPIState>(
        listenWhen: (CAPIState previous, CAPIState current) {
          return !previous.isSuspended(widget.wwName) && current.isSuspended(widget.wwName);
        },
        listener: (context, state) {
          removeListViewCallout(widget.wwName);
          hideAllTargets(bloc: bloc, wwName: widget.wwName);
          removeTextEditorCallout();
          removeIVRectCallout();
        },
      );

// BlocListener<CAPIBloc, CAPIState> _resumed() => BlocListener<CAPIBloc, CAPIState>(
//       listenWhen: (CAPIState previous, CAPIState current) {
//         return previous.suspended(widget.wwName) && !current.suspended(widget.wwName);
//       },
//       listener: (context, state) {
//       },
//     );

  BlocListener<CAPIBloc, CAPIState> _addedANewTarget() => BlocListener<CAPIBloc, CAPIState>(
        listenWhen: (CAPIState previous, CAPIState current) {
          return (current.numTargetsOnPage() != previous.numTargetsOnPage()
              //&& current.selectedTarget == previous.selectedTarget
              );
        },
        listener: (context, state) {
          Callout? listViewCallout = Useful.om.findCallout(CAPI.TARGET_LISTVIEW_CALLOUT.feature(widget.wwName));
          Useful.om.refreshCalloutByFeature(CAPI.TARGET_LISTVIEW_CALLOUT.feature(widget.wwName), () {
            listViewCallout?.calloutSize = Size(TARGET_LISTVIEW_CALLOUT_W, 200 + CCTargetListViewContents.targetListH(this));
          });
        },
      );

  BlocListener<CAPIBloc, CAPIState> _justSelectedATarget() => BlocListener<CAPIBloc, CAPIState>(
          // just selected a target
          listenWhen: (CAPIState previous, CAPIState current) {
        bool curr = current.aTargetIsSelected(widget.wwName);
        bool prev = previous.aTargetIsSelected(widget.wwName);
        bool b = current.aTargetIsSelected(widget.wwName) && !previous.aTargetIsSelected(widget.wwName);
        return b;
      }, listener: (context, state) {
        // Useful.om.removeAllCalloutsExceptFor(exceptions: [
        //   CAPI.TARGET_LISTVIEW_CALLOUT.feature(),
        //   CAPI.TARGET_CALLOUT.feature(state.selectedTargetWrapperName, state.selectedTargetInde(widget.wwwName)x)
        // ]);
        TargetConfig selectedTc = state.selectedTarget(widget.wwName)!;
        // savedChildLocalPosPc = Offset(state.selectedTarget!.childLocalPosLeftPc ?? 0, state.selectedTarget!.childLocalPosTopPc ?? 0);
        Useful.afterNextBuildDo(() {
          transformationController.value = selectedTc.getRecordedMatrix();
          transformationController.addListener(onChangeTransformation);
          showStylesCallout(selectedTc, widget.ancestorScrollController);
          showTextEditorCallout(selectedTc, widget.ancestorScrollController);
          WidgetToast(
                  feature: CAPI.ANY_TOAST.feature(),
                  backgroundColor: Colors.purpleAccent,
                  widthF: () => Useful.scrW * .5,
                  heightF: () => 150,
                  gravity: Alignment.bottomCenter,
                  contents: () => DefaultTextStyle(
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18.0),
                              child: Text("Target ${state.selectedTargetIndex(widget.wwName) + 1} Selected\nyou can now:"),
                            ),
                            const Text("- pan and zoom,\n- reposition the target,\n- reposition the callout"),
                          ],
                        ),
                      ),
                  gotitAxis: Axis.horizontal,
                  onGotitPressedF: () {})
              .show(removeAfterMs: SECS(20), notUsingHydratedStorage: true);
        });
      });

// BlocListener<CAPIBloc, CAPIState> _justClearedSelection() => BlocListener<CAPIBloc, CAPIState>(
//       // just cleared selection
//       listenWhen: (CAPIState previous, CAPIState current) {
//         return !current.aTargetIsSelected(widget.wwName) && previous.aTargetIsSelected(widget.wwName);
//       },
//       // stop listening to transformationcontroller
//       listener: (context, state) {
//         transformationController.value = Matrix4.identity();
//         transformationController.removeListener(_onChangeTransformation);
//         Useful.om.removeCalloutByFeature(CAPI.ANY_TOAST.feature(), true);
//         removeTextEditorCallout();
//         removeStylesCallout();
//         removeAllTargets(state, widget.wwName);
//         // refresh the deselected target
//         if (!state.suspended(widget.wwName) && state.lastUpdatedTC != null) {
//           int i = state.wtMap[state.lastUpdatedTC!.wwName]?.indexOf(state.lastUpdatedTC!) ?? -1;
//           if (i > -1) {
//             Offset deselectedPos = state.lastUpdatedTC!.targetGlobalPos();
//             // Callout.moveToByFeature(CAPI.TARGET_CALLOUT.feature(widget.wwName, i), deselectedPos);
//             _targetCreationInProgress = true;
//             removeTargetCallout(widget.wwName, i);
//             showDraggableTargetCallout(state.lastUpdatedTC!, onReadyF: () {
//               _targetCreationInProgress = false;
//             });
//           }
//         }
//       },
//     );

// BlocListener<CAPIBloc, CAPIState> _getReadyToStartPlaying() => BlocListener<CAPIBloc, CAPIState>(
//       // start playing a target
//       listenWhen: (CAPIState previous, CAPIState current) {
//         return !current.isPlaying && previous.playList.isEmpty && current.playList.isNotEmpty;
//       },
//       // stop listening to transformationcontroller
//       listener: (context, state) async {
//       },
//     );

  BlocListener<CAPIBloc, CAPIState> _playATarget() => BlocListener<CAPIBloc, CAPIState>(
        // start playing a target
        listenWhen: (CAPIState previous, CAPIState current) {
          return previous.playList(widget.wwName).length != current.playList(widget.wwName).length;
        },
        listener: (context, state) {
          if (state.playList(widget.wwName).isNotEmpty) {
            tcToPlay = state.playList(widget.wwName)[0];
            matrix4Animation = Matrix4Tween(
              begin: Matrix4.identity(),
              end: tcToPlay.getRecordedMatrix(),
            ).animate(aController);
            aController.forward().then((_) {
              tcToPlay.visible = true;
              Callout(
                targetGKF: tcToPlay.gk,
                feature: CAPI.TEXT_CALLOUT.feature(),
                color: tcToPlay.calloutColor(),
                widthF: () => tcToPlay.calloutWidth,
                heightF: () => tcToPlay.calloutHeight,
                contents: () => Padding(
                  padding: const EdgeInsets.all(TextEditor.CONTENT_PADDING),
                  child: RichText(
                    textAlign: tcToPlay.textAlign(),
                    text: TextSpan(
                      style: tcToPlay.textStyle(),
                      text: tcToPlay.text(),
                    ),
                  ),
                ),
                separation: 30,
                initialCalloutPos: tcToPlay.getTextCalloutPos(),
                onExpiredF: () async {
                  await aController.reverse();
                  if (state.playList(widget.wwName).length > 1)
                    bloc.add(CAPIEvent.playNext(wwName: widget.wwName));
                  else
                    _playEnded();
                },
                ignoreCalloutResult: true,
                arrowColor: Color(tcToPlay.calloutColorValue!),
                arrowType: tcToPlay.getArrowType(),
                animate: tcToPlay.animateArrow,
              ).show(
                removeAfterMs: tcToPlay.calloutDurationMs,
                notUsingHydratedStorage: true,
              );
            });
          }
        },
      );

  void _playEnded() {
    bloc.add(CAPIEvent.playNext(wwName: widget.wwName)); //sets playlist empty
    transformationController.value = Matrix4.identity();
    transformationController.addListener(onChangeTransformation);
    // hideAllTargets();
    onChangeTransformation();
    // Useful.afterNextBuildDo(() {
    //   showAllTargets();
    // });
    // if (bloc.state.aTargetIsSelected(widget.wwName)) {
    //   TargetItemView.clearSelection(this, tappedTc: bloc.state.selectedTarget(widget.wwName)!);
    // }
    createAndShowTargetListCallout(this);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (SizeChangedLayoutNotification notification) {
        print("CAPIWidgetWrapperState on Size Change Notification - ${widget.wwName}");
        removeIVRectCallout();
        removeListViewCallout(widget.wwName);
        CAPIWidgetWrapperState.hideAllTargets(bloc: bloc, wwName: widget.wwName);
        measureIVPos();
        if (bloc.state.isSuspended(widget.wwName)) {
          Useful.afterMsDelayDo(1000, () {
            measureIVPos();
            // showIVRectCallout(this);
            // CAPIWidgetWrapperState.showAllTargets(bloc: bloc, wwName: widget.wwName);
            // createAndShowTargetListCallout(this);
          });
        } else
          _suspendResumeButtonPressF(forceSuspend: true);
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: MultiBlocListener(
          listeners: [
            _suspended(),
            // _resumed(),
            _addedANewTarget(),
            _justSelectedATarget(),
            // _justClearedSelection(),
            // _getReadyToStartPlaying(),
            _playATarget(),
            // _playEnded(),
          ],
          child: BlocBuilder<CAPIBloc, CAPIState>(buildWhen: (previous, current) {
            // suspendws OR resumed OR selection changed
            return previous.isSuspended(widget.wwName) != current.isSuspended(widget.wwName) ||
                previous.selectedTarget(widget.wwName) != current.selectedTarget(widget.wwName) ||
                previous.isPlaying != current.isPlaying;
          }, builder: (context, state) {
            print("--- ${widget.wwName} builder");
            return Material(
              child: Stack(
                clipBehavior: widget.hardEdge ? Clip.hardEdge : Clip.none,
                children: [
                  if (state.isSuspended(widget.wwName) || !CAPIAppWrapper.wwPosMap.containsKey(widget.wwName))
                    // NORMAL BUILD ---------------------------------------------
                    _suspendedBuild(),
                  // long pressable barrier
                  // PREVENT ACCIDENTAL APP EVENTS SUCH AS NAVIGATING AWAY
                  if (!state.isSuspended(widget.wwName) && !state.aTargetIsSelected(widget.wwName))
                    GestureDetector(
                      key: CAPIAppWrapper.wwGKMap[widget.wwName] = GlobalKey(),
                      // long press creates a new target for this TargetWrapper
                      onLongPressStart: (LongPressStartDetails details) {
                        if (!state.aTargetIsSelected(widget.wwName)) {
                          hideAllTargets(bloc: bloc, wwName: widget.wwName);
                          bloc.add(
                            CAPIEvent.newTarget(
                              wwName: widget.wwName,
                              newGlobalPos: details.globalPosition.translate(widget.ancestorScrollController?.offset ?? 0.0, 0),
                            ),
                          );
                          // Useful.afterNextBuildDo(() {
                          //   TargetConfig? newestTarget = bloc.state.newestTarget(widget.wwName);
                          //   newestTarget?.setTargetStackPosPc(details.globalPosition);
                          // });
                        }
                      },
                      child: SizedBox.fromSize(
                        size: CAPIAppWrapper.wwSize(widget.wwName),
                        child: ModalBarrier(
                          color: !state.isPlaying(widget.wwName) ? Colors.purple.withOpacity(.25) : null,
                          dismissible: false,
                        ),
                      ),
                    ),
                  // --
                  // NORMAL BUILD ---------------------------------------------
                  // --
                  //TARGET SELECTED
                  if (!state.isSuspended(widget.wwName) && state.aTargetIsSelected(widget.wwName))
                    // only render an IV when a target is selected
                    _selectedTargetBuild(state),
                  // --
                  if (!state.isSuspended(widget.wwName) && !state.aTargetIsSelected(widget.wwName))
                    // when no selection, render with current (possibly animating) transform
                    _noSelectionBuild(state),
                  if (!state.isSuspended(widget.wwName) && !state.aTargetIsSelected(widget.wwName) && !state.isPlaying(widget.wwName))
                    for (var tc in state.targets(widget.wwName)) buildPositionedDraggableTarget(tc),
                  if (!state.isSuspended(widget.wwName) && !state.aTargetIsSelected(widget.wwName) && !state.isPlaying(widget.wwName))
                    for (var tc in state.targets(widget.wwName).where((el) => el.showBtn)) buildPositionedDraggableTargetBtn(tc),
                  if (!state.isSuspended(widget.wwName) && (state.aTargetIsSelected(widget.wwName)))
                    buildPositionedDraggableTarget(state.selectedTarget(widget.wwName)!),
                  if (state.isPlaying(widget.wwName)) buildPositionedTargetForPlay(tcToPlay),
                  // --
                  // if (state.suspended(widget.wwName))
                  Positioned(
                    left: (widget.suspendButtonLeft == null && widget.suspendButtonRight == null) ? -20 : widget.suspendButtonLeft,
                    right: widget.suspendButtonRight,
                    bottom: (widget.suspendButtonTop == null && widget.suspendButtonBottom == null) ? -20 : widget.suspendButtonBottom,
                    top: widget.suspendButtonTop,
                    child: CircleAvatar(
                      backgroundColor: Colors.purpleAccent.withOpacity(!bloc.state.isSuspended(widget.wwName) ? 1.0 : 0.3),
                      radius: 30,
                      child: IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                        onPressed: _suspendResumeButtonPressF,
                      ),
                    ),
                  ),
                ],
              ),
            );
            // cannot show any CC functionality until not suspended and have measured the child (i.e. after 1st build)
          }),
        ),
      ),
    );
  }

  void _suspendResumeButtonPressF({bool forceSuspend = false}) {
    if (!forceSuspend && bloc.state.isSuspended(widget.wwName)) {
      bloc.add(CAPIEvent.resume(wwName: widget.wwName));
      Useful.afterNextBuildDo(() {
        removeListViewCallout(widget.wwName);
        Useful.afterMsDelayDo(200, () {
          showAllTargets(bloc: bloc, wwName: widget.wwName);
          createAndShowTargetListCallout(this);
          showIVRectCallout(this);
          CAPIState state = bloc.state;
          print(state.suspendedMap.toString());
          // possibly reshow targetlistview and targets
        });
      });
    } else {
      removeListViewCallout(widget.wwName);
      hideAllTargets(bloc: bloc, wwName: widget.wwName);
      removeTextEditorCallout();
      removeIVRectCallout();
      bloc.add(CAPIEvent.suspend(wwName: widget.wwName));
    }
  }

  Positioned buildPositionedDraggableTarget(TargetConfig tc) {
    return Positioned(
      top: tc.targetStackPos().dy - bloc.state.CAPI_TARGET_RADIUS(widget.wwName),
      left: tc.targetStackPos().dx - bloc.state.CAPI_TARGET_RADIUS(widget.wwName),
      child: Draggable(
        feedback: _draggableTargetBeingDragged(tc),
        child: _draggableTargetNotBeingDragged(tc),
        childWhenDragging: Offstage(),
        onDragUpdate: (DragUpdateDetails details) {
          Offset newGlobalPos = details.globalPosition.translate(widget.ancestorScrollController?.offset ?? 0.0, 0);
          tc.setTargetStackPosPc(newGlobalPos);
          // Callout.updateTargetPosByFeature(CAPI.TEXT_CALLOUT.feature(), details.globalPosition);
          bloc.add(CAPIEvent.targetMoved(tc: tc, newGlobalPos: newGlobalPos));
        },
        onDragStarted: () {
          removeTextEditorCallout();
        },
        onDragEnd: (DraggableDetails details) {
          Offset newGlobalPos = details.offset.translate(widget.ancestorScrollController?.offset ?? 0.0, 0);
          tc.setTargetStackPosPc(newGlobalPos);
          // Callout.updateTargetPosByFeature(CAPI.TEXT_CALLOUT.feature(), details.offset);
          bloc.add(CAPIEvent.targetMoved(tc: tc, newGlobalPos: newGlobalPos));
          Useful.afterNextBuildDo(() {
            if (bloc.state.aTargetIsSelected(widget.wwName)) showTextEditorCallout(tc, widget.ancestorScrollController);
          });
        },
      ),
    );
  }

  Widget _draggableTargetNotBeingDragged(tc) {
    return SizedBox(
      width: bloc.state.CAPI_TARGET_RADIUS(widget.wwName) * 2,
      height: bloc.state.CAPI_TARGET_RADIUS(widget.wwName) * 2,
      child: Stack(
        children: [
          Positioned(
            top: bloc.state.CAPI_TARGET_RADIUS(widget.wwName),
            left: bloc.state.CAPI_TARGET_RADIUS(widget.wwName),
            child: SizedBox(
              key: tc.gk(),
              width: 1,
              height: 1,
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: IntegerCircleAvatar(
              tc,
              num: bloc.state.targetIndex(tc) + 1,
              bgColor: Colors.yellow.withOpacity(.2),
              radius: bloc.state.CAPI_TARGET_RADIUS(widget.wwName),
              textColor: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _draggableTargetBeingDragged(tc) {
    return SizedBox(
      width: bloc.state.CAPI_TARGET_RADIUS(widget.wwName) * 2,
      height: bloc.state.CAPI_TARGET_RADIUS(widget.wwName) * 2,
      child: Stack(
        children: [
          Positioned(
            top: bloc.state.CAPI_TARGET_RADIUS(widget.wwName),
            left: bloc.state.CAPI_TARGET_RADIUS(widget.wwName),
            child: SizedBox(
              key: tc.gk(),
              width: 1,
              height: 1,
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Target(
              radius: bloc.state.CAPI_TARGET_RADIUS(widget.wwName),
            ),
          ),
        ],
      ),
    );
  }

  Positioned buildPositionedDraggableTargetBtn(TargetConfig tc) {
    return Positioned(
      top: tc.btnStackPos().dy - bloc.state.CAPI_TARGET_BTN_RADIUS,
      left: tc.btnStackPos().dx - bloc.state.CAPI_TARGET_BTN_RADIUS,
      child: Draggable(
        childWhenDragging: Offstage(),
        feedback: IntegerCircleAvatar(
          tc,
          num: bloc.state.targetIndex(tc) + 1,
          bgColor: tc.calloutColor(),
          radius: bloc.state.CAPI_TARGET_BTN_RADIUS,
          textColor: Color(tc.textColorValue ?? Colors.white.value),
          fontSize: 14,
        ),
        child: IntegerCircleAvatar(
          tc,
          num: bloc.state.targetIndex(tc) + 1,
          bgColor: tc.calloutColor(),
          radius: bloc.state.CAPI_TARGET_BTN_RADIUS,
          textColor: Color(tc.textColorValue ?? Colors.white.value),
          fontSize: 14,
        ),
        onDragUpdate: (DragUpdateDetails details) {
          Offset newGlobalPos = details.globalPosition.translate(widget.ancestorScrollController?.offset ?? 0.0, 0);
          tc.setBtnStackPosPc(newGlobalPos);
          bloc.add(CAPIEvent.btnMoved(tc: tc, newGlobalPos: newGlobalPos));
        },
        onDragEnd: (DraggableDetails details) {
          Offset newGlobalPos = details.offset.translate(widget.ancestorScrollController?.offset ?? 0.0, 0);
          tc.setBtnStackPosPc(newGlobalPos);
          bloc.add(CAPIEvent.btnMoved(tc: tc, newGlobalPos: newGlobalPos));
        },
      ),
    );
  }

  Positioned buildPositionedTargetForPlay(TargetConfig tc) {
    return Positioned(
      top: tc.targetStackPos().dy,
      left: tc.targetStackPos().dx,
      child: SizedBox(
        key: tc.gk(),
        width: 1,
        height: 1,
      ),
    );
  }

  Widget _suspendedBuild() => MeasureSizeBox(
        key: CAPIAppWrapper.wwGKMap[widget.wwName] = GlobalKey(),
        onSizedCallback: (Size size) {
          CAPIAppWrapper.wwSizeMap[widget.wwName] = size;
          print("MeasureSizeBox => ${size.toString()}");
        },
        child: widget.aspectRatio != null
            ? AspectRatio(
                aspectRatio: widget.aspectRatio!,
                child: widget.child,
              )
            : widget.child,
      );

  Widget _selectedTargetBuild(CAPIState state) {
    TargetConfig st = state.selectedTarget(widget.wwName)!;
    print("_selectedTargetBuild");
    print("recordedScale      ${st.recordedScale}");
    print("recordedTranslateX ${st.getTranslate().dx}");
    print("recordedTranslateY ${st.getTranslate().dy}");
    return InteractiveViewer(
      key: CAPIAppWrapper.wwGKMap[widget.wwName] = GlobalKey(),
      scaleEnabled: state.aTargetIsSelected(widget.wwName),
      //selectedTarget != -1,
      panEnabled: state.aTargetIsSelected(widget.wwName),
      //selectedTarget != -1,
      minScale: .25,
      maxScale: 8,
      transformationController: transformationController,
      onInteractionStart: (_) {
        showTextCalloutTimer?.cancel();
        if (state.aTargetIsSelected(widget.wwName)) {
          removeTextEditorCallout();
        }
      },
      child: IgnorePointer(
        child: widget.aspectRatio != null
            ? AspectRatio(
                aspectRatio: widget.aspectRatio!,
                child: widget.child,
              )
            : widget.child,
      ),
    );
  }

  Widget _noSelectionBuild(state) {
    // print("_noSelectionBuild");
    return SizedBox.fromSize(
      size: CAPIAppWrapper.wwSize(widget.wwName),
      child: AnimatedBuilder(
        animation: aController,
        builder: (BuildContext context, _) {
          return Transform(
            transform: matrix4Animation.value,
            // transform: matrix4Animation.value,
            child: IgnorePointer(
              child: widget.child,
            ),
          );
        },
      ),
    );
  }

  static void hideAllTargets({required CAPIBloc bloc, required String wwName, final int? exception}) {
    List<TargetConfig> list = bloc.state.targets(wwName);
    for (int i = 0; i < list.length; i++) {
      if (i != exception) bloc.state.target(wwName, i)?.visible = false;
    }
  }

  static void showAllTargets({required CAPIBloc bloc, required String wwName}) {
    if (!bloc.state.aTargetIsSelected(wwName)) {
      for (TargetConfig tc in bloc.state.targets(wwName)) {
        tc.visible = true;
      }
    }
  }
}

class IntegerCircleAvatar extends StatelessWidget {
  final TargetConfig tc;
  final int? num;
  final Color textColor;
  final Color bgColor;
  final bool selected;
  final double radius;
  final double fontSize;

  const IntegerCircleAvatar(this.tc,
      {this.num, required this.textColor, required this.bgColor, required this.radius, required this.fontSize, this.selected = false, super.key});

  @override
  Widget build(BuildContext context) => CircleAvatar(
        backgroundColor: Colors.grey.withOpacity(.25),
        radius: radius + (selected ? 4 : 1),
        child: CircleAvatar(
          foregroundColor: textColor,
          backgroundColor: bgColor,
          radius: radius,
          child: tc.bloc.state.aTargetIsSelected(tc.wwName) ? null : Text('${num}', style: TextStyle(color: textColor, fontSize: fontSize)),
        ),
      );
}
