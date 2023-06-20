import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_event.dart';
import 'package:flutter_callout_api/src/bloc/capi_state.dart';
import 'package:flutter_callout_api/src/callout_dotted_border.dart';
import 'package:flutter_callout_api/src/callout_help_content/callout_help_content.dart';
import 'package:flutter_callout_api/src/callout_target/callout_radius_and_zoom.dart';
import 'package:flutter_callout_api/src/callout_target/callout_target_config_toolbar.dart';
import 'package:flutter_callout_api/src/callout_target/callout_target_duration.dart';
import 'package:flutter_callout_api/src/measuring/find_global_rect.dart';
import 'package:flutter_callout_api/src/measuring/measure_sizebox.dart';
import 'package:flutter_callout_api/src/model/target_config.dart';
import 'package:flutter_callout_api/src/overlays/callouts/callout.dart';
import 'package:flutter_callout_api/src/overlays/callouts/toast.dart';
import 'package:flutter_callout_api/src/useful.dart';
import 'package:flutter_callout_api/src/wrapper/buttons/positioned_target_btn.dart';
import 'package:flutter_callout_api/src/wrapper/target.dart';
import 'package:flutter_callout_api/src/wrapper/transformable_widget_wrapper.dart';

import '../blink.dart';

class ImageWrapperAuto extends StatefulWidget {
  final String iwName;
  final ContentFunc imageF;
  final ScrollController? ancestorHScrollController;
  final ScrollController? ancestorVScrollController;
  final double? suspendButtonLeft;
  final double? suspendButtonRight;
  final double? suspendButtonTop;
  final double? suspendButtonBottom;
  final double? aspectRatio;
  final bool hardEdge;

  ImageWrapperAuto({
    // required this.twName,
    required this.iwName,
    required this.imageF,
    this.ancestorHScrollController,
    this.ancestorVScrollController,
    this.suspendButtonLeft,
    this.suspendButtonRight,
    this.suspendButtonTop,
    this.suspendButtonBottom,
    this.aspectRatio,
    this.hardEdge = true,
  }) : super(key: CAPIState.gkMap[iwName] = GlobalKey());

  @override
  State<ImageWrapperAuto> createState() => ImageWrapperAutoState();
}

class ImageWrapperAutoState extends State<ImageWrapperAuto> {
  Rect? _selectedTargetRect;

  Offset? savedChildLocalPosPc;

  Timer? _sizeChangedTimer;
  bool targetCreationInProgress = false;

  double? scrollOffset;
  Orientation? _lastO;

  CAPIBloc get bloc => BlocProvider.of<CAPIBloc>(context);

  late TargetConfig tcToPlay;

  @override
  void initState() {
    super.initState();

    if (widget.ancestorHScrollController != null) CAPIState.registerScrollController(widget.ancestorHScrollController!);
    if (widget.ancestorVScrollController != null) CAPIState.registerScrollController(widget.ancestorVScrollController!);

    // make available globally
    CAPIState.gkMap[widget.iwName] = widget.key as GlobalKey;

    Useful.afterNextBuildDo(() {
      // register ww with AppWrapper
      measureIWPos();
      GlobalKey? gk = CAPIState.gk(widget.iwName);
      if (gk != null) {
        measureWidget(gk);
        Size size = CAPIState.iwSize(widget.iwName);
        // print("${widget.iwName} size: ${size.toString()}");
      }
    });
  }

  @override
  void didChangeDependencies() {
    Useful.instance.initWithContext(context, force: true);
    super.didChangeDependencies();
  }

  void measureIWPos() {
    Offset? globalPos;
    try {
      GlobalKey? iwGK = CAPIState.gkMap[widget.iwName];
      if (iwGK != null) {
        globalPos = Useful.findGlobalPos(iwGK)?.translate(
          widget.ancestorHScrollController?.offset ?? 0.0,
          widget.ancestorVScrollController?.offset ?? 0.0,
        );
      }
    } catch (e) {
      // ignore but then don't update pos
    }
    if (globalPos != null) {
      CAPIState.iwPosMap[widget.iwName] = globalPos;
    }
  }

  Rect? measureWidget(GlobalKey gk) {
    try {
      return findGlobalRect(gk);
    } catch (e) {
      // ignore but then don't update pos
    }
  }

  @override
  void didChangeMetrics() {
    print("***  didChangeMetrics  ***");
    measureIWPos();
  }

// @override
// void didUpdateWidget(Object oldWidget) {
//   print("didUpdateWidget");
// }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  BlocListener<CAPIBloc, CAPIState> _suspended() => BlocListener<CAPIBloc, CAPIState>(
        listenWhen: (CAPIState previous, CAPIState current) {
          return !previous.isSuspended(widget.iwName) && current.isSuspended(widget.iwName);
        },
        listener: (context, state) {
          CAPIModel model = CAPIModel(state.timestamp!, state.targetMap, state.imageTargetListMap);
          Clipboard.setData(ClipboardData(text: jsonEncode(model.toJson())));
          // hideAllTargets(bloc: bloc, iwName: widget.iwName);
          removeHelpContentEditorCallout();

          TextToast(
              feature: CAPI.ANY_TOAST.feature(),
              msgText: "Config json copied to the clipboard - use this to create your CCAppWrapper instance",
              backgroundColor: Colors.purpleAccent,
              textColor: Colors.yellowAccent,
              widthF: () => 600,
              heightF: () => 80).show(
            removeAfterMs: SECS(5),
            notUsingHydratedStorage: true,
          );
        },
      );

  BlocListener<CAPIBloc, CAPIState> _resumed() => BlocListener<CAPIBloc, CAPIState>(
        listenWhen: (CAPIState previous, CAPIState current) {
          return previous.isSuspended(widget.iwName) && !current.isSuspended(widget.iwName);
        },
        listener: (context, state) {
          removeDottedBorderCallout();
          measureIWPos();
          showAllTargets(bloc: bloc, iwName: widget.iwName);
          showDottedBorderCallout(
            widget.iwName,
            widget.ancestorHScrollController,
            widget.ancestorVScrollController,
            1000,
          );
        },
      );

  // BlocListener<CAPIBloc, CAPIState> _addedANewTarget() => BlocListener<CAPIBloc, CAPIState>(
  //       listenWhen: (CAPIState previous, CAPIState current) {
  //         return (current.numTargetsOnPage() != previous.numTargetsOnPage()
  //             //&& current.selectedTarget == previous.selectedTarget
  //             );
  //       },
  //       listener: (context, state) {
  //         TargetConfig? newestTarget = state.getNewestTarget();
  //         if (newestTarget != null) {
  //         }
  //       },
  //     );

  BlocListener<CAPIBloc, CAPIState> _justChangedSelectedTargetRadiusOrZoom() => BlocListener<CAPIBloc, CAPIState>(
        listenWhen: (CAPIState previous, CAPIState current) {
          bool result = current.selectedTarget?.wName == widget.iwName &&
              (current.selectedTarget?.radius != previous.selectedTarget?.radius ||
                  current.selectedTarget?.transformScale != previous.selectedTarget?.transformScale);
          if (result) print('_justChangedSelectedTargetRadiusOrZoom: ${current.selectedTarget?.radius}, ${previous.selectedTarget?.radius}');
          return result;
        },
        listener: (context, state) {
          TargetConfig? selectedTarget = state.selectedTarget;
          if (selectedTarget != null) {
            Useful.afterMsDelayPassBlocAndDo(50, bloc, (bloC) {
              if (isShowingTargetConfigCallout()) {
                removeTargetConfigToolbarCallout();
                if (!isShowingTargetConfigCallout())
                  showTargetConfigToolbarCallout(bloC, widget.ancestorHScrollController, widget.ancestorVScrollController);
              }
              if (isShowingHelpContentCallout()) {
                removeHelpContentEditorCallout();
                if (!isShowingHelpContentCallout()) {
                  showHelpContentEditorCallout(selectedTarget, widget.ancestorHScrollController, widget.ancestorVScrollController);
                }
              }
            });
          }
        },
      );

  BlocListener<CAPIBloc, CAPIState> _justChangedSelectedTargetArrowType() => BlocListener<CAPIBloc, CAPIState>(
        listenWhen: (CAPIState previous, CAPIState current) {
          return current.selectedTarget?.wName == widget.iwName && current.selectedTarget?.arrowType != previous.selectedTarget?.arrowType;
        },
        listener: (context, state) {
          TargetConfig? selectedTarget = state.selectedTarget;
          if (selectedTarget != null) {
            if (isShowingHelpContentCallout()) {
              removeHelpContentEditorCallout();
              showHelpContentEditorCallout(selectedTarget, widget.ancestorHScrollController, widget.ancestorVScrollController);
            }
          }
        },
      );

  BlocListener<CAPIBloc, CAPIState> _justSelectedATarget() => BlocListener<CAPIBloc, CAPIState>(
          // just selected a target
          listenWhen: (CAPIState previous, CAPIState current) {
        return current.aTargetIsSelected() && current.selectedTarget?.wName == widget.iwName && !previous.aTargetIsSelected();
      }, listener: (context, state) {
        TargetConfig selectedTc = state.selectedTarget!;
        TransformableWidgetWrapperState? parentState = TransformableWidgetWrapper.of(context);
        if (parentState != null) {
          Rect? wrapperRect = findGlobalRect(CAPIState.gk(widget.iwName)!);
          Rect? targetRect = findGlobalRect(selectedTc.gk());
          if (wrapperRect != null && targetRect != null) {
            hideAllTargets(bloc: bloc, iwName: widget.iwName, exception: selectedTc);
            Alignment ta = Useful.calcTargetAlignment(wrapperRect, targetRect);
            // IMPORTANT applyTransform will destroy this context, so make state available for afterwards
            parentState.applyTransform(selectedTc.transformScale, selectedTc.transformScale, ta, afterTransformF: (bloC) {
              showTargetConfigToolbarCallout(bloC, widget.ancestorHScrollController, widget.ancestorVScrollController);
              // showHelpContentCallout(selectedTc, widget.ancestorHScrollController, widget.ancestorVScrollController);
            });
          }
        }
      });

  BlocListener<CAPIBloc, CAPIState> _justClearedSelection() => BlocListener<CAPIBloc, CAPIState>(
        // just cleared selection
        listenWhen: (CAPIState previous, CAPIState current) {
          return previous.aTargetIsSelected() && previous.selectedTarget?.wName == widget.iwName && !current.aTargetIsSelected();
        },
        listener: (context, state) {
          _backToNormal();
        },
      );

  void _backToNormal() {
    Useful.om.remove(CAPI.ANY_TOAST.feature(), true);
    removeRadiusAndZoomCallout();
    removeTargetDurationCallout();
    removeHelpContentEditorCallout();
    removeTargetConfigToolbarCallout();
    TransformableWidgetWrapperState? parentState = TransformableWidgetWrapper.of(context);
    parentState?.resetTransform();
    showAllTargets(bloc: bloc, iwName: widget.iwName);
  }

// BlocListener<CAPIBloc, CAPIState> _getReadyToStartPlaying() => BlocListener<CAPIBloc, CAPIState>(
//       // start playing a target
//       listenWhen: (CAPIState previous, CAPIState current) {
//         return !current.isPlaying && previous.playList.isEmpty && current.playList.isNotEmpty;
//       },
//       // stop listening to transformationcontroller
//       listener: (context, state) async {
//       },
//     );

  // BlocListener<CAPIBloc, CAPIState> _playATarget() => BlocListener<CAPIBloc, CAPIState>(
  //       // start playing a target
  //       listenWhen: (CAPIState previous, CAPIState current) {
  //         return previous.playList.length != current.playList.length;
  //       },
  //       listener: (context, state) {
          // if (state.playList(widget.iwName).isNotEmpty) {
          //   tcToPlay = state.playList(widget.iwName)[0];
          //   matrix4Animation = Matrix4Tween(
          //     begin: Matrix4.identity(),
          //     end: tcToPlay.getRecordedMatrix(),
          //   ).animate(aController);
          //   aController.forward().then((_) {
          //     tcToPlay.visible = true;
          //     Callout(
          //       targetGKF: tcToPlay.gk,
          //       feature: CAPI.TEXT_CALLOUT.feature(),
          //       color: tcToPlay.calloutColor(),
          //       widthF: () => tcToPlay.calloutWidth,
          //       heightF: () => tcToPlay.calloutHeight,
          //       contents: () => Padding(
          //         padding: const EdgeInsets.all(TextEditor.CONTENT_PADDING),
          //         child: RichText(
          //           textAlign: tcToPlay.textAlign(),
          //           text: TextSpan(
          //             style: tcToPlay.textStyle(),
          //             text: tcToPlay.text(),
          //           ),
          //         ),
          //       ),
          //       // separation: 30,
          //       initialCalloutPos: tcToPlay.getTextCalloutPos(),
          //       onExpiredF: () async {
          //         await aController.reverse();
          //         if (state.playList(widget.iwName).length > 1)
          //           bloc.add(CAPIEvent.playNext(wName: widget.iwName));
          //         else
          //           _playEnded();
          //       },
          //       ignoreCalloutResult: true,
          //       arrowColor: Color(tcToPlay.calloutColorValue!),
          //       arrowType: tcToPlay.getArrowType(),
          //       animate: tcToPlay.animateArrow,
          //     ).show(
          //       removeAfterMs: tcToPlay.calloutDurationMs,
          //       notUsingHydratedStorage: true,
          //     );
          //   });
          // }
      //   },
      // );

  // void _playEnded() {
  //   bloc.add(CAPIEvent.playNext(wName: widget.iwName)); //sets playlist empty
    // Useful.afterNextBuildDo(() {
    //   showAllTargets();
    // });
    // if (bloc.state.aTargetIsSelected(widget.iwName)) {
    //   TargetItemView.clearSelection(this, tappedTc: bloc.state.selectedTarget(widget.iwName)!);
    // }
    // createAndShowTargetListCallout(this);
  // }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (SizeChangedLayoutNotification notification) {
        // print("CAPIWidgetWrapperState on Size Change Notification - ${widget.iwName}");
        removeDottedBorderCallout();
        // update size at end of resize
        _sizeChangedTimer?.cancel();
        _sizeChangedTimer = Timer(Duration(milliseconds: 500), () {
          measureIWPos();
          GlobalKey? gk = CAPIState.gk(widget.iwName);
          if (gk != null) {
            measureWidget(gk);
            Size size = CAPIState.iwSize(widget.iwName);
            // print("${widget.iwName} size: ${size.toString()}");
          }
        });
        Useful.afterNextBuildDo(() {
          measureIWPos();
          GlobalKey? gk = CAPIState.gk(widget.iwName);
          if (gk != null) {
            measureWidget(gk);
            Size size = CAPIState.iwSize(widget.iwName);
            // print("${widget.iwName} size: ${size.toString()}");
          }
        });
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: MultiBlocListener(
          listeners: [
            _suspended(),
            _resumed(),
            // _addedANewTarget(),
            _justSelectedATarget(),
            _justClearedSelection(),
            _justChangedSelectedTargetRadiusOrZoom(),
            _justChangedSelectedTargetArrowType(),
            // _getReadyToStartPlaying(),
            // _playATarget(),
            // _playEnded(),
          ],
          child: BlocBuilder<CAPIBloc, CAPIState>(buildWhen: (previous, current) {
            // suspendws OR resumed OR selection changed
            return true; //previous.isSuspended(widget.iwName) != current.isSuspended(widget.iwName) //||
            // previous.selectedTarget(widget.iwName) != current.selectedTarget(widget.iwName) ||
            ; //previous.isPlaying != current.isPlaying;
          }, builder: (context, CAPIState state) {
            // print("--- ${widget.iwName} builder");
            return SizedBox(
              child: _stack(state),
            );
            // cannot show any CC functionality until not suspended and have measured the child (i.e. after 1st build)
          }),
        ),
      ),
    );
  }

  Stack _stack(CAPIState state) => Stack(
        clipBehavior: widget.hardEdge ? Clip.hardEdge : Clip.none,
        children: [
          if (state.isSuspended(widget.iwName) || !CAPIState.iwPosMap.containsKey(widget.iwName))
            // SUSPENDED BUILD ---------------------------------------------
            _suspended_build(),
          if (state.isSuspended(widget.iwName) || !CAPIState.iwPosMap.containsKey(widget.iwName))
            for (var tc in state.imageTargets(widget.iwName).where((el) => el.showBtn))
              if (tc.visible && (state.hideTargetsWhilePlayingExcept == null))
                PositionedTargetBtn(parent: this, iwName:widget.iwName, tcIndex: state.targetIndex(tc), draggable: false),
          if (state.isSuspended(widget.iwName) || !CAPIState.iwPosMap.containsKey(widget.iwName))
            for (TargetConfig tc in state.imageTargets(widget.iwName))
              if (tc.visible && (state.hideTargetsWhilePlayingExcept == null || state.hideTargetsWhilePlayingExcept == tc))
                buildPositionedTarget(tc),
          // NOT SUSPENDED BUILD ---------------------------------------------
          if (!state.isSuspended(widget.iwName) && !state.aTargetIsSelected())
            // RESUMED NO SELECTION - LONG-PRESSABLE BARRIER
            _no_selection_long_pressable_barrier_build(state),
          if (!state.isSuspended(widget.iwName))
            // RESUMED
            _image_child_build(state),
          // PLAYING BUILD
          if (!state.isSuspended(widget.iwName))
            for (TargetConfig tc in state.imageTargets(widget.iwName))
              if (!state.aTargetIsSelected() || state.selectedTarget!.uid == tc.uid) buildPositionedDraggableTarget(tc, state.aTargetIsSelected()),
          if (!state.isSuspended(widget.iwName) && !state.aTargetIsSelected())
            for (var tc in state.imageTargets(widget.iwName).where((el) => el.showBtn))
              if (tc.visible) PositionedTargetBtn(parent: this, iwName:widget.iwName, tcIndex: state.targetIndex(tc), draggable: true),
          // if (!state.isSuspended(widget.iwName) && (state.aTargetIsSelected(widget.iwName)))
          //   buildPositionedDraggableTarget(state.selectedTarget(widget.iwName)!),
          if (state.playList.isNotEmpty) buildPositionedTargetForPlay(tcToPlay),
          // --
          // if (state.suspended(widget.iwName))
          Positioned(
            left: (widget.suspendButtonLeft == null && widget.suspendButtonRight == null) ? -10 : widget.suspendButtonLeft,
            right: widget.suspendButtonRight,
            bottom: (widget.suspendButtonTop == null && widget.suspendButtonBottom == null) ? -10 : widget.suspendButtonBottom,
            top: widget.suspendButtonTop,
            child: Blink(
              dontAnimate: state.isSuspended(widget.iwName),
              bgColor: Colors.greenAccent,
              child: CircleAvatar(
                backgroundColor: Colors.purpleAccent.withOpacity(!bloc.state.isSuspended(widget.iwName) ? 1.0 : 0.3),
                radius: 30,
                child: IconButton(
                  icon: Icon(
                    state.isSuspended(widget.iwName) ? Icons.menu : Icons.copy,
                    color: Colors.white,
                  ),
                  iconSize: 40,
                  onPressed: _suspendResumeButtonPressF,
                ),
              ),
            ),
          ),
        ],
      );

  void _suspendResumeButtonPressF({bool forceSuspend = false}) {
    if (!forceSuspend && bloc.state.isSuspended(widget.iwName)) {
      Size size = CAPIState.iwSize(widget.iwName);
      bloc.add(CAPIEvent.resume(wName: widget.iwName));
    } else {
      removeDottedBorderCallout();
      bloc.add(CAPIEvent.suspendAndCopyToJson(wName: widget.iwName));
    }
  }

  Positioned buildPositionedDraggableTarget(TargetConfig tc, bool aTargetIsSelected) {
    double radius = tc.radius;
    return Positioned(
      top: tc.targetStackPos().dy - radius,
      left: tc.targetStackPos().dx - radius,
      child: aTargetIsSelected
          ? _draggableTargetNotBeingDragged(tc, aTargetIsSelected, Colors.yellow.withOpacity(.2))
          : Draggable(
              feedback: _draggableTargetBeingDragged(tc),
              child: _draggableTargetNotBeingDragged(tc, aTargetIsSelected, Colors.yellow.withOpacity(.2)),
              childWhenDragging: Offstage(),
              onDragUpdate: (DragUpdateDetails details) {
                Offset newGlobalPos = details.globalPosition.translate(
                  widget.ancestorHScrollController?.offset ?? 0.0,
                  widget.ancestorVScrollController?.offset ?? 0.0,
                );
                tc.setTargetStackPosPc(newGlobalPos);
              },
              onDragStarted: () {
                removeHelpContentEditorCallout();
              },
              onDragEnd: (DraggableDetails details) {
                Offset newGlobalPos = details.offset.translate(
                  widget.ancestorHScrollController?.offset ?? 0.0,
                  widget.ancestorVScrollController?.offset ?? 0.0,
                );
                tc.setTargetStackPosPc(newGlobalPos);
                bloc.add(CAPIEvent.targetMoved(tc: tc, targetRadius: radius, newGlobalPos: newGlobalPos));
                Useful.afterNextBuildPassBlocAndDo(bloc, (bloC) {
                  if (bloC.state.aTargetIsSelected()) {
                    showTargetConfigToolbarCallout(
                      bloc,
                      widget.ancestorHScrollController,
                      widget.ancestorVScrollController,
                    );
                  }
                });
              },
            ),
    );
  }

  // used when suspended
  Positioned buildPositionedTarget(TargetConfig tc) {
    double radius = tc.radius;
    return Positioned(
      top: tc.targetStackPos().dy - radius,
      left: tc.targetStackPos().dx - radius,
      child: CircleAvatar(
        key: tc.gk(),
        backgroundColor: Colors.transparent,
        radius: radius + 2,
      ),
    );
  }

  Widget _draggableTargetNotBeingDragged(tc, bool targetIsSelected, Color bgColor) {
    double radius = tc.radius;
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: IntegerCircleAvatar(
        tc,
        key: tc.gk(),
        num: bloc.state.targetIndex(tc) + 1,
        bgColor: bgColor,
        radius: radius,
        textColor: Colors.white,
        fontSize: 18,
        selected: targetIsSelected,
      ),
    );
  }

  Widget _draggableTargetBeingDragged(tc) {
    double radius = tc.radius;
    return SizedBox(
      width: tc.getScale() * radius * 2,
      height: tc.getScale() * radius * 2,
      child: Target(
        radius: tc.getScale() * radius,
      ),
    );
  }

  Positioned buildPositionedTargetForPlay(TargetConfig tc) {
    double radius = tc.radius;
    return Positioned(
      top: tc.targetStackPos().dy - radius,
      left: tc.targetStackPos().dx - radius,
      child: Container(
        decoration: BoxDecoration(color: FUCHSIA_X.withOpacity(.2), shape: BoxShape.circle),
        //color:Colors.pink.withOpacity(.2),
        key: tc.gk(),
        width: radius * 2,
        height: radius * 2,
      ),
    );
  }

  Widget _suspended_build() => MeasureSizeBox(
        // key: CAPIState.wGKMap[widget.iwName] = GlobalKey(),
        onSizedCallback: (Size size) {
          CAPIState.iwSizeMap[widget.iwName] = size;
          // print("MeasureSizeBox => ${size.toString()}");
        },
        child: widget.aspectRatio != null
            ? AspectRatio(
                aspectRatio: widget.aspectRatio!,
                child: widget.imageF.call(),
              )
            : widget.imageF.call(),
      );

  Widget _no_selection_long_pressable_barrier_build(state) => GestureDetector(
        // long press creates a new target for this TargetWrapper
        onLongPressStart: (LongPressStartDetails details) {
          hideAllTargets(bloc: bloc, iwName: widget.iwName);
          bloc.add(
            CAPIEvent.newTargetAuto(
              wName: widget.iwName,
              newGlobalPos: details.globalPosition.translate(
                widget.ancestorHScrollController?.offset ?? 0.0,
                widget.ancestorVScrollController?.offset ?? 0.0,
              ),
            ),
          );
          Useful.afterNextBuildDo(() {
            showAllTargets(bloc: bloc, iwName: widget.iwName);
          });
        },
        child: SizedBox.fromSize(
          size: CAPIState.iwSize(widget.iwName),
          child: ModalBarrier(
            color: !state.playList.isNotEmpty ? Colors.purple.withOpacity(.25) : null,
            dismissible: false,
          ),
        ),
      );

  // Widget _selectedTargetBuild(CAPIState state) {
  //   TargetConfig st = state.selectedTarget(widget.iwName)!;
  //   print("_selectedTargetBuild");
  //   print("recordedScale      ${st.recordedScale}");
  //   print("recordedTranslateX ${st.getTranslate().dx}");
  //   print("recordedTranslateY ${st.getTranslate().dy}");
  //   return InteractiveViewer(
  //     key: CAPIState.iwGKMap[widget.iwName] = GlobalKey(),
  //     scaleEnabled: state.aTargetIsSelected(widget.iwName),
  //     //selectedTarget != -1,
  //     panEnabled: state.aTargetIsSelected(widget.iwName),
  //     //selectedTarget != -1,
  //     minScale: .25,
  //     maxScale: 8,
  //     transformationController: transformationController,
  //     onInteractionStart: (_) {
  //       showTextCalloutTimer?.cancel();
  //       if (state.aTargetIsSelected(widget.iwName)) {
  //         removeTextEditorCallout();
  //       }
  //     },
  //     child: IgnorePointer(
  //       child: widget.aspectRatio != null
  //           ? AspectRatio(
  //               aspectRatio: widget.aspectRatio!,
  //               child: widget.child,
  //             )
  //           : widget.child,
  //     ),
  //   );
  // }

  Widget _image_child_build(final CAPIState state) {
    // print("_image_child_build");
    return CAPIState.iwSizeMap.containsKey(widget.iwName)
        ? IgnorePointer(
            ignoring: !state.aTargetIsSelected(),
            child: GestureDetector(
              onTap: () {
                bloc.add(CAPIEvent.clearSelection(wName: widget.iwName));
              },
              child: MeasureSizeBox(
                // key: CAPIState.wGKMap[widget.iwName] = GlobalKey(),
                onSizedCallback: (Size size) {
                  CAPIState.iwSizeMap[widget.iwName] = size;
                  // print("MeasureSizeBox => ${size.toString()}");
                },
                child: widget.aspectRatio != null
                    ? AspectRatio(
                        aspectRatio: widget.aspectRatio!,
                        child: widget.imageF.call(),
                      )
                    : widget.imageF.call(),
              ),
            ),
          )
        : MeasureSizeBox(
            // key: CAPIState.wGKMap[widget.iwName] = GlobalKey(),
            onSizedCallback: (Size size) {
              CAPIState.iwSizeMap[widget.iwName] = size;
              // print("MeasureSizeBox => ${size.toString()}");
            },
            child: widget.aspectRatio != null
                ? AspectRatio(
                    aspectRatio: widget.aspectRatio!,
                    child: widget.imageF.call(),
                  )
                : widget.imageF.call(),
          );
  }

  static void hideAllTargets({required CAPIBloc bloc, required String iwName, final TargetConfig? exception}) {
    List<TargetConfig> list = bloc.state.imageTargets(iwName);
    for (int i = 0; i < list.length; i++) {
      TargetConfig? tc = bloc.state.target(iwName, i);
      if (tc != exception) tc?.visible = false;
    }
  }

  static void showAllTargets({required CAPIBloc bloc, required String iwName}) {
    if (!bloc.state.aTargetIsSelected()) {
      for (TargetConfig tc in bloc.state.imageTargets(iwName)) {
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
        backgroundColor: Colors.black.withOpacity(.1),
        radius: radius + 2,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: radius + 1,
          child: CircleAvatar(
            foregroundColor: textColor,
            backgroundColor: selected ? Colors.white12 : bgColor,
            radius: radius,
            child: Text('${num}', style: TextStyle(color: textColor, fontSize: fontSize)),
          ),
        ),
      );
}
