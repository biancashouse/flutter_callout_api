import 'package:flutter_callout_api/src/blink.dart';
import 'package:flutter_callout_api/src/overlays/callouts/callout.dart';
import 'package:flutter_callout_api/src/useful.dart';
import 'package:flutter_callout_api/src/wrapper/app_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_event.dart';
import 'package:flutter_callout_api/src/callout_text_editor.dart';
import 'package:flutter_callout_api/src/styles/styles_picker.dart';
import 'package:flutter_callout_api/src/wrapper/buttons/copy_button.dart';
import 'package:flutter_callout_api/src/wrapper/buttons/play_button.dart';
import 'package:flutter_callout_api/src/wrapper/widget_wrapper.dart';

import '../model/target_config.dart';

void refreshListViewCallout(final String wwName) => Useful.om.refreshCalloutByFeature(CAPI.TARGET_LISTVIEW_CALLOUT.feature(wwName), () {});
//
// void hideListViewCallout(final String wwName) => Useful.om.hideCalloutByFeature(CAPI.TARGET_LISTVIEW_CALLOUT.feature(wwName));
//
// void unhideListViewCallout(final String wwName) => Useful.om.unhideCalloutByFeature(CAPI.TARGET_LISTVIEW_CALLOUT.feature(wwName));
//
void removeListViewCallout(final String wwName) => Useful.om.remove(CAPI.TARGET_LISTVIEW_CALLOUT.feature(wwName), true);

class CCTargetListViewContents extends StatelessWidget {
  final CAPIWidgetWrapperState parent;

  const CCTargetListViewContents(this.parent, {super.key});

  static double targetListH(final CAPIWidgetWrapperState parent) => parent.bloc.state.targets(parent.widget.wwName).length * 40;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        if (parent.bloc.state.wtMap.isNotEmpty)
          SizedBox.fromSize(
            size: Size(180, targetListH(parent)),
            child: ReorderableListView(
              onReorder: (int oldIndex, int newIndex) {
                CAPIWidgetWrapperState.hideAllTargets(bloc:parent.bloc, wwName: parent.widget.wwName);
                parent.bloc.add(CAPIEvent.changedOrder(wwName: parent.widget.wwName, oldIndex: oldIndex, newIndex: newIndex));
                Useful.afterNextBuildDo(() {
                  Useful.afterMsDelayDo(200, () {
                    CAPIWidgetWrapperState.showAllTargets(bloc:parent.bloc, wwName: parent.widget.wwName);
                  });
                });
              },
              children: [
                // for (String wwName in state.wtMap.keys)
                for (int index = 0; index < (parent.bloc.state.wtMap[parent.widget.wwName]?.length ?? 0); index++)
                  TargetItemView(
                    key: UniqueKey(),
                    parent,
                    parent.bloc.state.wtMap[parent.widget.wwName]![index],
                    index,
                  ),
              ],
            ),
          ),
        Divider(
          color: Colors.white,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: PlayButton(parent),
        ),
        CopyButton(parent.widget.wwName),
        // Spacer(),
        // SuspendButton(parent.widget.wwName),
      ],
    );
  }
}

class TargetItemView extends StatelessWidget {
  final CAPIWidgetWrapperState parent;
  final TargetConfig tc;
  final int index;

  const TargetItemView(this.parent, this.tc, this.index, {super.key});

  static Widget indexAvatar(TargetConfig tc, int index, bool isNotSelected) {
    Color selectedColor = tc.calloutColorValue == Colors.white.value ? Colors.grey : Colors.white;
    return SizedBox(
      width: 120,
      height: 30,
      child: Blink(
        bgColor: Colors.yellowAccent,
        dontAnimate: !isNotSelected,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                decoration: ShapeDecoration(
                  color: Color(tc.calloutColorValue ?? 128),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: !isNotSelected ? selectedColor : Colors.grey, width: !isNotSelected ? 4 : 1),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                child: SizedBox(
                  width: 160,
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      ' ${tc.calloutDurationMs} ',
                      style: TextStyle(color: Color(tc.textColorValue ?? 128), fontSize: 14),
                    ),
                  )),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                CAPIBloc.showStartTimeCallout(tc);
              },
              icon: Icon(
                Icons.timer,
                color: Colors.white,
              ),
              iconSize: 24,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.horizontal,
      key: UniqueKey(),
      onDismissed: (_) async {
        if (parent.bloc.state.aTargetIsSelected(parent.widget.wwName)) {
          await clearSelection(parent, tappedTc: parent.bloc.state.selectedTarget(parent.widget.wwName)!);
        }
        CAPIWidgetWrapperState.hideAllTargets(bloc:parent.bloc, wwName: parent.widget.wwName);
        await Future.delayed(Duration(milliseconds: 300));
        CAPIWidgetWrapperState.showAllTargets(bloc:parent.bloc, wwName: parent.widget.wwName);
        tc.bloc.add(CAPIEvent.deleteTarget(tc: tc));
        Useful.afterNextBuildDo(() {
          if (!tc.bloc.state.aTargetIsSelected(tc.wwName)) {
            Useful.afterMsDelayDo(200, () {
              CAPIWidgetWrapperState.showAllTargets(bloc:parent.bloc, wwName: parent.widget.wwName);
            });
          }
        });
      },
      child: SizedBox(
        child: InkWell(
          onTap: () async {
            if (tc.bloc.state.aTargetIsSelected(tc.wwName)) {
              if (tc.uid != tc.bloc.state.selectedTarget(tc.wwName)!.uid) {
                // tapped a different item to selected one
                removeTextEditorCallout();
                await clearSelection(parent, tappedTc: tc);
                CAPIWidgetWrapperState.hideAllTargets(bloc:parent.bloc, wwName: parent.widget.wwName);
                tc.bloc.add(CAPIEvent.selectTarget(tc: tc));
              } else {
                // tapped selected item
                await clearSelection(parent, tappedTc: tc);
                CAPIWidgetWrapperState.hideAllTargets(bloc:parent.bloc, wwName: parent.widget.wwName);
                await Future.delayed(Duration(milliseconds: 300));
                CAPIWidgetWrapperState.showAllTargets(bloc:parent.bloc, wwName: parent.widget.wwName);
              }
            } else {
              tc.bloc.add(CAPIEvent.selectTarget(tc: tc));
              CAPIWidgetWrapperState.hideAllTargets(bloc:parent.bloc, wwName: parent.widget.wwName, exception: tc.bloc.state.selectedTargetIndex(tc.wwName));
            }
          },
          onDoubleTap: () {
            // showStartTimeCallout(tc, tc.focusNode, tc.gk);
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TargetItemView.indexAvatar(tc, index, tc.bloc.state.selectedTargetIndex(tc.wwName) == index),
          ),
        ),
      ),
    );
  }

  static Future<void> clearSelection(final CAPIWidgetWrapperState parent, {required TargetConfig tappedTc}) async {
    // Useful.om.remove(CAPI.ANY_TOAST.feature(), true);
    removeTextEditorCallout();
    removeStylesCallout();
    parent.transformationController.removeListener(parent.onChangeTransformation);

    // // for selected item, save (convert) current callout pos + transfrom matrix back to normal coords
    TargetConfig selectedTc = parent.bloc.state.selectedTarget(parent.widget.wwName)!;
    //   parent.bloc.state.CC_TARGET_RADIUS(parent.widget.wwName),
    //   parent.bloc.state.CC_TARGET_RADIUS(parent.widget.wwName),
    // ));

    selectedTc.bloc.add(CAPIEvent.clearSelection(wwName: tappedTc.wwName));
  }
}

const double TARGET_LISTVIEW_CALLOUT_W = kIsWeb ? 180 : 140;

void createAndShowTargetListCallout(final CAPIWidgetWrapperState parent) {
  // if (!state.wtMap.containsKey(wwName)) return;

  double calloutH() {
    double h = 300;
    List<TargetConfig> list = parent.bloc.state.wtMap[parent.widget.wwName] ?? [];
    h += list.length * 30;
    // print("h(${bloc.state.selectedTargetIndex(widget.wwName)}) = $h");
    return h;
  }

  Rect? ivRect = CAPIAppWrapper.wwRect(parent.widget.wwName);

  if (ivRect == null) return;

  Offset targetListCalloutInitialPos = Offset(ivRect.right, ivRect.top-40);

  // Offset initialPos = stackMeasuredGlobalPos?.translate(-calloutW, stackMeasuredSize!.height - calloutH) ?? Offset.zero;
  Callout(
    feature: CAPI.TARGET_LISTVIEW_CALLOUT.feature(parent.widget.wwName),
    color: Colors.transparent,
    widthF: () => TARGET_LISTVIEW_CALLOUT_W,
    heightF: () => calloutH(),
    // resizeableV: true,
    // dragHandle: const Icon(Icons.drag_indicator, color: Colors.grey,),
    dragHandle: Container(
      color: Colors.white12,
      width: TARGET_LISTVIEW_CALLOUT_W,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            indent: 6,
            endIndent: 6,
            height: 10,
            thickness: 2,
            color: Colors.purpleAccent.withOpacity(.3),
          ),
          Divider(
            indent: 6,
            endIndent: 6,
            height: 10,
            thickness: 2,
            color: Colors.purpleAccent.withOpacity(.3),
          ),
          Divider(
            indent: 6,
            endIndent: 6,
            height: 10,
            thickness: 2,
            color: Colors.purpleAccent.withOpacity(.3),
          ),
          Divider(
            indent: 6,
            endIndent: 6,
            height: 10,
            thickness: 2,
            color: Colors.purpleAccent.withOpacity(.3),
          ),
          Divider(
            indent: 6,
            endIndent: 6,
            height: 10,
            thickness: 2,
            color: Colors.purpleAccent.withOpacity(.3),
          ),
        ],
      ),
    ),
    dragHandleHeight: 50,
    contents: () => Container(
      padding: const EdgeInsets.all(12),
      decoration: const ShapeDecoration(
        color: Colors.purpleAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          side: BorderSide(color: Colors.black12),
        ),
      ),
      child: CCTargetListViewContents(parent),
    ),
    initialCalloutPos: targetListCalloutInitialPos,
    ignoreCalloutResult: true,
    arrowType: ArrowType.NO_CONNECTOR,
    // onExpiredF: () {
    //   // Useful.afterMsDelayDo(500, () {
    //   //   createAndShowTargetListCallout(bloc);
    //   // });
    // },
  ).show(
    notUsingHydratedStorage: true,
  );
}
