
import 'package:callout_api/src/blink.dart';
import 'package:callout_api/src/bloc/capi_bloc.dart';
import 'package:callout_api/src/bloc/capi_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SuspendButton extends StatelessWidget {
  static const double BUTTON_SIZE = 30;
  final String wwName;

  const SuspendButton(this.wwName, {super.key});

  @override
  Widget build(BuildContext context) {
    CAPIBloc bloc = context.read<CAPIBloc>();
    return CircleAvatar(
      backgroundColor: Colors.purpleAccent,
      radius: SuspendButton.BUTTON_SIZE,
      child: !bloc.state.isSuspended(wwName)
          ? Offstage()
          : Blink(
              child: buildIconButton(bloc),
            ),
    );
  }

  IconButton buildIconButton(bloc) {
    return IconButton(
      iconSize: SuspendButton.BUTTON_SIZE,
      icon: const Icon(
        Icons.power_settings_new,
        color: Colors.white,
      ),
      onPressed: () async {
        if (bloc.state.isSuspended(wwName)) {
          bloc.add( CAPIEvent.resume(wwName: wwName));
        }
      },
    );
  }
}
