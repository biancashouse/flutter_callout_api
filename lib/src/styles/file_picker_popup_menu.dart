import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callout_api/callout_api.dart';

import '../model/target_config.dart';

class FilePickerPopupMenu extends StatefulWidget {
  final TargetConfig tc;
  final ScrollController? ancestorHScrollController;
  final ScrollController? ancestorVScrollController;

  const FilePickerPopupMenu({
    super.key,
    required this.tc,
    this.ancestorHScrollController,
    this.ancestorVScrollController,
  });

  static Future<void> pickImage(
    FileType fType,
    final TargetConfig tc, {
    bool mounted = false,
  }) async {
    Useful.om.showCircularProgressIndicator(true, reason: 'Picking an Image');
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: fType,
      withData: true,
    );
    Future<ui.Image> bytesToUiImage(Uint8List bytes) async {
      ui.Codec codec = await ui.instantiateImageCodec(bytes);
      ui.FrameInfo fi = await codec.getNextFrame();
      return fi.image;
    }

    Future<Uint8List> uiImageToBytes(ui.Image image) async {
      var byteData = await (image.toByteData(format: ui.ImageByteFormat.png) as FutureOr<ByteData>);
      return byteData.buffer.asUint8List();
    }

    Useful.om.showCircularProgressIndicator(false, reason: 'Picking an Image');
    Useful.om.showCircularProgressIndicator(true, reason: 'Picked an Image');
    if (result != null && result.files.isNotEmpty && mounted) {
      PlatformFile file = result.files.first;
      Uint8List? pickedFileBytes = file.bytes;
      if (pickedFileBytes != null && pickedFileBytes.lengthInBytes > 0) {
        ui.Image img = await bytesToUiImage(file.bytes!);
        developer.log('actual size (${img.width} v ${img.height}) storage: ${file.bytes?.toList().length} bytes');
        // _bytes = await compressImage(file.bytes!, min(512,img.width.toDouble()), .85);
        // ui.Image compressedImg = await bytesToUiImage(_bytes!);
        // developer.log('scaled down size (${compressedImg.width} v ${compressedImg.height}) storage: ${_bytes?.toList().length} bytes');
        // FlowchartM cleanClone = widget.flowchart.cleanClone();
        // if (widget.comment != null) {
        //   widget.flowchart.editingPageState?.editorBloc.add(EditorEvent.commentImageChanged(newBytes: file.bytes, stepId: widget.stepId!, skipUndoCreation: true));
        // } else {
        //   widget.flowchart.editingPageState?.editorBloc.add(EditorEvent.flowchartImageChanged(newBytes: file.bytes, skipUndoCreation: true));
        // }
        Useful.om.removeAll();
      }
    }
    Useful.om.showCircularProgressIndicator(false, reason: 'Picked an Image');
  }

  @override
  FilePickerPopupMenuState createState() => FilePickerPopupMenuState();
}

class FilePickerPopupMenuState extends State<FilePickerPopupMenu> {
  TextEditingController? _txtController;

  @override
  void initState() {
    super.initState();

    widget.tc.imageUrlFocusNode().addListener(() {
      print("Has focus: ${widget.tc.imageUrlFocusNode().hasFocus}");
      // print("Useful.om.anyPresent([-4] is ${Useful.om.anyPresent([-4])}");
    });

    widget.tc.imageUrlFocusNode().onKey = (node, event) {
      if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
        node.unfocus();
        Useful.om.remove(CAPI.PICK_IMAGE.feature(), true);
        return KeyEventResult.handled;
      }
      if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
        node.unfocus();
        Useful.om.remove(CAPI.PICK_IMAGE.feature(), false);
        // Do something
        // Next 2 line needed If you don't want to update the text field with new line.
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };

    _txtController = TextEditingController();
    _txtController?.text = widget.tc.calloutImageUrl ?? "http";

    // Useful.afterNextBuildDo(() {
    //   widget.tc.focusNode().requestFocus();
    // });
  }

  @override
  void dispose() {
    _txtController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 60,),
        Expanded(
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...getMenuItems(),
              ],
            ),
          ),
        ),
        SizedBox(width: 60,),
      ],
    );
  }

  List<Widget> getMenuItems() {
    List<Widget> menuItems = [];

    menuItems.add(
        // from GALLERY
        Container(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () async {
          FilePickerPopupMenu.pickImage(FileType.image, widget.tc, mounted: mounted);
        },
        label: text16('pick from the image gallery'),
        icon: Icon(
          Icons.image,
          size: 28,
          color: Colors.purpleAccent,
        ),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.white,
          disabledForegroundColor: Colors.grey,
        ),
      ),
    ));

    menuItems.add(
        // from FILE SYSTEM
        Container(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () async {
          FilePickerPopupMenu.pickImage(FileType.any, widget.tc, mounted: mounted);
        },
        label: text16('pick from the file system'),
        icon: Icon(
          Icons.folder,
          size: 28,
          color: Colors.teal,
        ),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.white,
          disabledForegroundColor: Colors.grey,
        ),
      ),
    ));

    menuItems.add(
        // from WEB
        Container(
      width: double.infinity,
      color: Colors.purpleAccent,
      child: Column(
        children: [
          Text(
            "or, specify an image on the web:\n",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          TextField(
            controller: _txtController,
            onChanged: (s) {
              widget.tc.calloutImageUrl = s;
            },
            style: TextStyle(color: Colors.black, fontSize: 24),
            decoration: InputDecoration(
              hintText: 'web URL',
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(TextEditor.CONTENT_PADDING),
            ),
            maxLines: 2,
            focusNode: widget.tc.imageUrlFocusNode(),
          ),
        ],
      ),
    ));

    return menuItems
        .map((Widget mi) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: mi,
            ))
        .toList();
  }
}
