import 'package:flutter_callout_api/callout_api.dart';
import 'package:flutter_callout_api/src/bloc/capi_bloc.dart';
import 'package:flutter_callout_api/src/bloc/capi_event.dart';
import 'package:flutter_callout_api/src/callout_ivrect.dart';
import 'package:flutter_callout_api/src/list/targetlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// this widget must enclose your MaterialApp, or CupertinoApp or WidgetsApp
/// so that the CAPIBloc becomes available to overlays, which are placed into
/// the app's overlay and not in your widget tree as you might have expected.
class CAPIAppWrapper extends StatefulWidget {
  final String initialValueJsonAssetPath;
  final ContentFunc childF;
  final bool localTestingFilePaths;
  final bool runningInProduction;

  // want new sizes to be available immediately after changing, hence not part of bloc, but static (global) instead
  static Map<String, GlobalKey> wwGKMap = {};
  static Map<String, Offset> wwPosMap = {};
  static Map<String, Size> wwSizeMap = {};

  static Size wwSize(String wwName) => wwSizeMap[wwName] ?? Size.zero;

  static Offset wwPos(String wwName) => wwPosMap[wwName] ?? Offset.zero;

  static Rect wwRect(String wwName) => Rect.fromLTWH(
        wwPos(wwName).dx,
        wwPos(wwName).dy,
        wwSize(wwName).width,
        wwSize(wwName).height,
      );

  CAPIAppWrapper({
    required this.initialValueJsonAssetPath,
    required this.childF,
    this.localTestingFilePaths = false,
    this.runningInProduction = false,
    super.key,
  });

  @override
  State<CAPIAppWrapper> createState() => _CAPIAppWrapperState();
}

class _CAPIAppWrapperState extends State<CAPIAppWrapper> {
  late CAPIBloc capiBloc;

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
  void didChangeDependencies() {
    Useful.instance.initWithContext(context, force: true);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        return NotificationListener<SizeChangedLayoutNotification>(
          onNotification: (SizeChangedLayoutNotification notification) {
            print("_CAPIAppWrapperState onNotification");
            return true;
          },
          child: SizeChangedLayoutNotifier(
            child: BlocProvider(
              create: (BuildContext context) => capiBloc,
              child: widget.childF.call(),
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
