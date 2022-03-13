import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';

/// {@template flame_puzzle_animation_component}
/// The Flame Puzzle animation component.
/// {@endtemplate}
class FlamePuzzleAnimationComponent extends SpriteAnimationComponent
    with FlamePuzzleComponent {
  /// {@macro flame_puzzle_animation_component}
  FlamePuzzleAnimationComponent(
    FlamePuzzleComponentType type, {
    required SpriteAnimation animation,
    bool? removeOnFinish,
    bool? playing,
    Paint? paint,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
    bool isOverlay = false,
  }) : super(
          animation: animation,
          removeOnFinish: removeOnFinish,
          playing: playing,
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
