import 'package:flutter/material.dart';
import 'package:flutter_callout_api/src/widget_helper.dart';
import 'package:flutter_callout_api/src/wrapper/app_wrapper.dart';
import 'package:flutter_callout_api/src/wrapper/transformable_widget_wrapper.dart';
import 'package:flutter_callout_api/src/wrapper/widget_wrapper.dart';

import 'src/wrapper/image_wrapper_auto.dart';

class BiancaPage extends StatelessWidget {
  const BiancaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ImageWrapperAuto(
        iwName: "bianca",
        aspectRatio: 1,
        imageF: () => Image(image: AssetImage('images/developer-logo-512x512.png'), fit: BoxFit.cover),
        // imageF: ()=>assetPicWithFadeIn(
        //   path: 'images/developer-logo-512x512.png',
        //   padding: EdgeInsets.zero,
        //   alignment: Alignment.center,
        // ),
      ),
    );
  }
}
