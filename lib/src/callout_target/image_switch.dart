import 'package:flutter/material.dart';

import '../model/target_config.dart';

class ImageSwitch extends StatefulWidget {
  final TargetConfig tc;

  const ImageSwitch(this.tc, {super.key});

  @override
  State<ImageSwitch> createState() => _ImageSwitchState();
}

class _ImageSwitchState extends State<ImageSwitch> {
  late bool _useImage;

  @override
  void initState() {
    super.initState();
    _useImage = widget.tc.usingText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const ShapeDecoration(
          color: Colors.purpleAccent,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          )),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 10,
          ),
          IconButton(
            icon: const Icon(Icons.image),
            color: _useImage ? Colors.white : Colors.grey,
            iconSize: 30,
            onPressed: (){
              setState(() {
                _useImage = !_useImage;
                widget.tc.usingText = !_useImage;
              });

            },
          ),
          Switch(
            // This bool value toggles the switch.
            value: _useImage,
            inactiveThumbColor: Colors.grey,
            activeColor: Colors.white,
            onChanged: (bool value) {
              setState(() {
                _useImage = value;
                widget.tc.usingText = !value;
              });
            },
          ),
        ],
      ),
    );
  }
}
