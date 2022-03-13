import 'dart:developer';

import 'package:bonfire/util/extensions/extensions.dart';
import 'package:tiled/tiled.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:very_good_slide_puzzle/flame/objects/objects.dart';

/// Player type
enum PlayerType {
  /// Player type peasant
  peasant,

  /// Player type wizard
  wizard
}

/// Creates player component
Future<FlamePuzzleComponent?> createPlayer(
  FlamePuzzleGame game,
  TiledObject obj, {
  bool isOverlay = false,
}) async {
  PlayerType? type;
  try {
    type =
        PlayerType.values.firstWhere((e) => e.name == obj.type.toLowerCase());
  } catch (ex) {
    log('Player with type ${obj.type} not found');
  }

  if (type == null) return null;

  final rect = game.getObjectRect(obj);
  final position = rect.topLeft.toVector2();
  final size = rect.sizeVector2;

  switch (type) {
    case PlayerType.peasant:
      return PeasantComponent.create(
        game: game,
        map: game.map,
        tiles: game.flamePuzzleTiles,
        position: position,
        size: size,
        isOverlay: isOverlay,
      );
    case PlayerType.wizard:
      return WizardComponent.create(
        game: game,
        map: game.map,
        tiles: game.flamePuzzleTiles,
        position: position,
        size: size,
        isOverlay: isOverlay,
      );
  }
}
