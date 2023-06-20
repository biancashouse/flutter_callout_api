import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_callout_api/src/cpi_reason_stack.dart';
import 'package:flutter_callout_api/src/feature_discovery/featured_widget.dart';
import 'package:flutter_callout_api/src/useful.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../overlays/callouts/callout.dart';
import '../overlays/callouts/toast.dart';
//import 'responsive_helper.dart';

/// idea is to keep track of overlay entries currently in the root overlay, so
/// it easy to ensure all get removed if, say, back button tapped etc.
class OverlayManager {
  final OverlayState overlayState;

  // final List<Object> _overlayItems = []; // OverlayEntry or Callout or Toast

  final List<int> _featureStack = []; // 0th element is the top most item
  final Map<int, Object> _calloutMap = {}; // actually callouts (incl Toasts) and DiscoveryWidgets
  final Map<int, List<OverlayEntry>> _entryMap = {};

  // always append entries, and remove from end of list; i.e. treat like a stack

  // int itemCount() => _overlayItems.length;

  // private, named constructor
  OverlayManager(this.overlayState) {
    print("OverlayManager");
  }

  void overlaySetState({VoidCallback? f}) {
    // because not allowed to setState from outside of the state itself !
    if (overlayState.mounted) {
      overlayState.setState(f ?? (){});
    } else {
      throw ('overlayState not mouted!');
    }
  }

  // void insertOverlayEntry(OverlayEntry entry, {bool isPartOfACallout = false}) {
  //   if (false) developer.log('insertOverlayEntry', name: 'om');
  //   _overlayState.insert(entry);
  //   if (!isPartOfACallout) _overlayItems.add(entry);
  // }

  Callout? findCallout(int theFeature) {
    Object? result = _calloutMap[theFeature];
    return result != null && result is Callout ? result : null;
  }

  FeaturedWidget? findFeaturedWidget(int theFeature) {
    Object? result = _calloutMap[theFeature];
    return result != null && result is FeaturedWidget ? result : null;
  }

  // returns whether any of the features is present
  // if no feature provided as an arg, return whether ANY callout are present
  bool anyPresent(List<int> features) {
    if (features.isEmpty) {
      return _featureStack.isNotEmpty;
    } else {
      for (int feature in features) {
        if (_calloutMap.keys.contains(feature)) return true;
      }
    }
    return false;
  }

  void insertCalloutOverlayEntry(Callout callout, OverlayEntry entry) {
    if (!_featureStack.contains(callout.feature)) _featureStack.insert(0, callout.feature);
    if (!_calloutMap.containsKey(callout.feature)) _calloutMap[callout.feature] = callout;
    if (!_entryMap.containsKey(callout.feature)) _entryMap[callout.feature] = [];
    Timer.run(() {
      overlayState.insert(entry);
      _entryMap[callout.feature]?.add(entry);
    });
  }

  void insertFeaturedWidgetOverlayEntry(FeaturedWidget fw, OverlayEntry entry) {
    if (!_featureStack.contains(fw.featureEnum)) _featureStack.insert(0, fw.featureEnum);
    if (!_calloutMap.containsKey(fw.featureEnum)) _calloutMap[fw.featureEnum] = fw;
    if (!_entryMap.containsKey(fw.featureEnum)) _entryMap[fw.featureEnum] = [];
    Timer.run(() {
      overlayState.insert(entry);
      _entryMap[fw.featureEnum]!.add(entry);
    });
  }

  void remove(int feature, [bool theResult = true]) {
    Callout? callout = findCallout(feature);
    if (callout != null) {
      List<OverlayEntry> toBeRemoved = []..addAll(_entryMap[feature] ?? []);
      for (OverlayEntry entry in toBeRemoved) {
        try {
          entry.remove();
          _entryMap[feature]?.remove(entry);
        } catch (e) {
          print("remove(${feature}) - ${e.toString()}");
        }
      }
      _calloutMap.remove(feature);
      _featureStack.remove(feature);
      _entryMap.remove(feature);
      callout.completed(theResult);
    } else {
      FeaturedWidget? fw = findFeaturedWidget(feature);
      if (fw != null) {
        List<OverlayEntry> toBeRemoved = []..addAll(_entryMap[feature] ?? []);
        for (OverlayEntry entry in toBeRemoved) {
          try {
            entry.remove();
            _entryMap[feature]?.remove(entry);
          } catch (e) {
            print("remove(${feature}) - ${e.toString()}");
          }
        }
        _calloutMap.remove(feature);
        _featureStack.remove(feature);
        _entryMap.remove(feature);
      }
    }
  }

  void removeTopFeature(bool theResult) {
    if (_featureStack.isNotEmpty) {
      remove(_featureStack[0], theResult);
    }
  }

  void removeAll({bool exceptToast = false, bool skipCC = true, bool theResult = true}) {
    List<int> keysToRemove = [];
    for (int feature in _calloutMap.keys) {
      if ((!skipCC || feature > -1) /* && _calloutMap[feature] is! ToastCallout */) {
        keysToRemove.add(feature);
      }
    }
    for (int feature in keysToRemove) {
      remove(feature, theResult);
    }
  }

  void removeToasts({bool theResult = true}) {
    List<int> keysToRemove = [];
    for (int feature in _calloutMap.keys) {
      if (_calloutMap[feature] is ToastCallout) {
        keysToRemove.add(feature);
      }
    }
    for (int feature in keysToRemove) {
      remove(feature, theResult);
    }
  }

  void removeAllExceptFor({List<int>? exceptions, bool theResult = true}) {
    List<int> keysToRemove = [];
    for (int feature in _calloutMap.keys) {
      if (!(exceptions ?? []).contains(feature)) {
        keysToRemove.add(feature);
      }
    }
    for (int feature in keysToRemove) {
      remove(feature, theResult);
    }
  }

  void removeParentCallout(BuildContext ctx, bool result) {
    CalloutParent? calloutParent = ctx.findAncestorWidgetOfExactType<CalloutParent>();
    if (calloutParent != null) {
      remove(calloutParent.callout.feature, result);
    }
  }

  void hide(int feature) {
    Callout? c = findCallout(feature);
    if (c != null) {
      c.hide();
    }
  }

  void unhide(int feature) {
    Callout? c = findCallout(feature);
    if (c != null) {
      c.unhide();
    }
  }

  void refreshAll() {
    for (Object o in _calloutMap.values) {
      if (o is Callout) {
        o.refresh();
      }
    }
  }

  // void refreshAllCallouts() {
  //   print('Overlay Helper refresh');
  //   if (false) developer.log('refresh', name: 'om');
  //   for (var el in _overlayItems) {
  //     // if (el is ToastCallout) {
  //     //   // el.refresh(() => el.tR = el.targetRectangle());
  //     //   el.refresh((){});
  //     // }
  //     if (el is Callout) {
  //       Callout callout = el;
  //       callout.refreshOverlay(() {
  //         callout.widthF = callout.originalWidthF;
  //         callout.heightF = callout.originalHeightF;
  //         // callout.tR = callout.targetRectangle();
  //         callout.possibleMeasure().then((_) {
  //           callout.didAnimateYet = false;
  //           callout.initialAnimatedPositionDurationMs = 500;
  //           callout.calcContentTopLeft();
  //           callout.refreshOverlay(() {
  //             // callout.tR = callout.targetRectangle();
  //             callout.didAnimateYet = false;
  //             callout.initialAnimatedPositionDurationMs = 500;
  //             callout.calcContentTopLeft();
  //             Future.delayed(const Duration(milliseconds: 500), () {
  //               callout.refreshOverlay(() {
  //                 callout.didAnimateYet = true;
  //               });
  //             });
  //           });
  //         });
  //         //callout.didAnimateYet = true;
  //       });
  //     }
  //   }
  // }

  // void refreshIfOffscreen({bool force = false}) {
  //   for (var el in _overlayItems) {
  //     if (el is ToastCallout) {
  //       el.refreshOverlay(() => el.tR = el.targetRectangle());
  //     } else if (el is Callout) {
  //       Callout callout = el;
  //       callout.refresh();
  //     }
  //   }
  // }

  // void refreshCallout(Callout callout) {
  //   if (false) developer.log('refreshCallout', name: 'om');
  //   callout.refresh(() => callout.tR = callout.targetRectangle());
  // }

// void refreshCallout(Callout callout) {
//   if (false) developer.log('refreshCallout', name: 'om');
//   callout.refreshOverlay(() {
//     callout.widthF = callout.originalWidthF;
//     callout.heightF = callout.originalHeightF;
//     // callout.tR = callout.targetRectangle();
//     callout.tR = callout.targetRectangle();
//     callout.possibleMeasure().then((_) {
//       callout.didAnimateYet = false;
//       callout.initialAnimatedPositionDurationMs = 500;
//       callout.calcContentTopLeft();
//       callout.refreshOverlay(() {
//         // callout.tR = callout.targetRectangle();
//         callout.didAnimateYet = false;
//         callout.initialAnimatedPositionDurationMs = 500;
//         callout.calcContentTopLeft();
//         Future.delayed(const Duration(milliseconds: 500), () {
//           callout.refreshOverlay(() {
//             callout.didAnimateYet = true;
//           });
//         });
//       });
//     });
//     //callout.didAnimateYet = true;
//   });
// }

// void reinit() {
//   for (var element in _overlayItems) {
//     if (element is Callout) element.init();
//     if (element is ToastCallout) element.init();
//   }
// }

// void refreshAllEntries() async {
//   overlayState.refresh(() {
//     overlayItems.forEach((element) {
//       if (element is Callout)
//         element.tR = element.targetRectangle();
//     });
//     if (false) developer.log('refreshAll()', name:'om');
//   });
// }

// void removeCallout(Callout theCallout, bool theResult) {
//   if (_overlayItems.contains(theCallout)) {
//     int pos = _overlayItems.indexOf(theCallout);
//     Callout foundCallout = _overlayItems[pos] as Callout;
//     foundCallout.completed(theResult);
//     _overlayItems.remove(foundCallout);
//     print("num overlay items is now: ${_overlayItems.length}");
//   }
// }
//
// void removeToast(ToastCallout theToast, bool theResult) {
//   if (_overlayItems.contains(theToast)) {
//     int pos = _overlayItems.indexOf(theToast);
//     ToastCallout foundToast = _overlayItems[pos] as ToastCallout;
//     foundToast.completed(theResult);
//     _overlayItems.remove(theToast);
//     print("num overlay items is now: ${_overlayItems.length}");
//   }
// }

// ToastCallout? findToast(int theFeature) {
//   for (Object el in _overlayItems) {
//     if (el is ToastCallout && el.feature == theFeature) return el;
//   }
//   return null;
// }
//
// int findRelated() {
//   int count = 0;
//   for (Object el in _overlayItems) {
//     if (el is! Callout && el is! ToastCallout) {
//       count++;
//     }
//   }
//   return count;
// }

// void refreshCalloutBubbleByFeature(int feature, VoidCallback func) {
//   Callout? callout = findCallout(feature);
//   if (callout != null) {
//     callout.updateTarget;
//   }
// }

  void refreshCalloutByFeature(int feature, VoidCallback func) {
    findCallout(feature)?.rebuildOverlays(func);
  }

// void removeToastByFeature(int feature, bool theResult) {
//   if (false) developer.log('removeToastByFeature', name: 'om');
//   ToastCallout? c = findToast(feature);
//   if (c != null) removeToast(c, theResult);
// }

// void removeTopCallout() {
//   if (_overlayItems.isNotEmpty) {
//     int topPos = _overlayItems.length - 1;
//     if (_overlayItems[topPos] is Callout) {
//       Callout c = _overlayItems[topPos] as Callout;
//       removeCallout(c, false);
//     }
//   }
// }

// void removeTopToast() {
//   if (false) developer.log('removeTopToast', name: 'om');
//   if (_overlayItems.isNotEmpty) {
//     int topPos = _overlayItems.length - 1;
//     if (_overlayItems[topPos] is ToastCallout) {
//       ToastCallout c = _overlayItems[topPos] as ToastCallout;
//       removeToast(c, false);
//     }
//   }
// }

// void clearAllCallouts({List<int> exceptions = const []}) {
//   if (false) developer.log('clearAllCallouts', name: 'om');
//   for (int i = _overlayItems.length; i > 0; i--) {
//     Object el = _overlayItems[i - 1];
//     if (el is Callout && !exceptions.contains(el.feature) && el.feature > -1) {
//       removeCallout(el, false);
//     }
//   }
// }
//
// void clearAllToasts({List<int> exceptions = const []}) {
//   if (false) developer.log('clearAllToasts', name: 'om');
//   for (int i = _overlayItems.length; i > 0; i--) {
//     Object el = _overlayItems[i - 1];
//     if (el is ToastCallout && !exceptions.contains(el.feature) && el.feature > -1) {
//       removeToast(el, false);
//     }
//   }
// }
//
// void clearAll({List<int> exceptions = const []}) {
//   if (false) developer.log('clearAll', name: 'om');
//   for (int i = _overlayItems.length; i > 0; i--) {
//     Object el = _overlayItems[i - 1];
//     if (el is ToastCallout && !exceptions.contains(el.feature) && el.feature > -1) {
//       removeToast(el, false);
//     } else if (el is Callout && !exceptions.contains(el.feature) && el.feature > -1) {
//       removeCallout(el, false);
//     } else if (el is OverlayEntry && el.mounted) {
//       removeOverlayEntry(el);
//     }
//   }
// }

  refreshParentCallout(BuildContext ctx, VoidCallback f) {
    CalloutParent? calloutParent = ctx.findAncestorWidgetOfExactType<CalloutParent>();
    if (calloutParent != null) {
      calloutParent.callout.rebuildOverlays(f);
    }
  }

  hideParentCallout(BuildContext ctx) {
    Callout? callout = ctx.findAncestorWidgetOfExactType<CalloutParent>()?.callout;
    if (callout != null) hide(callout.feature);
  }

  unhideParentCallout(BuildContext ctx) {
    Callout? callout = ctx.findAncestorWidgetOfExactType<CalloutParent>()?.callout;
    if (callout != null) unhide(callout.feature);
  }

//------------------------------------------------------------------------------------------

  OverlayEntry? _cpiOverlay;
  Timer? _cpiTimer;

  void showCircularProgressIndicator(bool theBool, {required String reason}) {
    if (theBool) {
      remove(CAPI.CPI.feature(), true);
      _cpiOverlay = OverlayEntry(
        builder: (BuildContext overlayContext) {
          return Center(
            child: SizedBox(
              child: Useful.isAndroid
                  ? const CircularProgressIndicator(strokeWidth: 50.0, color: Colors.green)
                  : const CupertinoActivityIndicator(
                      radius: 50,
                    ),
              width: 100,
              height: 100,
            ),
          );
        },
        opaque: false,
      );
      overlayState.insert(_cpiOverlay!);
      CPIReasonStack.singleton().push(reason);
      // jic hide never called, set timeout at 10s
      if (_cpiTimer?.isActive ?? false) _cpiTimer?.cancel();
      _cpiTimer = Timer(const Duration(seconds: 10), () {
        if (CPIReasonStack.singleton().length > 0) {
          CPIReasonStack.singleton().pop();
          if (CPIReasonStack.singleton().length == 0 && _cpiOverlay != null) _cpiOverlay?.remove();
        }
      });
    } else {
      _cpiTimer?.cancel();
      if (CPIReasonStack.singleton().length > 0) {
        CPIReasonStack.singleton().pop();
        if (CPIReasonStack.singleton().length == 0 && _cpiOverlay != null) _cpiOverlay?.remove();
      }
    }
  }
}
