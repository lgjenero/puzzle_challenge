import 'dart:developer';

import 'package:bonfire/util/extensions/extensions.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:tiled/tiled.dart';
import 'package:very_good_slide_puzzle/flame/objects/objects.dart';

/// Decoration type
enum DecorationType {
  /// Decoration type plant
  plant,

  /// Decoration type fire
  fire
}

/// Creates decoration component
Future<FlamePuzzleComponent?> createDecoration(
  FlamePuzzleGame game,
  TiledObject obj, {
  bool isOverlay = false,
}) async {
  DecorationType? type;
  try {
    type = DecorationType.values
        .firstWhere((e) => e.name == obj.type.toLowerCase());
  } catch (ex) {
    log('Decoration with type ${obj.type} not found');
  }

  if (type == null) return null;

  final rect = game.getObjectRect(obj);
  final position = rect.topLeft.toVector2();
  final size = rect.sizeVector2;

  switch (type) {
    case DecorationType.fire:
      return FireComponent.create(position: position, size: size);
    case DecorationType.plant:
      return createPlant(game, obj, isOverlay: isOverlay);
  }
}
