import 'dart:developer';

import 'package:bonfire/util/extensions/extensions.dart';
import 'package:tiled/tiled.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:very_good_slide_puzzle/flame/objects/objects.dart';

/// Pickup type
enum PickupType {
  /// Pickup type key
  key,

  /// Pickup type flask
  flask,
}

/// Creates enemy component
Future<FlamePuzzleComponent?> createPickup(
  FlamePuzzleGame game,
  TiledObject obj, {
  bool isOverlay = false,
}) async {
  PickupType? type;
  try {
    type =
        PickupType.values.firstWhere((e) => e.name == obj.type.toLowerCase());
  } catch (ex) {
    log('Pickup with type ${obj.type} not found');
  }

  if (type == null) return null;

  switch (type) {
    case PickupType.key:
      return null;

    case PickupType.flask:
      return null;
  }
}
