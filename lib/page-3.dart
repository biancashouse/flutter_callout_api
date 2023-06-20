// import 'package:flutter/material.dart';
// import 'package:flutter_callout_api/src/widget_helper.dart';
// import 'package:flutter_callout_api/src/wrapper/app_wrapper.dart';
// import 'package:flutter_callout_api/src/wrapper/transformable_widget_wrapper.dart';
// import 'package:flutter_callout_api/src/wrapper/widget_wrapper.dart';
//
// import 'src/wrapper/image_wrapper_auto.dart';
//
// class Page3 extends StatelessWidget {
//   const Page3({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     print("main build");
//     return MaterialAppWrapper(
//       initialValueJsonAssetPath: "callout-scripts/sample-config.json",
//       localTestingFilePaths: true,
//       runningInProduction: false,
//       materialAppF: () => MaterialApp(
//         home: TransformableWidgetWrapper(
//           twName: "main_scaffold",
//           widgetF: () => Scaffold(
//             appBar: AppBar(
//               title: const Text('Flutter Callout API sample'),
//               leading: WidgetWrapper(
//                 twName: "main",
//                 wwName: 'phone',
//                 ancestorHScrollController: hsc,
//                 ancestorVScrollController: vsc,
//                 initialTargetAlignment: Alignment.bottomCenter,
//                 initialCalloutAlignment: Alignment.topLeft,
//                 child: IconButton(
//                   icon: const Icon(Icons.call),
//                   iconSize: 36,
//                   color: Colors.yellow,
//                   onPressed: () {
//                     print("phone");
//                   },
//                 ),
//               ),
//               actions: [
//                 WidgetWrapper(
//                   twName: "main",
//                   wwName: 'clock',
//                   initialTargetAlignment: Alignment.bottomCenter,
//                   initialCalloutAlignment: Alignment.topCenter,
//                   ancestorHScrollController: hsc,
//                   child: IconButton(
//                     icon: const Icon(Icons.access_time),
//                     iconSize: 36,
//                     color: Colors.red,
//                     onPressed: () {
//                       print("clock");
//                     },
//                   ),
//                 ),
//                 const SizedBox(
//                   width: 50,
//                 ),
//                 WidgetWrapper(
//                   twName: "main",
//                   wwName: 'building',
//                   initialTargetAlignment: Alignment.bottomCenter,
//                   initialCalloutAlignment: Alignment.topRight,
//                   ancestorHScrollController: hsc,
//                   ancestorVScrollController: vsc,
//                   child: IconButton(
//                     icon: const Icon(Icons.account_balance),
//                     iconSize: 36,
//                     color: Colors.green,
//                     onPressed: () {
//                       print("theatre");
//                     },
//                   ),
//                 ),
//                 const SizedBox(
//                   width: 50,
//                 ),
//               ],
//             ),
//             bottomSheet: SizedBox(
//               height: 50,
//               child: BottomSheet(
//                 enableDrag: false,
//                 builder: (context) => Row(
//                   mainAxisSize: MainAxisSize.max,
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     WidgetWrapper(
//                       twName: "main",
//                       wwName: 'accessibility',
//                       initialTargetAlignment: Alignment.topCenter,
//                       initialCalloutAlignment: Alignment.bottomLeft,
//                       ancestorHScrollController: hsc,
//                       ancestorVScrollController: vsc,
//                       child: IconButton(
//                         icon: const Icon(Icons.accessibility),
//                         iconSize: 36,
//                         color: Colors.pink,
//                         onPressed: () {
//                           print("accessibility");
//                         },
//                       ),
//                     ),
//                     WidgetWrapper(
//                       twName: "main",
//                       wwName: 'garage',
//                       initialTargetAlignment: Alignment.topCenter,
//                       initialCalloutAlignment: Alignment.bottomCenter,
//                       ancestorHScrollController: hsc,
//                       ancestorVScrollController: vsc,
//                       child: IconButton(
//                         icon: const Icon(Icons.garage),
//                         iconSize: 36,
//                         color: Colors.brown,
//                         onPressed: () {
//                           print("garage");
//                         },
//                       ),
//                     ),
//                     WidgetWrapper(
//                       twName: "main",
//                       wwName: 'sailing',
//                       initialTargetAlignment: Alignment.topCenter,
//                       initialCalloutAlignment: Alignment.bottomRight,
//                       ancestorHScrollController: hsc,
//                       ancestorVScrollController: vsc,
//                       child: IconButton(
//                         icon: const Icon(Icons.sailing),
//                         iconSize: 36,
//                         color: Colors.blue[700],
//                         onPressed: () {
//                           print("sailing");
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 onClosing: () {},
//               ),
//             ),
//             body: Center(
//               child: Stack(
//                   children: [
//                     ListView(
//                       scrollDirection: Axis.vertical,
//                       controller: vsc,
//                       children: [
//                         _cats(),
//                         Container(
//                           width: testw,
//                           height: testh,
//                           color: Colors.redAccent,
//                         ),
//                         Container(
//                           width: testw,
//                           height: testh,
//                           color: Colors.redAccent,
//                         ),
//                         _bianca(),
//                         Container(
//                           width: testw,
//                           height: testh,
//                           color: Colors.redAccent,
//                         ),
//                       ],
//                     ),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: WidgetWrapper(
//                         twName: "main",
//                         wwName: 'cloud',
//                         initialTargetAlignment: Alignment.centerRight,
//                         initialCalloutAlignment: Alignment.centerLeft,
//                         ancestorHScrollController: hsc,
//                         ancestorVScrollController: vsc,
//                         child: IconButton(
//                           icon: const Icon(Icons.cloud_circle),
//                           iconSize: 36,
//                           color: Colors.black,
//                           onPressed: () {
//                             print("cloud");
//                           },
//                         ),
//                       ),
//                     ),
//                     Align(
//                       alignment: Alignment.center,
//                       child: WidgetWrapper(
//                         twName: "main",
//                         wwName: 'snowflake',
//                         initialTargetAlignment: Alignment.topCenter,
//                         initialCalloutAlignment: Alignment.bottomCenter,
//                         ancestorHScrollController: hsc,
//                         ancestorVScrollController: vsc,
//                         child: IconButton(
//                           icon: const Icon(Icons.ac_unit),
//                           iconSize: 36,
//                           color: Colors.teal,
//                           onPressed: () {
//                             print("snowflake");
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _cats() => ImageWrapperAuto(
//         // twName: "main_scaffold_body",
//         iwName: "cats",
//         // ancestorHScrollController: hsc,
//         ancestorVScrollController: vsc,
//         aspectRatio: 3516 / 1534,
//         hardEdge: true,
//         imageF: () => assetPicWithFadeIn(
//           path: 'images/top-cat-gang.png',
//           padding: EdgeInsets.zero,
//           alignment: Alignment.center,
//           fit: BoxFit.contain,
//         ),
//       );
//
//   Widget _bianca() => ImageWrapperAuto(
//         // twName: "main_scaffold_body",
//         iwName: "bianca",
//         ancestorHScrollController: hsc,
//         ancestorVScrollController: vsc,
//         aspectRatio: 1,
//         imageF: () => Image(image: AssetImage('images/developer-logo-512x512.png'), fit: BoxFit.cover),
//         // imageF: ()=>assetPicWithFadeIn(
//         //   path: 'images/developer-logo-512x512.png',
//         //   padding: EdgeInsets.zero,
//         //   alignment: Alignment.center,
//         // ),
//       );
//
//   Widget _aibo() => ImageWrapperAuto(
//         // twName: "main_scaffold_body",
//         iwName: "aibo",
//         // ancestorHScrollController: hsc,
//         ancestorVScrollController: vsc,
//         aspectRatio: 2984 / 1940,
//         imageF: () => assetPicWithFadeIn(
//           path: 'images/pepper-and-aibo.png',
//           padding: EdgeInsets.zero,
//           alignment: Alignment.center,
//           fit: BoxFit.fitHeight,
//         ),
//       );
// }