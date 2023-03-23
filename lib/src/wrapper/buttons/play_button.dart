
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_event.dart';
import 'package:flutter_callout_api/src/list/targetlistview.dart';
import 'package:flutter_callout_api/src/overlays/callouts/callout.dart';
import 'package:flutter_callout_api/src/overlays/callouts/toast.dart';
import 'package:flutter_callout_api/src/useful.dart';
import 'package:flutter_callout_api/src/wrapper/widget_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayButton extends StatelessWidget {
  static const double BUTTON_SIZE = 30;
  final CAPIWidgetWrapperState parent;

  const PlayButton(this.parent, {super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: parent.bloc.state.aTargetIsSelected(parent.widget.wwName) ? Colors.white12 : Colors.white,
      radius: BUTTON_SIZE,
      child: IconButton(
        iconSize: BUTTON_SIZE,
        icon: Icon(
          Icons.play_arrow_sharp,
          color: parent.bloc.state.aTargetIsSelected(parent.widget.wwName) ? Colors.blue.withOpacity(.2) : Colors.blue[500],
        ),
        onPressed: () {
          if (parent.bloc.state.aTargetIsSelected(parent.widget.wwName)) return;
          CAPIBloc bloc = context.read<CAPIBloc>();
          if (bloc.state.numTargetsOnPage() == 0) {
            bloc.playErrorSound();
            TextToast(
                feature: CAPI.ANY_TOAST.feature(),
                msgText: "No targets found on this page !",
                backgroundColor: Colors.red[900]!,
                textColor: Colors.yellowAccent,
                widthF: () => 500,
                heightF: () => 50).show(removeAfterMs: SECS(2), notUsingHydratedStorage: true);
          } else {
            bloc.playPlopSound();

            // widget.parent.hideAllTargets();
            // widget.parent.transformationController.value = Matrix4.identity();
            // widget.parent.onChangeTransformation();
            parent.transformationController.removeListener(parent.onChangeTransformation);
            removeListViewCallout(parent.widget.wwName);
            bloc.add(CAPIEvent.startPlaying(wwName: parent.widget.wwName));
          }
        },
      ),
    );
  }
}
