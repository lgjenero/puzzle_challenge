import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';

/// {@template flame_puzzle_direction_animation_component}
/// The Flame puzzle direction animation component.
/// {@endtemplate}
class FlamePuzzleDirectionAnimationComponent extends PositionComponent
    with FlamePuzzleComponent {
  /// {@macro flame_puzzle_direction_animation_component}
  FlamePuzzleDirectionAnimationComponent(
    FlamePuzzleComponentType type, {
    required this.animation,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
    bool isOverlay = false,
  }) : super(
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

  /// Directional sprite animation
  final SimpleDirectionAnimation animation;

  @override
  void render(Canvas canvas) {
    animation.render(canvas);
  }

  /// Play a specific direction animation
  void play(SimpleAnimationEnum animation) => this.animation.play(animation);

  /// Current animation state
  SimpleAnimationEnum? get playingAnimation => animation.currentType;
}
