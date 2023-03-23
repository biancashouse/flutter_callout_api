// import 'package:flutter/material.dart';
//
// import 'ken_burns/kenburns.dart';
// import 'useful.dart';
//
// class ScreenBg extends StatelessWidget {
//   final String imgAssetPath;
//   final Widget child;
//   final bool kenBurns;  //ignored until pkg migrated to null-safety
//   final double maxScale;
//   final double opacity;
//
//   const ScreenBg({required this.imgAssetPath, required this.child, this.kenBurns = false, this.maxScale=1.02, this.opacity = 1.0, Key? key,}) : super(key:key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         if (kenBurns)
//           Opacity(
//             opacity: opacity,
//             child: SizedBox(
//               height: Useful.scrH,
//               child: KenBurns(
//                 minAnimationDuration : const Duration(milliseconds: 3000),
//                 maxAnimationDuration : const Duration(milliseconds: 5000),
//                 maxScale: maxScale,
//                 child: Image.asset(imgAssetPath, fit: BoxFit.cover,),
//                 childW: Useful.scrW,
//                 childH: Useful.scrH
//               ),
//             ),
//           ),
//         if (!kenBurns)
//           Opacity(
//             opacity: opacity,
//             child: Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage(imgAssetPath),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//         child,
//       ],
//     );
//   }
// }
