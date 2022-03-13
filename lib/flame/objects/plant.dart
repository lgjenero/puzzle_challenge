import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:bonfire/bonfire.dart';
import 'package:intl/intl.dart';
import 'package:tiled/tiled.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:very_good_slide_puzzle/flame/utils/texture_packer.dart';
import 'package:very_good_slide_puzzle/models/models.dart' as game;

/// Plant types
enum PlantType {
  /// Simple plant type
  plant,

  /// Plant with mutiple stems
  multiplant,

  /// Plant waving in the wind
  windplant,

  /// Blue flower plant
  blueflower,

  /// Waving plant
  waveplant,

  /// Small plant
  smallplant
}

extension _PlantTypeUtils on PlantType {
  int get sheetNumber {
    switch (this) {
      case PlantType.plant:
        return 1;
      case PlantType.multiplant:
        return 1;
      case PlantType.windplant:
        return 1;
      case PlantType.blueflower:
        return 2;
      case PlantType.waveplant:
        return 1;
      case PlantType.smallplant:
        return 1;
    }
  }
}

/// {@template platform_plant_component}
/// The Plant component.
/// {@endtemplate}
class PlantComponent extends FlamePuzzleAnimationComponent
    with FlamePuzzleMovingComponent {
  /// {@macro platform_plant_component}
  PlantComponent({
    required FlamePuzzleGameTiledComponent map,
    required Map<game.Position, FlamePuzzleTile> tiles,
    required SpriteAnimation animation,
    required Vector2 position,
    required Vector2 size,
    bool isOverlay = false,
  }) : super(
          FlamePuzzleComponentType.decoration,
          animation: animation,
          position: position,
          size: size,
          isOverlay: isOverlay,
        ) {
    this.map = map;
    this.tiles = tiles;
  }

  /// Creates Plant component
  static Future<PlantComponent> create({
    required FlamePuzzleGameTiledComponent map,
    required Map<game.Position, FlamePuzzleTile> tiles,
    required Vector2 position,
    required PlantType type,
    required Vector2 size,
    bool isOverlay = false,
  }) async {
    final sprites = <Sprite>[];
    for (var i = 0; i < type.sheetNumber; i++) {
      final packedSprites = await TexturepackerLoader.fromJSONAtlas(
        'sprites/plants/${type.name}/idle_$i.png',
        'images/sprites/plants/${type.name}/idle_$i.json',
      );
      sprites.addAll(packedSprites.values.first);
    }

    final animation = SpriteAnimation.spriteList(
      sprites,
      stepTime: 0.15,
    );

    return PlantComponent(
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
}

/// Creates decoration component
Future<FlamePuzzleComponent?> createPlant(
  FlamePuzzleGame game,
  TiledObject obj, {
  bool isOverlay = false,
}) async {
  PlantType? type;

  final plantType = obj.properties
      .firstWhereOrNull((e) => e.name == 'planttype')
      ?.value
      .toLowerCase();
  try {
    type = PlantType.values.firstWhere((e) => e.name == plantType);
  } catch (ex) {
    log('Decoration with type $plantType not found');
  }

  if (type == null) return null;

  final rect = game.getObjectRect(obj);
  final position = rect.topLeft.toVector2();
  final size = rect.sizeVector2;

  return PlantComponent.create(
    map: game.map,
    tiles: game.flamePuzzleTiles,
    position: position,
    size: size,
    type: type,
    isOverlay: isOverlay,
  );
}
