import 'dart:async';
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flame/geometry.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:very_good_slide_puzzle/flame/objects/objects.dart';
import 'package:very_good_slide_puzzle/flame/utils/texture_packer.dart';
import 'package:very_good_slide_puzzle/models/position.dart';

const _pi_4 = pi / 4;
const _pi_3_4 = 3 * pi / 4;
const _pi_5_4 = 5 * pi / 4;
const _pi_7_4 = 7 * pi / 4;

/// {@template flame_puzzle_peasant_component}
/// The Flame Puzzle peasant component.
/// {@endtemplate}
class PeasantComponent extends FlamePuzzleDirectionAnimationComponent
    with FlamePuzzleMovingComponent, HasHitboxes, Collidable {
  /// {@macro flame_puzzle_peasant_component}
  PeasantComponent({
    required this.game,
    required FlamePuzzleGameTiledComponent map,
    required Map<Position, FlamePuzzleTile> tiles,
    required SimpleDirectionAnimation animation,
    required Vector2 position,
    required Vector2 size,
    this.speed = 20,
    bool isOverlay = false,
  }) : super(
          FlamePuzzleComponentType.player,
          animation: animation,
          position: position,
          size: size,
          isOverlay: isOverlay,
        ) {
    this.map = map;
    this.tiles = tiles;
  }

  /// creates Player component
  static Future<PeasantComponent> create({
    required FlamePuzzleGame game,
    required FlamePuzzleGameTiledComponent map,
    required Map<Position, FlamePuzzleTile> tiles,
    required Vector2 position,
    required Vector2 size,
    bool isOverlay = false,
  }) async {
    final spritesUp = await TexturepackerLoader.fromJSONAtlas(
      'sprites/person/up.png',
      'images/sprites/person/up.json',
    );

    final spritesDown = await TexturepackerLoader.fromJSONAtlas(
      'sprites/person/down.png',
      'images/sprites/person/down.json',
    );

    final spritesRight = await TexturepackerLoader.fromJSONAtlas(
      'sprites/person/right.png',
      'images/sprites/person/right.json',
    );

    final idleRight = SpriteAnimation.spriteList(
      spritesRight['Side Idle Character 1']!,
      stepTime: 0.1,
    );
    final runRight = SpriteAnimation.spriteList(
      spritesRight['Side Run Character 1']!,
      stepTime: 0.1,
    );

    final idleDown = SpriteAnimation.spriteList(
      spritesDown['Down Idle Character 1']!,
      stepTime: 0.1,
    );
    final runDown = SpriteAnimation.spriteList(
      spritesDown['Down Run Character 1']!,
      stepTime: 0.1,
    );

    final idleUp = SpriteAnimation.spriteList(
      spritesUp['Up Idle Character 1']!,
      stepTime: 0.1,
    );
    final runUp = SpriteAnimation.spriteList(
      spritesUp['Up Run Character 1']!,
      stepTime: 0.1,
    );

    final dieRight = SpriteAnimation.spriteList(
      spritesRight['Side Die Character 1']!,
      stepTime: 0.1,
      loop: false,
    );
    final dieDown = SpriteAnimation.spriteList(
      spritesDown['Down Die Character 1']!,
      stepTime: 0.1,
      loop: false,
    );
    final dieUp = SpriteAnimation.spriteList(
      spritesUp['Up Die Character 1']!,
      stepTime: 0.1,
      loop: false,
    );

    final animation = SimpleDirectionAnimation(
      idleRight: idleRight,
      runRight: runRight,
    )
      ..idleRight = idleRight
      ..runRight = runRight
      ..idleDown = idleDown
      ..runDown = runDown
      ..idleUp = idleUp
      ..runUp = runUp;

    await animation.addOtherAnimation(_dieRight, dieRight);
    await animation.addOtherAnimation(_dieUp, dieUp);
    await animation.addOtherAnimation(_dieDown, dieDown);

    animation.play(SimpleAnimationEnum.idleRight);

    final comp = PeasantComponent(
      game: game,
      map: map,
      tiles: tiles,
      animation: animation,
      position: position,
      size: size,
      isOverlay: isOverlay,
    );
    await comp.onLoad();
    return comp;
  }

  @override
  Future<void>? onLoad() {
    addHitbox(HitboxCircle(normalizedRadius: 0.25, position: Vector2(0, 0.75)));
    collidableType = CollidableType.active;
    return super.onLoad();
  }

  static const _dieRight = 'dieRight';
  static const _dieUp = 'dieUp';
  static const _dieDown = 'dieDown';

  /// Game reference
  final FlamePuzzleGame game;

  /// Movement speed
  final double speed;

  /// Player picked up the key
  bool hasKey = false;

  /// Player movement
  Vector2 movement = Vector2.zero();

  SimpleAnimationEnum _lastAnimation = SimpleAnimationEnum.idleRight;

  /// Player killed
  bool _killed = false;

  @override
  void update(double dt) {
    super.update(dt);

    // stay in place when killed
    if (_killed) {
    } else {
      _move(dt);
    }

    // update animation
    animation.update(dt, Vector2.zero(), size, 1);

    // update tile position(s)
    updateTileAndPosition();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    if (_killed) return;
    if (other is Wall) {
      _backtrackCollision(intersectionPoints);
    } else if (other is LeverComponent) {
      _pullLever(other);
    } else if (other is DoorComponent) {
      if (!_checkOpenDoor(other)) {
        _backtrackCollision(intersectionPoints);
      }
    } else if (other is BanditComponent) {
      _die();
    } else if (other is ExitComponent) {
      _finished();
    }
  }

  void _move(double dt) {
    // update 'real position'
    if (movement.x != 0 || movement.y != 0) {
      position += movement.normalized() * dt * speed;
    }

    // check animation
    final animationType = _animation(movement);
    if (_lastAnimation != animationType) {
      _lastAnimation = animationType;
      play(animationType);
    }
  }

  void _backtrackCollision(Set<Vector2> intersectionPoints) {
    if (intersectionPoints.length == 2) {
      final mid =
          (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) /
              2;
      final collisionNormal = absoluteCenter - mid;
      final separationDistance = (size.x / 8) - collisionNormal.length;

      position += collisionNormal.normalized().scaled(separationDistance);
    }
  }

  bool _checkOpenDoor(DoorComponent door) {
    if (!hasKey) return false;
    door.playing = true;
    return true;
  }

  void _die() {
    _killed = true;

    final String animationKey;
    final bool flip;

    switch (_lastAnimation) {
      case SimpleAnimationEnum.idleLeft:
      case SimpleAnimationEnum.runLeft:
        animationKey = _dieRight;
        flip = true;
        break;
      case SimpleAnimationEnum.runUp:
      case SimpleAnimationEnum.idleUp:
        animationKey = _dieUp;
        flip = false;
        break;
      case SimpleAnimationEnum.runDown:
      case SimpleAnimationEnum.idleDown:
        animationKey = _dieDown;
        flip = false;
        break;
      // ignore: no_default_cases
      default:
        animationKey = _dieRight;
        flip = false;
        break;
    }

    animation.playOther(animationKey, flipX: flip);

    game.killed();
  }

  void _pullLever(LeverComponent lever) {
    lever
      ..playing = true
      ..collidableType = CollidableType.inactive;
    game.triggerAction(lever);
  }

  void _finished() {
    game.finished();
  }

  SimpleAnimationEnum _animation(Vector2 movement) {
    if (movement.length == 0) {
      switch (_lastAnimation) {
        case SimpleAnimationEnum.runLeft:
          return SimpleAnimationEnum.idleLeft;
        case SimpleAnimationEnum.runUp:
          return SimpleAnimationEnum.idleUp;
        case SimpleAnimationEnum.runRight:
          return SimpleAnimationEnum.idleRight;
        case SimpleAnimationEnum.runDown:
          return SimpleAnimationEnum.idleDown;
        // ignore: no_default_cases
        default:
          return _lastAnimation;
      }
    }

    var angle = movement.angleTo(Vector2(0, 1));
    if (movement.x < 0) angle = -angle;

    if (angle > -_pi_3_4) {
      if (angle < -_pi_4) {
        return SimpleAnimationEnum.runLeft;
      } else if (angle < _pi_4) {
        return SimpleAnimationEnum.runDown;
      } else if (angle < _pi_3_4) {
        return SimpleAnimationEnum.runRight;
      } else if (angle < _pi_5_4) {
        return SimpleAnimationEnum.runUp;
      } else if (angle < _pi_7_4) {
        return SimpleAnimationEnum.runLeft;
      } else {
        return SimpleAnimationEnum.runDown;
      }
    } else {
      return SimpleAnimationEnum.runUp;
    }
  }
}
