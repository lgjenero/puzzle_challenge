import 'dart:developer';

import 'package:bonfire/util/extensions/extensions.dart';
import 'package:tiled/tiled.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:very_good_slide_puzzle/flame/objects/objects.dart';

/// Enemy type
enum EnemyType {
  /// Enemy type bandit
  bandit,

  /// Enemy type slime
  slime
}

/// Creates enemy component
Future<FlamePuzzleComponent?> createEnemy(
  FlamePuzzleGame game,
  TiledObject obj, {
  bool isOverlay = false,
}) async {
  EnemyType? type;
  try {
    type = EnemyType.values.firstWhere((e) => e.name == obj.type.toLowerCase());
  } catch (ex) {
    log('Enemy with type ${obj.type} not found');
  }

  if (type == null) return null;

  final rect = game.getObjectRect(obj);
  final position = rect.topLeft.toVector2();
  final size = rect.sizeVector2;

  switch (type) {
    case EnemyType.bandit:
      return BanditComponent.create(
        map: game.map,
        tiles: game.flamePuzzleTiles,
        position: position,
        size: size,
        isOverlay: isOverlay,
      );
    case EnemyType.slime:
      return createSlime(
        game,
        obj,
        isOverlay: isOverlay,
      );
  }
}
