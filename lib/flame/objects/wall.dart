import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';

/// {@template flame_puzzle_wall}
/// The RPG game wall.
/// {@endtemplate}
class Wall extends PositionComponent with HasHitboxes, Collidable {
  /// {@macro flame_puzzle_wall}
  Wall({
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super(
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );

  @override
  Future<void>? onLoad() {
    addHitbox(HitboxRectangle());
    collidableType = CollidableType.passive;
    return super.onLoad();
  }
}
