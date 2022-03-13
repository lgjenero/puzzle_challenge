import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:very_good_slide_puzzle/models/models.dart' as game;

/// {@template flame_puzzle_tiled_component}
/// The RPG game [TiledComponent].
/// {@endtemplate}
class FlamePuzzleGameTiledComponent extends TiledComponent {
  /// {@macro flame_puzzle_tiled_component}
  FlamePuzzleGameTiledComponent(
    FlamePuzzleGameRenderableTiledMap tileMap, {
    int? priority,
  }) : super(tileMap, priority: priority);

  /// RPG game [RenderableTiledMap]
  FlamePuzzleGameRenderableTiledMap get flamePuzzleTileMap =>
      tileMap as FlamePuzzleGameRenderableTiledMap;

  /// Loads a [TiledComponent] from a file.
  static Future<FlamePuzzleGameTiledComponent> load(
    List<game.Tile> tiles,
    String fileName,
    Vector2 destTileSize, {
    int? priority,
  }) async {
    return FlamePuzzleGameTiledComponent(
      await FlamePuzzleGameRenderableTiledMap.fromFile(
        tiles,
        fileName,
        destTileSize,
      ),
      priority: priority,
    );
  }
}
