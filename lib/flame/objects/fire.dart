import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:flame/components.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';

/// {@template flame_puzzle_fire_component}
/// The Flame Puzzle fire component.
/// {@endtemplate}
class FireComponent extends FlamePuzzleAnimationComponent {
  /// {@macro flame_puzzle_key_component}
  FireComponent({
    required SpriteAnimation animation,
    Vector2? position,
    Vector2? size,
  }) : super(
          FlamePuzzleComponentType.decoration,
          animation: animation,
          position: position,
          size: size,
        );

  /// creates Key component
  static Future<FireComponent> create({
    Vector2? position,
    Vector2? size,
  }) async {
    final comp = FireComponent(
      animation: await SpriteAnimation.load(
        'sprites/fire/fire.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.2,
          textureSize: Vector2(64, 64),
          amountPerRow: 4,
        ),
      ),

      // animation: SpriteAnimation.spriteList(
      //   [
      //     await Sprite.load(
      //       'tiles/Dungeon@64x64.png',
      //       srcPosition: Vector2(13 * 64, 12 * 64),
      //       srcSize: Vector2(64, 64),
      //     ),
      //     await Sprite.load(
      //       'tiles/Dungeon@64x64.png',
      //       srcPosition: Vector2(9 * 64, 15 * 64),
      //       srcSize: Vector2(64, 64),
      //     ),
      //   ],
      //   stepTime: 0.25,
      //   loop: false,
      // ),
      position: position,
      size: size,
    );
    await comp.onLoad();
    return comp;
  }
}
