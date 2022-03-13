import 'package:flame/components.dart';

/// Flame Puzzle component types
enum FlamePuzzleComponentType {
  /// Player component
  player,

  /// Enemy component
  enemy,

  /// Component player can pickup
  pickup,

  /// Component player can operate
  actionable,

  /// Door component
  door,

  /// decoration component
  decoration,

  /// Dead player component
  death,

  /// Exit component
  exit
}

///  Flame Puzzle component mixin
mixin FlamePuzzleComponent on PositionComponent {
  /// Component type
  late final FlamePuzzleComponentType type;

  /// Do we add the component to the overlay
  late final bool isOverlay;

  /// Dispose the component
  void dispose() {
    removeFromParent();
  }
}
