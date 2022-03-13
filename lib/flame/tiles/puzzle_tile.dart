import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:very_good_slide_puzzle/models/tile.dart';

/// {@template flame_puzzle_tile}
/// The Flame puzzle tile component.
/// {@endtemplate}
class FlamePuzzleTile extends Component {
  /// {@macro flame_puzzle_tile}
  FlamePuzzleTile(
    this.map,
    this.overlay,
    this.components,
    this.overlayComponents,
    this.tile,
    this.previousTile,
    this.spacing,
    this.gameOffset,
    this.transitionAnimation,
    this.outlineColor,
    this.backgroundColor,
  );

  /// Tiled map
  final FlamePuzzleGameRenderableTiledMap map;

  /// Overlay tiles
  final List<SpriteBatchComponent> overlay;

  /// Components that are part of this tile
  final Map<FlamePuzzleComponent, Vector2> components;

  /// Overlay components
  final Map<FlamePuzzleComponent, Vector2> overlayComponents;

  /// Starting tile position
  Tile tile;

  /// Ending tile position
  Tile previousTile;

  /// tile spacing
  double spacing;

  /// game offset;
  final Vector2 gameOffset;

  /// Transition animation time
  final double transitionAnimation;

  /// Tile outline color
  final Color outlineColor;

  /// Tile background color;
  final Color backgroundColor;

  double _startTime = 0;
  double _startProgress = 0;
  bool _playedStart = false;

  bool _haveBefore = false;
  bool _haveAfter = false;
  double _time = 0;

  double _completeTime = 0;
  bool _completed = false;

  /// puzzle completed
  void setCompleted() => _completed = true;

  /// puzzle completed
  void setUnCompleted() => _completed = false;

  /// Tile rendeing transform
  late RSTransform transform;

  /// Tile rendeing transform matrix
  late Matrix4 matrix4;

  /// Outline paint
  late Paint _paint;

  late double _alpha;

  /// Update tile setup
  void updateSetup(Tile tile, Tile previousTile, double spacing) {
    this.tile = tile;
    this.previousTile = previousTile;
    this.spacing = spacing;

    _completed = false;
    _haveBefore = false;
    _haveAfter = false;
    _time = 0;
  }

  @override
  void update(double dt) {
    if (_completed) {
      _updateCompleted(dt);
    } else if (_playedStart) {
      _updateAfterStart(dt);
    } else {
      _updateDuringStart(dt);
    }
  }

  void _updateDuringStart(double dt) {
    _startTime += dt;
    _startProgress = (_startTime / transitionAnimation).clamp(0.0, 1.0);
    _alpha = _startProgress;

    if (_startProgress >= 1) {
      _playedStart = true;
      _paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = outlineColor;

      _updateAfterStart(dt);
    } else {
      _startProgress = Curves.bounceOut.transform(_startProgress);

      _paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 * _startProgress
        ..color = outlineColor.withAlpha((255 * _startProgress).round());

      final offset = Vector2(
        tile.currentPosition.x.toDouble() - 1,
        tile.currentPosition.y.toDouble() - 1,
      );

      transform = _calculateTransform(
        offset,
        map.puzzleTileWidth,
        map.puzzleTileHeight,
        spacing * _startProgress,
      );
      matrix4 = Matrix4(
        transform.scos, transform.ssin, 0, 0, //
        -transform.ssin, transform.scos, 0, 0, //
        0, 0, 0, 0, //
        transform.tx, transform.ty, 0, 1, //
      );
    }
  }

  void _updateAfterStart(double dt) {
    _time += dt;
    var progress = _time / transitionAnimation;

    final Vector2 offset;
    if (progress <= 0) {
      if (_haveBefore) return;
      offset = Vector2(
        previousTile.currentPosition.x.toDouble() - 1,
        previousTile.currentPosition.y.toDouble() - 1,
      );
      _haveBefore = true;
    } else if (progress >= 1) {
      if (_haveAfter) return;

      if (_startProgress < 1) {
        _startProgress = 1;
        _alpha = 1;
        _paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4 * _startProgress
          ..color = outlineColor.withAlpha((255 * _startProgress).round());
      }

      offset = Vector2(
        tile.currentPosition.x.toDouble() - 1,
        tile.currentPosition.y.toDouble() - 1,
      );

      _haveAfter = true;
    } else {
      if (_startProgress < progress) {
        _alpha = progress;
        _startProgress = progress;
        _paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4 * _startProgress
          ..color = outlineColor.withAlpha((255 * _startProgress).round());
      }

      progress = Curves.easeInOutBack.transform(progress);
      final x = previousTile.currentPosition.x +
          (tile.currentPosition.x - previousTile.currentPosition.x) * progress;
      final y = previousTile.currentPosition.y +
          (tile.currentPosition.y - previousTile.currentPosition.y) * progress;
      offset = Vector2(x - 1, y - 1);
    }

    transform = _calculateTransform(
      offset,
      map.puzzleTileWidth,
      map.puzzleTileHeight,
      spacing,
    );
    matrix4 = Matrix4(
      transform.scos, transform.ssin, 0, 0, //
      -transform.ssin, transform.scos, 0, 0, //
      0, 0, 0, 0, //
      transform.tx, transform.ty, 0, 1, //
    );
  }

  void _updateCompleted(double dt) {
    if (_alpha <= 0) return;

    _completeTime += dt;
    final progress =
        (_completeTime / transitionAnimation).clamp(0, 1).toDouble();

    _alpha = 1 - progress;

    _startProgress = 1 - Curves.bounceOut.transform(progress);

    _paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * _startProgress
      ..color = outlineColor.withAlpha((255 * _startProgress).round());

    final offset = Vector2(
      tile.currentPosition.x.toDouble() - 1,
      tile.currentPosition.y.toDouble() - 1,
    );

    transform = _calculateTransform(
      offset,
      map.puzzleTileWidth,
      map.puzzleTileHeight,
      spacing * _startProgress,
    );
    matrix4 = Matrix4(
      transform.scos, transform.ssin, 0, 0, //
      -transform.ssin, transform.scos, 0, 0, //
      0, 0, 0, 0, //
      transform.tx, transform.ty, 0, 1, //
    );
  }

  RSTransform _calculateTransform(
    Vector2 offset,
    double tileWidth,
    double tileHight,
    double spacing,
  ) {
    final padding = spacing / 2;

    // apply scaling for inset
    final scale = 1 - spacing / tileWidth;

    // apply shuffle &  game offset
    final shuffleTransform = offset * tileWidth + gameOffset;

    // apply scale and shuffle
    final scaledOffset = Vector2(
      padding + offset.x * spacing,
      padding + offset.y * spacing,
    );

    final finalOffset = Vector2(
      scale * shuffleTransform.x + scaledOffset.x,
      scale * shuffleTransform.y + scaledOffset.y,
    );

    return RSTransform(
      scale,
      0,
      finalOffset.x,
      finalOffset.y,
    );
  }

  @override
  void renderTree(Canvas canvas) {
    final alpha = tile.isWhitespace ? _alpha : -1;
    if (alpha >= 1) return;

    final rect = RRect.fromLTRBR(
      0,
      0,
      map.puzzleTileWidth,
      map.puzzleTileHeight,
      Radius.circular(8 * _startProgress),
    );

    canvas
      ..save()
      ..transform(matrix4.storage)
      ..clipRRect(rect);

    super.renderTree(canvas);
    for (final comp in components.entries) {
      canvas
        ..save()
        ..translate(comp.value.x, comp.value.y);

      comp.key.render(canvas);
      canvas.restore();
    }

    for (final batch in overlay) {
      batch.render(canvas);
    }

    for (final comp in overlayComponents.entries) {
      canvas
        ..save()
        ..translate(comp.value.x, comp.value.y);

      comp.key.render(canvas);
      canvas.restore();
    }

    canvas.drawRRect(rect, _paint);

    if (alpha > 0) {
      canvas.drawColor(
        backgroundColor.withAlpha((alpha * 255).toInt()),
        BlendMode.srcOver,
      );
    }

    canvas.restore();
  }
}
