import 'package:flutter/material.dart';

import 'package:hydrated_bloc/hydrated_bloc.dart';

class GotitsHelper {
  static List<int>? _features;

  static List<int> features({bool notUsingHydratedStorage = false}) {
    //print(_features.toString());

    if (_features == null) {
      if (notUsingHydratedStorage)
        _features = [];
      else {
        String? gotitList = HydratedBloc.storage.read('gotits');
        _features = gotitList?.substring(1, gotitList.length - 1).split(',').map(int.parse).toList() ?? [];
      }
    }
    // print("GotitsHelper.features");
    return _features!;
  }

  static void gotit(int theFeatureIndex, {bool notUsingHydratedStorage = false}) {
    if (!features(notUsingHydratedStorage:notUsingHydratedStorage).contains(theFeatureIndex)) {
      features(notUsingHydratedStorage:notUsingHydratedStorage).add(theFeatureIndex);
      HydratedBloc.storage.write('gotits', features(notUsingHydratedStorage:notUsingHydratedStorage).toString());
    }
    // print("GotitsHelper.gotit");
  }

  static bool alreadyGotit(int feature, {bool notUsingHydratedStorage = false}) {
    // print("GotitsHelper.alreadyGotit");
    return features(notUsingHydratedStorage:notUsingHydratedStorage).contains(feature);
  }

  static void clearGotits({bool notUsingHydratedStorage = false}) {
    if (!notUsingHydratedStorage) HydratedBloc.storage.delete('gotits');
    features(notUsingHydratedStorage:notUsingHydratedStorage).clear();
    // print("GotitsHelper.clearGotits");
  }

  static Widget gotitButton({required int feature, required double iconSize, bool notUsingHydratedStorage = false}) => IconButton(
        onPressed: () {
          gotit(feature, notUsingHydratedStorage:notUsingHydratedStorage);
        },
        icon: const Icon(Icons.thumb_up),
        iconSize: iconSize,
      );
}
