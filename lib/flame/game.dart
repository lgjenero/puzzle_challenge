import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bonfire/bonfire.dart';
import 'package:collection/collection.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiled/tiled.dart';
import 'package:very_good_slide_puzzle/audio_control/audio_control.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:very_good_slide_puzzle/flame/lifecycle/lifecycle.dart';
import 'package:very_good_slide_puzzle/flame/objects/objects.dart';
import 'package:very_good_slide_puzzle/models/models.dart' as puzzle;
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';
import 'package:very_good_slide_puzzle/theme/bloc/theme_bloc.dart';

/// {@template flame_puzzle_game_board}
/// The Flame Puzzle game board.
/// {@endtemplate}
class FlamePuzzleGameBoard extends StatefulWidget {
  /// {@macro flame_puzzle_game_board}
  const FlamePuzzleGameBoard({
    required this.tiles,
    required this.spacing,
    required this.gameBuilder,
    Key? key,
  }) : super(key: key);

  /// The tiles to be displayed on the board.
  final List<puzzle.Tile> tiles;

  /// The spacing between each tile from [tiles].
  final double spacing;

  /// The game builder
  final FlamePuzzleGame Function(
    List<puzzle.Tile> tiles,
    double spacing,
    BuildContext context,
  ) gameBuilder;

  @override
  State<FlamePuzzleGameBoard> createState() => _FlamePuzzleGameBoardState();
}

class _FlamePuzzleGameBoardState extends State<FlamePuzzleGameBoard>
    with WidgetsBindingObserver, LifecycleObserver {
  final FocusNode _focusNode = FocusNode();

  late final FlamePuzzleGame _game;

  final GlobalKey _gameKey = GlobalKey();

  AudioPlayer? _audioPlayer;

  @override
  void initState() {
    super.initState();
    _game = widget.gameBuilder(widget.tiles, widget.spacing, context);
    registerLifecycleObserver(this);

    FlameAudio.loopLongAudio('background.mp3', volume: 0.05)
        .then((value) => _audioPlayer = value);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    unregisterLifecycleObserver(this);
    _audioPlayer
      ?..stop()
      ..dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FlamePuzzleGameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _game.updateSetup(widget.tiles, widget.spacing);
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, _focusNode.requestFocus);
    return MultiBlocListener(
      listeners: [
        BlocListener<PuzzleBloc, PuzzleState>(
          listener: (context, state) {
            _game.joystick(state.joystick.toVector2());
            if (state.puzzleStatus == PuzzleStatus.complete) {
              _game.puzzleComplete();
            } else if (state.puzzleStatus == PuzzleStatus.incomplete) {
              _game.reset();
            }
          },
        ),
        BlocListener<AudioControlBloc, AudioControlState>(
          listener: (context, state) {
            if (state.muted) {
              _audioPlayer?.pause();
            } else {
              _audioPlayer?.resume();
            }
            _game.enableSound(enable: !state.muted);
          },
        ),
      ],
      child: GameWidget(
        key: _gameKey,
        game: _game,
        focusNode: _focusNode,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_game.isPrepared) {
      switch (state) {
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
        case AppLifecycleState.detached:
          _game.paused = true;
          break;
        case AppLifecycleState.resumed:
          _game.paused = false;
          break;
      }
    }
  }

  void setupAudio(AudioPlayer audioPlayer) {
    _audioPlayer = audioPlayer;

    final muted = context.read<AudioControlBloc>().state.muted;
    if (!muted) {
      audioPlayer.resume();
    } else {
      audioPlayer.pause();
    }
    _game.enableSound(enable: !muted);
  }
}

/// {@template flame_puzzle_game}
/// The Flame Puzzle game.
/// {@endtemplate}
mixin FlamePuzzleGame on FlameGame {
  /// The tiles to be displayed on the board.
  late List<puzzle.Tile> tiles;

  /// The spacing between each tile from [tiles].
  late double spacing;

  /// Build context that is building the game UI
  late final BuildContext context;

  /// Flame puzzle game tile map
  late final FlamePuzzleGameTiledComponent map;

  /// Flame puzzle game tiles
  final Map<puzzle.Position, FlamePuzzleTile> flamePuzzleTiles = {};

  /// Flame puzzle game objects
  final List<FlamePuzzleComponent> objects = [];

  /// Flame puzzle game transition animation duration
  late final double transitionAnimation;

  /// Flame puzzle game offset
  late final Vector2 offset;

  /// Flame puzzle game audio muted
  bool muted = false;

  /// Player component
  FlamePuzzleComponent? get player => objects
      .firstWhereOrNull((e) => e.type == FlamePuzzleComponentType.player);

  /// Updates the board setup
  void updateSetup(List<puzzle.Tile> tiles, double spacing);

  /// Load Tiles from the tile map
  Future<void> addTilesInMap(FlamePuzzleGameTiledComponent tiledMap) async {
    // tiles
    for (final batch in tiledMap.flamePuzzleTileMap.puzzleBatches.values) {
      var tile = flamePuzzleTiles[batch.tile.correctPosition];
      if (tile == null) {
        tile = FlamePuzzleTile(
          tiledMap.flamePuzzleTileMap,
          [],
          {},
          {},
          batch.tile,
          batch.tile,
          spacing,
          offset,
          transitionAnimation,
          context.read<ThemeBloc>().state.theme.tileOutlineColor,
          context.read<ThemeBloc>().state.theme.backgroundColor,
        );
        await add(tile);
      }

      final background = [0, 1];
      for (final layerIndex in background) {
        final spriteBatch = batch.batches[layerIndex];
        if (spriteBatch != null) {
          await tile.add(SpriteBatchComponent(spriteBatch: spriteBatch));
        }
      }

      final overlay = [2, 3];
      for (final layerIndex in overlay) {
        final spriteBatch = batch.batches[layerIndex];
        if (spriteBatch != null) {
          tile.overlay.add(SpriteBatchComponent(spriteBatch: spriteBatch));
        }
      }

      flamePuzzleTiles[batch.tile.correctPosition] = tile;
    }
  }

  /// Load decorations from the tile map
  Future<void> addDecorationsInMap(
    FlamePuzzleGameTiledComponent tiledMap,
  ) async {
    // add decorations
    final layers = ['Decorations', 'OverlayDecorations'];
    var first = true;
    for (final layer in layers) {
      final objGroup = tiledMap.tileMap.getObjectGroupFromLayer(layer);
      for (final obj in objGroup.objects) {
        final comp = await createObject(this, obj, isOverlay: !first);
        if (comp == null) continue;

        if (comp is! FlamePuzzleMovingComponent) {
          final rect = getObjectRect(obj);
          final tile = tiledMap.flamePuzzleTileMap
              .getTile(rect.center.dx, rect.center.dy);
          final flamePuzzleTile = flamePuzzleTiles[tile.correctPosition];
          if (flamePuzzleTile == null) continue;

          final inTilePosition = tiledMap.flamePuzzleTileMap
              .getInTilePosition(rect.left, rect.top);
          final tilePosition = inTilePosition.toVector2();
          if (first) {
            flamePuzzleTile.components[comp] = tilePosition;
          } else {
            flamePuzzleTile.overlayComponents[comp] = tilePosition;
          }
        }

        objects.add(comp);
      }
      first = false;
    }
  }

  /// Load boundaries from the tile map
  Future<void> addBoundariesInMap(
    FlamePuzzleGameTiledComponent tiledMap,
  ) async {
    // add boundaries
    final collisionGroup = tiledMap.tileMap.getObjectGroupFromLayer('Collider');
    for (final obj in collisionGroup.objects) {
      final rect = getObjectRect(obj);
      await add(
        Wall(position: rect.topLeft.toVector2(), size: rect.sizeVector2),
      );
    }
  }

  /// Load objects from the tile map
  Future<void> addObjectsInMap(
    FlamePuzzleGameTiledComponent tiledMap,
  ) async {
    // add objects
    final objGroup = tiledMap.tileMap.getObjectGroupFromLayer('Objects');
    for (final obj in objGroup.objects) {
      final comp = await createObject(this, obj);
      if (comp == null) continue;

      if (comp is Collidable && this is HasCollidables) {
        (this as HasCollidables).collidables.add(comp as Collidable);
      }

      if (comp is! FlamePuzzleMovingComponent) {
        final rect = getObjectRect(obj);
        final tile =
            tiledMap.flamePuzzleTileMap.getTile(rect.center.dx, rect.center.dy);
        final flamePuzzleTile = flamePuzzleTiles[tile.correctPosition];
        if (flamePuzzleTile == null) continue;

        final inTilePosition =
            tiledMap.flamePuzzleTileMap.getInTilePosition(rect.left, rect.top);
        final tilePosition = inTilePosition.toVector2();
        final overlay = obj.properties
                .firstWhereOrNull((e) => e.name == 'overlay')
                ?.value ==
            'true';
        if (overlay) {
          flamePuzzleTile.overlayComponents[comp] = tilePosition;
        } else {
          flamePuzzleTile.components[comp] = tilePosition;
        }
      }

      objects.add(comp);
    }
  }

  /// Get Tiled object rect in the map
  Rect getObjectRect(TiledObject obj, {bool centered = false}) {
    if (centered) {
      return Rect.fromCenter(
        center: Offset(
          obj.x * map.flamePuzzleTileMap.tileScale,
          obj.y * map.flamePuzzleTileMap.tileScale,
        ),
        width: obj.width * map.flamePuzzleTileMap.tileScale,
        height: obj.height * map.flamePuzzleTileMap.tileScale,
      );
    }
    return Rect.fromLTWH(
      obj.x * map.flamePuzzleTileMap.tileScale,
      obj.y * map.flamePuzzleTileMap.tileScale,
      obj.width * map.flamePuzzleTileMap.tileScale,
      obj.height * map.flamePuzzleTileMap.tileScale,
    );
  }

  /// Player killed
  void killed() {}

  /// Player finished
  void finished() {}

  /// Player triggered actionable
  void triggerAction(FlamePuzzleComponent component) {}

  /// Player opened door
  void openDoor(FlamePuzzleComponent component) {}

  /// Joystick update
  void joystick(Vector2 joystick) {}

  /// Puzzle complete
  void puzzleComplete() {}

  /// Reset the game
  void reset() {}

  /// Enable/disable sound
  void enableSound({required bool enable}) => muted = !enable;
}
