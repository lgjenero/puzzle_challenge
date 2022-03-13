import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:very_good_slide_puzzle/flame/objects/objects.dart';
import 'package:very_good_slide_puzzle/models/models.dart' as game;
import 'package:very_good_slide_puzzle/models/position.dart';
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';

/// {@template dungeon_game}
/// The Flame Puzzle dungeon game.
/// {@endtemplate}
class HouseGame extends FlameGame
    with FlamePuzzleGame, TapDetector, KeyboardEvents, HasCollidables {
  ///{@macro dungeon_game}
  HouseGame(List<game.Tile> tiles, double spacing, BuildContext context)
      : super() {
    this.tiles = tiles;
    this.spacing = spacing;
    this.context = context;
    offset = Vector2.all(32);
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

  PeasantComponent? get _paesantPlayer => player as PeasantComponent?;

  bool _finished = false;

  bool _puzzleCompleted = false;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    camera.viewport = FixedResolutionViewport(
      Vector2(
        448 + 2 * offset.x,
        448 + 2 * offset.y,
      ),
    );

    map = await FlamePuzzleGameTiledComponent.load(
      tiles,
      'house.tmx',
      Vector2(16, 16),
    );

    await addTilesInMap(map);
    await addDecorationsInMap(map);
    await addBoundariesInMap(map);
    await addObjectsInMap(map);
    await super.onLoad();
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (_puzzleCompleted) return;

    final touchPoint = info.eventPosition.viewport;
    final tileWidth = camera.viewport.effectiveSize.x / 4;
    final tileHeight = camera.viewport.effectiveSize.y / 4;
    final x = (touchPoint.x / tileWidth).floor() + 1;
    final y = (touchPoint.y / tileHeight).floor() + 1;

    final tile = tiles
        .firstWhere((tile) => tile.currentPosition == Position(x: x, y: y));

    context.read<PuzzleBloc>().add(TileTapped(tile));
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (_finished) return KeyEventResult.handled;

    // player movement

    var moveX = 0.0;
    var moveY = 0.0;

    if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) ||
        event.isKeyPressed(LogicalKeyboardKey.keyW)) {
      moveY -= 1;
    }
    if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) ||
        event.isKeyPressed(LogicalKeyboardKey.keyS)) {
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

    _paesantPlayer?.movement = Vector2(moveX, moveY);

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

    if (_finished) return;
  }

  /// Object needs to be removed
  void removeObject(FlamePuzzleComponent component) {
    objects.remove(component);
    for (final tile in flamePuzzleTiles.values) {
      tile.components.remove(component);
      tile.overlayComponents.remove(component);
    }
    collidables.remove(component);
  }

  @override
  void killed() {
    final player = _paesantPlayer;
    if (player == null) return;

    // find bandit
    (collidables.firstWhere((e) => e is BanditComponent) as BanditComponent)
        .attack(player);
  }

  @override
  void finished() {
    final player = _paesantPlayer;
    if (player == null) return;

    // finished
    _finished = true;

    // stop player
    player.movement = Vector2.zero();
  }

  @override
  void triggerAction(FlamePuzzleComponent component) {
    if (component is LeverComponent) {
      final door = objects.firstWhere((e) => e is DoorComponent);
      removeObject(door);
    }
  }

  @override
  void openDoor(FlamePuzzleComponent component) {}

  @override
  void joystick(Vector2 joystick) {
    if (_finished) return;

    _paesantPlayer?.movement = joystick;
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
