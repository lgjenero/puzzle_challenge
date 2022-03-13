import 'package:flame/extensions.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:very_good_slide_puzzle/models/models.dart';

/// Flame Puzzle component mixin for components that move
/// from tile to tile
mixin FlamePuzzleMovingComponent on FlamePuzzleComponent {
  /// Game map
  late final FlamePuzzleGameTiledComponent map;

  /// Game tiles
  late final Map<Position, FlamePuzzleTile> tiles;

  /// Current tiles
  Set<FlamePuzzleTile> currentTiles = {};

  Vector2? _lastTopLeft;

  /// Update component position and tile
  void updateTileAndPosition() {
    var rect = toRect();
    if (rect.top < 0) {
      rect = Rect.fromCenter(
        center: Offset(rect.center.dx, -rect.center.dy),
        width: rect.width,
        height: rect.height,
      );
    }

    final topLeft = rect.topLeft.toVector2();
    if (_lastTopLeft == topLeft) return;
    _lastTopLeft = topLeft;

    final points = [
      topLeft,
      rect.topRight.toVector2(),
      rect.bottomLeft.toVector2(),
      rect.bottomRight.toVector2(),
    ];

    final tiles = <Tile>{};
    final flamePuzzleTiles = <FlamePuzzleTile>{};
    for (final point in points) {
      // get tile
      final tile = map.flamePuzzleTileMap.getTile(point.x, point.y);

      // if it is the same tile exit
      if (tiles.contains(tile)) continue;

      // get position in tile
      final inTilePosition = Vector2(
        topLeft.x -
            (tile.correctPosition.x - 1) *
                map.flamePuzzleTileMap.puzzleTileWidth,
        topLeft.y -
            (tile.correctPosition.y - 1) *
                map.flamePuzzleTileMap.puzzleTileWidth,
      );

      // get Flame puzzle tile
      final flamePuzzleTile = this.tiles[tile.correctPosition];
      if (flamePuzzleTile == null) continue;

      // set tile position
      flamePuzzleTiles.add(flamePuzzleTile);
      if (isOverlay) {
        flamePuzzleTile.overlayComponents[this] = inTilePosition;
      } else {
        flamePuzzleTile.components[this] = inTilePosition;
      }
    }

    for (final flamePuzzleTile in currentTiles) {
      if (!flamePuzzleTiles.contains(flamePuzzleTile)) {
        if (isOverlay) {
          flamePuzzleTile.components.remove(this);
        } else {
          flamePuzzleTile.overlayComponents.remove(this);
        }
      }
    }
    currentTiles
      ..clear()
      ..addAll(flamePuzzleTiles);
  }

  @override
  void dispose() {
    for (final flamePuzzleTile in currentTiles) {
      if (isOverlay) {
        flamePuzzleTile.components.remove(this);
      } else {
        flamePuzzleTile.overlayComponents.remove(this);
      }
    }
    currentTiles.clear();
    super.dispose();
  }
}
