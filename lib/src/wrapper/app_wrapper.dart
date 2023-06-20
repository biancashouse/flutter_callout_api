import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_event.dart';

typedef MaterialAppFunc = MaterialApp Function();

/// this widget must enclose your MaterialApp, or CupertinoApp or WidgetsApp
/// so that the CAPIBloc becomes available to overlays, which are placed into
/// the app's overlay and not in your widget tree as you might have expected.
class MaterialAppWrapper extends StatefulWidget {
  final String initialValueJsonAssetPath;
  final MaterialAppFunc materialAppF;
  final bool localTestingFilePaths;
  final bool runningInProduction;

  MaterialAppWrapper({
    required this.initialValueJsonAssetPath,
    this.localTestingFilePaths = false,
    this.runningInProduction = false,
    required this.materialAppF,
    super.key,
  });

  @override
  State<MaterialAppWrapper> createState() => _MaterialAppWrapperState();
}

class _MaterialAppWrapperState extends State<MaterialAppWrapper> {
  late CAPIBloc capiBloc;
  double? _prevScrW;
  double? _prevScrH;
  double _prevKbdH = 0;

  @override
  void initState() {
    capiBloc = CAPIBloc();
    capiBloc.add(CAPIEvent.initApp(
      initialValueJsonAssetPath: widget.initialValueJsonAssetPath,
      localTestingFilePaths: widget.localTestingFilePaths,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        return NotificationListener<SizeChangedLayoutNotification>(
          onNotification: (SizeChangedLayoutNotification notification) {
            print("_CAPIAppWrapperState onNotification: ${notification.toString()}");
            // MaterialAppWrapper.iwSizeMap = {};
            bool screenSizeChanged = false;
            if ((_prevScrW ?? 0) != Useful.scrW) {
              _prevScrW = Useful.scrW;
              screenSizeChanged = true;
            }
            if (!screenSizeChanged || (_prevScrH ?? 0) != Useful.scrH) {
              _prevScrH = Useful.scrH;
              screenSizeChanged = true;
            }
            return screenSizeChanged;
          },
          child: SizeChangedLayoutNotifier(
            child: BlocProvider(
              create: (BuildContext context) => capiBloc,
              child: widget.materialAppF.call(),
            ),
          ),
        );
      });
}

extension ExtendedOffset on Offset {
  String toFlooredString() {
    return '(${dx.floor()}, ${dy.floor()})';
  }
}
