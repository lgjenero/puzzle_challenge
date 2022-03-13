import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:tiled/tiled.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:very_good_slide_puzzle/models/models.dart' as game;

/// {@macro flame_puzzle_renderable_tiled_map}
class FlamePuzzleGameRenderableTiledMap extends RenderableTiledMap {
  /// {@macro flame_puzzle_renderable_tiled_map}
  FlamePuzzleGameRenderableTiledMap(
    this._tiles,
    TiledMap map,
    List<Map<String, SpriteBatch>> batchesByLayer,
    Vector2 destTileSize,
  ) : super(
          map,
          batchesByLayer,
          destTileSize,
        ) {
    // get the puzzle dimensions
    _calculatePuzzleDimensions(_tiles);

    // split the tile map into puzzle tile batches
    final layerNum = batchesByLayer.length;
    for (var i = 0; i < layerNum; i++) {
      final batchMap = batchesByLayer[i];

      for (final batch in batchMap.values) {
        _addBatch(batch, i);
      }
    }
  }

  void _addBatch(SpriteBatch batch, int layerIndex) {
    for (var i = 0; i < batch.sources.length; i++) {
      final source = batch.sources[i];
      final transform = batch.transforms[i];

      // get the sprite tile position
      final tile = getTile(transform.tx, transform.ty);

      // get the position of sprite inside puzzle tile
      final inTilePosition = getInTilePosition(transform.tx, transform.ty);

      // get or create tile
      final rpgBatch = _batches[tile.correctPosition] ??
          (_batches[tile.correctPosition] = FlamePuzzleSpriteBatch(tile));

      // get or create tile SpriteBatch and update
      (rpgBatch.batches[layerIndex] ??= SpriteBatch(batch.atlas)).addTransform(
        source: source,
        transform: RSTransform(
          transform.scos,
          0,
          inTilePosition.dx,
          inTilePosition.dy,
        ),
      );
    }
  }

  /// The tiles to be displayed on the board.
  final List<game.Tile> _tiles;

  /// The puzzle width
  int get puzzleWidth => _puzzleWidth;
  late int _puzzleWidth;

  /// The puzzle height
  int get puzzleHeight => _puzzleHeight;
  late int _puzzleHeight;

  /// The puzzle tile width
  double get puzzleTileWidth => _puzzleTileWidth;
  late double _puzzleTileWidth;

  /// The puzzle tile height
  double get puzzleTileHeight => _puzzleTileHeight;
  late double _puzzleTileHeight;

  /// The puzzle tile width in tile map tiles
  int get puzzleTileWidthInTiles => _puzzleTileWidthInTiles;
  late int _puzzleTileWidthInTiles;

  /// The puzzle tile height in tile map tiles
  int get puzzleTileHeightInTiles => _puzzleTileHeightInTiles;
  late int _puzzleTileHeightInTiles;

  /// The puzzle tile subtile width in tile map tiles
  int get puzzleTileSubtileWidth => _puzzleTileSubtileWidth;
  late int _puzzleTileSubtileWidth;

  /// The puzzle tile subtile height in tile map tiles
  int get puzzleTileSubtileHeight => _puzzleTileSubtileHeight;
  late int _puzzleTileSubtileHeight;

  /// The tile scale
  double get tileScale => _tileScale;
  late double _tileScale;

  /// Puzzle tile batches corrsponding to [_tiles]
  Map<game.Position, FlamePuzzleSpriteBatch> get puzzleBatches => {..._batches};
  final Map<game.Position, FlamePuzzleSpriteBatch> _batches = {};

  /// Get the Puzzle tile position corresponding to the given position
  game.Position getTilePosition(double x, double y) => game.Position(
        x: (x / _puzzleTileWidth).floor() + 1,
        y: (y / _puzzleTileHeight).floor() + 1,
      );

  /// Get the Puzzle tile corresponding to the given position
  game.Tile getTile(double x, double y) =>
      _tiles.firstWhere((e) => e.correctPosition == getTilePosition(x, y));

  /// Get the relative position inside the Puzzle tile
  // Offset getInTilePosition(double x, double y) => Offset(
  //       (((x / map.tileWidth).floor() % _puzzleTileWidthInTiles) *
  //               map.tileWidth)
  //           .toDouble(),
  //       (((y / map.tileHeight).floor() % _puzzleTileHeightInTiles) *
  //               map.tileHeight)
  //           .toDouble(),
  //     );

  Offset getInTilePosition(double x, double y) =>
      Offset(x % _puzzleTileWidth, y % _puzzleTileHeight);

  /// Parses a file returning a [RenderableTiledMap].
  ///
  /// NOTE: this method looks for files under the path "assets/tiles/".
  static Future<FlamePuzzleGameRenderableTiledMap> fromFile(
    List<game.Tile> tiles,
    String fileName,
    Vector2 destTileSize,
  ) async {
    final map = await RenderableTiledMap.fromFile(fileName, destTileSize);

    return FlamePuzzleGameRenderableTiledMap(
      tiles,
      map.map,
      map.batchesByLayer,
      map.destTileSize,
    );
  }

  void _calculatePuzzleDimensions(List<game.Tile> tiles) {
    var maxWidth = 0;
    var maxHeight = 0;
    for (final tile in tiles) {
      if (maxWidth < tile.correctPosition.x) {
        maxWidth = tile.correctPosition.x;
      }
      if (maxHeight < tile.correctPosition.y) {
        maxHeight = tile.correctPosition.y;
      }
    }

    _tileScale = destTileSize.x / map.tileWidth;

    _puzzleWidth = maxWidth;
    _puzzleHeight = maxHeight;

    _puzzleTileWidthInTiles = map.width ~/ _puzzleWidth;
    _puzzleTileHeightInTiles = map.height ~/ _puzzleHeight;

    _puzzleTileWidth = _puzzleTileWidthInTiles * destTileSize.x;
    _puzzleTileHeight = _puzzleTileHeightInTiles * destTileSize.y;

    _puzzleTileSubtileWidth = destTileSize.x.toInt();
    _puzzleTileSubtileHeight = destTileSize.y.toInt();
  }
}

/// {@template flame_puzzle_sprite_batch}
/// The RPG puzzle game sprite batch.
/// {@endtemplate}
class FlamePuzzleSpriteBatch {
  /// {@macro flame_puzzle_sprite_batch}
  FlamePuzzleSpriteBatch(
    this.tile,
  );

  /// Tile SpriteBatch
  final Map<int, SpriteBatch> batches = {};

  /// Tile background SpriteBatch
  SpriteBatch? backgroundBatch;

  /// Tile
  final game.Tile tile;
}
