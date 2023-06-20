import 'package:flutter/material.dart';
import 'package:flutter_callout_api/src/widget_helper.dart';
import 'package:flutter_callout_api/src/wrapper/app_wrapper.dart';
import 'package:flutter_callout_api/src/wrapper/transformable_widget_wrapper.dart';
import 'package:flutter_callout_api/src/wrapper/widget_wrapper.dart';

import 'src/wrapper/image_wrapper_auto.dart';

class CatsPage extends StatelessWidget {
  const CatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ImageWrapperAuto(
        // twName: "main_scaffold_body",
        iwName: "cats",
        aspectRatio: 3516 / 1534,
        hardEdge: true,
        imageF: () => assetPicWithFadeIn(
          path: 'images/top-cat-gang.png',
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
