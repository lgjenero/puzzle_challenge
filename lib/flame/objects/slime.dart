import 'dart:async';
import 'dart:developer';

import 'package:bonfire/bonfire.dart';
import 'package:collection/collection.dart';
import 'package:flame/geometry.dart';
import 'package:tiled/tiled.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:very_good_slide_puzzle/flame/utils/texture_packer.dart';
import 'package:very_good_slide_puzzle/models/models.dart' as game;

/// Slime types
enum SlimeType {
  /// Green slime
  green,

  /// Orange slime
  orange,
}

extension _SlimeTypeUtils on SlimeType {
  int get sheetNumber {
    switch (this) {
      case SlimeType.green:
        return 1;
      case SlimeType.orange:
        return 1;
    }
  }
}

/// {@template platform_slime_component}
/// The Slime component.
/// {@endtemplate}
class SlimeComponent extends FlamePuzzleAnimationComponent
    with FlamePuzzleMovingComponent, HasHitboxes, Collidable {
  /// {@macro platform_slime_component}
  SlimeComponent({
    required FlamePuzzleGameTiledComponent map,
    required Map<game.Position, FlamePuzzleTile> tiles,
    required SpriteAnimation animation,
    required Vector2 position,
    required Vector2 size,
    bool isOverlay = false,
  }) : super(
          FlamePuzzleComponentType.enemy,
          animation: animation,
          position: position,
          size: size,
          isOverlay: isOverlay,
        ) {
    this.map = map;
    this.tiles = tiles;
  }

  /// Creates Slime component
  static Future<SlimeComponent> create({
    required FlamePuzzleGameTiledComponent map,
    required Map<game.Position, FlamePuzzleTile> tiles,
    required Vector2 position,
    required SlimeType type,
    required Vector2 size,
    bool isOverlay = false,
  }) async {
    final sprites = <Sprite>[];
    for (var i = 0; i < type.sheetNumber; i++) {
      final packedSprites = await TexturepackerLoader.fromJSONAtlas(
        'sprites/slime/${type.name}/idle_$i.png',
        'images/sprites/slime/${type.name}/idle_$i.json',
      );
      sprites.addAll(packedSprites.values.first);
    }

    final animation = SpriteAnimation.spriteList(
      sprites,
      stepTime: 0.15,
    );

    return SlimeComponent(
      map: map,
      tiles: tiles,
      animation: animation,
      position: position,
      size: size,
      isOverlay: isOverlay,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    updateTileAndPosition();
  }

  @override
  Future<void>? onLoad() {
    addHitbox(HitboxCircle(normalizedRadius: 0.7));
    collidableType = CollidableType.active;
    return super.onLoad();
  }
}

/// Creates slime component
Future<FlamePuzzleComponent?> createSlime(
  FlamePuzzleGame game,
  TiledObject obj, {
  bool isOverlay = false,
}) async {
  SlimeType? type;

  final slimeType = obj.properties
      .firstWhereOrNull((e) => e.name == 'slimetype')
      ?.value
      .toLowerCase();
  try {
    type = SlimeType.values.firstWhere((e) => e.name == slimeType);
  } catch (ex) {
    log('Decoration with type $slimeType not found');
  }

  if (type == null) return null;

  final rect = game.getObjectRect(obj);
  final position = rect.topLeft.toVector2();
  final size = rect.sizeVector2;

  return SlimeComponent.create(
    map: game.map,
    tiles: game.flamePuzzleTiles,
    position: position,
    size: size,
    type: type,
    isOverlay: isOverlay,
  );
}
