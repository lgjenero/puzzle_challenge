import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';

/// {@template flame_puzzle_exit_component}
/// The Flame Puzzle exit component.
/// {@endtemplate}
class ExitComponent extends PositionComponent
    with FlamePuzzleComponent, HasHitboxes, Collidable {
  /// {@macro flame_puzzle_exit_component}
  ExitComponent({
    Vector2? position,
    Vector2? size,
  }) : super(
          position: position,
          size: size,
        ) {
    type = FlamePuzzleComponentType.exit;
  }

  /// creates Key component
  static Future<ExitComponent> create({
    Vector2? position,
    Vector2? size,
  }) async {
    final comp = ExitComponent(
      position: position,
      size: size,
    );
    await comp.onLoad();
    return comp;
  }

  @override
  Future<void>? onLoad() {
    addHitbox(HitboxRectangle());
    collidableType = CollidableType.passive;
    return super.onLoad();
  }
}
