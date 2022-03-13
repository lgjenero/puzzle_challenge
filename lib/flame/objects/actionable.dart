import 'dart:developer';

import 'package:bonfire/util/extensions/extensions.dart';
import 'package:tiled/tiled.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:very_good_slide_puzzle/flame/objects/objects.dart';

/// Actionable type
enum ActionableType {
  /// Enemy type bandit
  lever
}

/// Creates enemy component
Future<FlamePuzzleComponent?> createActionable(
  FlamePuzzleGame game,
  TiledObject obj, {
  bool isOverlay = false,
}) async {
  ActionableType? type;
  try {
    type = ActionableType.values
        .firstWhere((e) => e.name == obj.type.toLowerCase());
  } catch (ex) {
    log('Actionable with type ${obj.type} not found');
  }

  if (type == null) return null;

  final rect = game.getObjectRect(obj);
  final position = rect.topLeft.toVector2();
  final size = rect.sizeVector2;

  switch (type) {
    case ActionableType.lever:
      return LeverComponent.create(
        position: position,
        size: size,
      );
  }
}
