import 'dart:math';

import 'package:flutter_callout_api/src/overlays/callouts/callout.dart';
import 'package:flutter_callout_api/src/useful.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef TextChangedF = void Function(String);
typedef TextStyleF = TextStyle Function();
typedef TextAlignF = TextAlign Function();

class TextEditor extends StatefulWidget {
  final String prompt;
  final int feature;
  final String originalS;
  final TextChangedF onChangedF;
  final Widget? prefixIcon;
  final double minHeight;
  final int? maxLines;
  final FocusNode focusNode;
  final bool dontAutoFocus;
  final Color? bgColor;
  final TextStyleF? textStyleF;
  final TextAlignF? textAlignF;

  static const double CONTENT_PADDING = 16.0;

  const TextEditor(
      {required this.prompt,
      required this.feature,
      required this.originalS,
      required this.onChangedF,
      this.prefixIcon,
      required this.minHeight,
      this.maxLines,
      required this.focusNode,
      required this.dontAutoFocus,
      this.bgColor,
      this.textStyleF,
      this.textAlignF,
      super.key});

  @override
  TextEditorState createState() => TextEditorState();
}

class TextEditorState extends State<TextEditor> {
  TextEditingController? _txtController;
  Callout? parentCallout;
  GlobalKey gk = GlobalKey(debugLabel: 'keys help icon');

  @override
  void initState() {
    super.initState();
    parentCallout = Useful.om.findCallout(widget.feature);

    widget.focusNode.addListener(() {
      print("Has focus: ${widget.focusNode.hasFocus}");
      // print("Useful.om.anyPresent([-4] is ${Useful.om.anyPresent([-4])}");
    });

    widget.focusNode.onKey = (node, event) {
      if (event.isKeyPressed(LogicalKeyboardKey.enter) && event.isShiftPressed) {
        node.unfocus();
        Useful.om.remove(parentCallout!.feature, true);
        // Do something
        // Next 2 line needed If you don't want to update the text field with new line.
        return KeyEventResult.handled;
      }
      if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
        node.unfocus();
        Useful.om.remove(parentCallout!.feature, false);
        // Do something
        // Next 2 line needed If you don't want to update the text field with new line.
        widget.onChangedF.call(widget.originalS);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };

    _txtController = TextEditingController();
    _txtController?.text = widget.originalS;
    if (!widget.dontAutoFocus) {
      Useful.afterNextBuildDo(() {
        widget.focusNode.requestFocus();
      });
    } else {
      widget.focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _txtController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int maxLines = widget.maxLines ?? max(1, (widget.minHeight / 22).round());
    // developer.log('height: ${parentCallout!.calloutSize!.height},  maxLines: $maxLines');

    TextStyle? ts = widget.textStyleF?.call();

    // Callout? f = Useful.om.findCallout(-4);

    return TextField(
      controller: _txtController,
      onTap: () {
        print("TextField tapped");
        // ensure callout free of soft keyboard - NOTE Scaffold.resizeToAvoidBottomInset must be false
        Useful.afterMsDelayDo(1000, () {
          if ((Useful.isIOS || Useful.isAndroid) && (parentCallout!.top! + parentCallout!.calloutSize.height) > (Useful.scrH - Useful.kbdH)) {
            parentCallout!.top = Useful.scrH - Useful.kbdH - parentCallout!.calloutSize.height - parentCallout!.draggableEdgeThickness * 2;
            parentCallout!.didAnimateYet = false;
            parentCallout!.animateTo(Offset(parentCallout!.left!, parentCallout!.top!), 300);
            Useful.afterMsDelayDo(350, () {
              parentCallout!.rebuildOverlays(() {
                parentCallout!.didAnimateYet = true;
              });
            });
          }
          if (parentCallout!.isOffscreen()) {
            parentCallout!.rebuildOverlays(() {});
          }
        });
      },
      onChanged: (s) {
        widget.onChangedF.call(s);
      },
      //controller: _txtController,
      decoration: InputDecoration(
        hintText: '${widget.prompt}',
        border: InputBorder.none,
        filled: true,
        fillColor: widget.bgColor ?? Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.all(TextEditor.CONTENT_PADDING),
        prefixIcon: widget.prefixIcon,
      ),
      autofocus: !widget.dontAutoFocus,
      focusNode: widget.focusNode,
      maxLines: null,
      //maxLines,
      minLines: null,
      expands: true,
      //step == null ? 1 : 2,
      keyboardType: TextInputType.multiline,
      autocorrect: false,
      enableInteractiveSelection: true,
      //scrollPadding: EdgeInsets.all(10),
      style: widget.textStyleF != null
          ? (widget.textStyleF!).call()
          : const TextStyle(fontSize: 16, fontFamily: 'monospace', letterSpacing: 2, color: Colors.blue),
      textAlign: widget.textAlignF != null ? (widget.textAlignF!).call() : TextAlign.left,
    );
  }
}
