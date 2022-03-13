import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:very_good_slide_puzzle/flame/objects/objects.dart';
import 'package:very_good_slide_puzzle/models/models.dart' as game;
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';

/// {@template platform_game}
/// The Flame puzzle platform game.
/// {@endtemplate}
class PlatformGame extends FlameGame
    with FlamePuzzleGame, TapDetector, KeyboardEvents, HasCollidables {
  ///{@macro platform_game}
  PlatformGame(List<game.Tile> tiles, double spacing, BuildContext context)
      : super() {
    this.tiles = tiles;
    this.spacing = spacing;
    this.context = context;
    offset = Vector2.all(14);
    transitionAnimation = 2.0;
  }

  @override
  void updateSetup(List<game.Tile> tiles, double spacing) {
    var forceUpdate = false;
    if (this.spacing != spacing) {
      this.spacing = spacing;
      forceUpdate = true;
    }
    for (final tile in tiles) {
      final flamePuzzleTile = flamePuzzleTiles[tile.correctPosition]!;
      if (forceUpdate ||
          flamePuzzleTile.tile.currentPosition != tile.currentPosition) {
        flamePuzzleTile.updateSetup(tile, flamePuzzleTile.tile, this.spacing);
      }
    }
    this.tiles = tiles;
  }

  WizardComponent? get _wizardPlayer => player as WizardComponent?;

  bool _finished = false;

  bool _puzzleCompleted = false;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewport = FixedResolutionViewport(
      Vector2(
        192 + offset.x * 2,
        192 + offset.y * 2,
      ),
    );

    map = await FlamePuzzleGameTiledComponent.load(
      tiles,
      'moss.tmx',
      Vector2(16, 16),
    );

    await addTilesInMap(map);
    await addDecorationsInMap(map);
    await addBoundariesInMap(map);
    await addBoundariesInMap(map);
    await addObjectsInMap(map);
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (_puzzleCompleted) return;

    final touchPoint = info.eventPosition.viewport;
    final x =
        (touchPoint.x / map.flamePuzzleTileMap.puzzleTileWidth).floor() + 1;
    final y =
        (touchPoint.y / map.flamePuzzleTileMap.puzzleTileWidth).floor() + 1;

    final tile = tiles.firstWhere(
      (tile) => tile.currentPosition == game.Position(x: x, y: y),
    );

    context.read<PuzzleBloc>().add(TileTapped(tile));
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (_finished) return KeyEventResult.handled;

    var moveX = 0.0;
    var moveY = 0.0;

    if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) ||
        event.isKeyPressed(LogicalKeyboardKey.keyW)) {
      moveY += 1;
    }
    if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) ||
        event.isKeyPressed(LogicalKeyboardKey.keyA)) {
      moveX -= 1;
    }
    if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) ||
        event.isKeyPressed(LogicalKeyboardKey.keyD)) {
      moveX += 1;
    }

    final player = _wizardPlayer;
    if (player == null) return KeyEventResult.handled;

    player.movement = Vector2(moveX, moveY);

    assert(
      this is! HasKeyboardHandlerComponents,
      'A keyboard event was registered by KeyboardEvents for a game also '
      'mixed with HasKeyboardHandlerComponents. Do not mix with both, '
      'HasKeyboardHandlerComponents removes the necessity of KeyboardEvents',
    );

    return KeyEventResult.handled;
  }

  // @override
  // void onGameResize(Vector2 canvasSize) {
  //   super.onGameResize(canvasSize);
  // }

  @override
  void update(double dt) {
    super.update(dt);

    for (final comp in objects) {
      comp.update(dt);
    }
  }

  @override
  void joystick(Vector2 joystick) {
    if (_finished) return;

    _wizardPlayer?.movement = Vector2(joystick.x, -joystick.y);
  }

  @override
  void puzzleComplete() {
    if (_puzzleCompleted) return;
    _puzzleCompleted = true;
    Future.delayed(Duration(milliseconds: (transitionAnimation * 1000).ceil()),
        () {
      for (final tile in flamePuzzleTiles.values) {
        tile.setCompleted();
      }
    });
  }

  @override
  void reset() {
    if (!_puzzleCompleted) return;
    _puzzleCompleted = false;
  }
}
