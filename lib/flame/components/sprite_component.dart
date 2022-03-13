import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';

/// {@template flame_puzzle_sprite_component}
/// The Flame puzzle sprite component.
/// {@endtemplate}
class FlamePuzzleSpriteComponent extends SpriteComponent
    with FlamePuzzleComponent {
  /// {@macro flame_puzzle_sprite_component}
  FlamePuzzleSpriteComponent(
    FlamePuzzleComponentType type, {
    required Sprite sprite,
    Paint? paint,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
    bool isOverlay = false,
  }) : super(
          sprite: sprite,
          paint: paint,
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        ) {
    this.type = type;
    this.isOverlay = isOverlay;
  }
}
