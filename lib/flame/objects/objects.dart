import 'dart:developer';

import 'package:bonfire/bonfire.dart';
import 'package:tiled/tiled.dart';
import 'package:very_good_slide_puzzle/flame/components/components.dart';
import 'package:very_good_slide_puzzle/flame/game.dart';

import 'actionable.dart';
import 'bandit.dart';
import 'decorations.dart';
import 'door.dart';
import 'enemy.dart';
import 'exit.dart';
import 'fire.dart';
import 'lever.dart';
import 'peasant.dart';
import 'pickup.dart';
import 'plant.dart';
import 'player.dart';
import 'slime.dart';
import 'wall.dart';
import 'wizard.dart';

export 'bandit.dart';
export 'decorations.dart';
export 'door.dart';
export 'enemy.dart';
export 'exit.dart';
export 'fire.dart';
export 'lever.dart';
export 'peasant.dart';
export 'pickup.dart';
export 'plant.dart';
export 'player.dart';
export 'slime.dart';
export 'wall.dart';
export 'wizard.dart';

/// Creates player component
Future<FlamePuzzleComponent?> createObject(
  FlamePuzzleGame game,
  TiledObject obj, {
  bool isOverlay = false,
}) async {
  FlamePuzzleComponentType? type;
  try {
    type = FlamePuzzleComponentType.values
        .firstWhere((e) => e.name == obj.name.toLowerCase());
  } catch (ex) {
    log('Object with type ${obj.name} not found');
  }

  if (type == null) return null;

  switch (type) {
    case FlamePuzzleComponentType.player:
      return createPlayer(game, obj, isOverlay: isOverlay);

    case FlamePuzzleComponentType.enemy:
      return createEnemy(game, obj, isOverlay: isOverlay);

    case FlamePuzzleComponentType.pickup:
      return createPickup(game, obj, isOverlay: isOverlay);

    case FlamePuzzleComponentType.actionable:
      return createActionable(game, obj, isOverlay: isOverlay);

    case FlamePuzzleComponentType.door:
      return createDoor(game, obj, isOverlay: isOverlay);

    case FlamePuzzleComponentType.decoration:
      return createDecoration(game, obj, isOverlay: isOverlay);

    case FlamePuzzleComponentType.death:
      return null;

    case FlamePuzzleComponentType.exit:
      final rect = game.getObjectRect(obj);
      return ExitComponent.create(
        position: rect.topLeft.toVector2(),
        size: rect.sizeVector2,
      );

    // ignore: no_default_cases
    default:
      return null;
  }
}
