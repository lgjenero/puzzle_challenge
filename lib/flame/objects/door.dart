import 'dart:async';
import 'dart:developer';

import 'package:bonfire/bonfire.dart';
import 'package:flame/geometry.dart';
import 'package:tiled/tiled.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';

/// Door oreintation
enum DoorOrientation {
  /// Door oriented up
  up,

  /// Door oriented up
  down,

  /// Door oriented left
  left,

  /// Door oriented right
  right
}

extension _DoorOrientationUtils on DoorOrientation {
  Vector2 get _spriteSize {
    switch (this) {
      case DoorOrientation.up:
      case DoorOrientation.down:
        return Vector2(3 * 32, 32);
      case DoorOrientation.left:
      case DoorOrientation.right:
        return Vector2(32, 3 * 32);
    }
  }

  Vector2 get _spriteLocation {
    switch (this) {
      case DoorOrientation.up:
        return Vector2(0, 12 * 32);
      case DoorOrientation.down:
        return Vector2(0, 12 * 32);
      case DoorOrientation.left:
        return Vector2(3 * 32, 11 * 32);
      case DoorOrientation.right:
        return Vector2(4 * 32, 11 * 32);
    }
  }
}

/// {@template flame_puzzle_door_component}
/// The Flame Puzzle door component.
/// {@endtemplate}
class DoorComponent extends FlamePuzzleAnimationComponent
    with HasHitboxes, Collidable {
  /// {@macro flame_puzzle_door_component}
  DoorComponent({
    required SpriteAnimation animation,
    required Vector2 position,
    required Vector2 size,
  }) : super(
          FlamePuzzleComponentType.door,
          animation: animation,
          position: position,
          size: size,
          playing: false,
        );

  /// creates Door component
  static Future<DoorComponent> create({
    required Vector2 position,
    required Vector2 size,
    required DoorOrientation orientation,
  }) async {
    final comp = DoorComponent(
      animation: SpriteAnimation.spriteList(
        [
          await Sprite.load(
            'tiles/Dungeon.png',
            srcPosition: orientation._spriteLocation,
            srcSize: orientation._spriteSize,
          ),
        ],
        stepTime: 1,
        loop: false,
      ),
      position: position,
      size: size,
    );
    await comp.onLoad();
    return comp;
  }

  @override
  Future<void>? onLoad() {
    addHitbox(HitboxCircle());
    collidableType = CollidableType.passive;
    return super.onLoad();
  }
}

/// Creates decoration component
Future<FlamePuzzleComponent?> createDoor(
  FlamePuzzleGame game,
  TiledObject obj, {
  bool isOverlay = false,
}) async {
  DoorOrientation? orientation;

  try {
    orientation = DoorOrientation.values.firstWhere((e) => e.name == obj.type);
  } catch (ex) {
    log('Door with orientation ${obj.type} not found');
  }

  if (orientation == null) return null;

  final rect = game.getObjectRect(obj);
  final position = rect.topLeft.toVector2();
  final size = rect.sizeVector2;

  return DoorComponent.create(
    position: position,
    size: size,
    orientation: orientation,
  );
}
