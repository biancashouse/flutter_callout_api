
import 'package:flutter/material.dart';
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_event.dart';
import 'package:flutter_callout_api/src/overlays/callouts/callout.dart';
import 'package:flutter_callout_api/src/overlays/callouts/toast.dart';

class CopyButton extends StatelessWidget {
  static const double BUTTON_SIZE = 30;
  final String iwName;

  const CopyButton(this.iwName, {super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      radius: CopyButton.BUTTON_SIZE,
      child: IconButton(
        iconSize: CopyButton.BUTTON_SIZE,
        icon: const Icon(
          Icons.copy,
          color: Colors.grey,
        ),
        onPressed: () async {
          copyToJson(context);
        },
      ),
    );
  }

  static void copyToJson(context) {
    CAPIBloc bloc = context.read<CAPIBloc>();
    bloc.add(const CAPIEvent.copyToClipboard());

    TextToast(
        feature: CAPI.ANY_TOAST.feature(),
        msgText: "Config json copied to clipboard - use this to create your CCAppWrapper instance",
        backgroundColor: Colors.purpleAccent,
        textColor: Colors.yellowAccent,
        widthF: () => 600,
        heightF: () => 80).show(
      removeAfterMs: SECS(10),
      notUsingHydratedStorage: true,
    );

  }
}
