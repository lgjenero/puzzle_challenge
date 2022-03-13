import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';

/// {@template flame_puzzle_key_component}
/// The RPG key component.
/// {@endtemplate}
class LeverComponent extends FlamePuzzleAnimationComponent
    with HasHitboxes, Collidable {
  /// {@macro flame_puzzle_key_component}
  LeverComponent({
    required SpriteAnimation animation,
    Vector2? position,
    Vector2? size,
  }) : super(
          FlamePuzzleComponentType.actionable,
          animation: animation,
          position: position,
          size: size,
          playing: false,
        );

  /// creates Key component
  static Future<LeverComponent> create({
    Vector2? position,
    Vector2? size,
  }) async {
    final comp = LeverComponent(
      animation: SpriteAnimation.spriteList(
        [
          await Sprite.load(
            'tiles/Dungeon@64x64.png',
            srcPosition: Vector2(13 * 64, 12 * 64),
            srcSize: Vector2(64, 64),
          ),
          await Sprite.load(
            'tiles/Dungeon@64x64.png',
            srcPosition: Vector2(9 * 64, 15 * 64),
            srcSize: Vector2(64, 64),
          ),
        ],
        stepTime: 0.25,
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
