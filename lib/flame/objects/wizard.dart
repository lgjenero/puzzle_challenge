import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:flame/geometry.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:very_good_slide_puzzle/flame/objects/objects.dart';
import 'package:very_good_slide_puzzle/flame/utils/texture_packer.dart';
import 'package:very_good_slide_puzzle/models/models.dart' as puzzle;

/// {@template flame_puzzle_player_component}
/// The Flame Puzzle player component.
/// {@endtemplate}
class WizardComponent extends FlamePuzzleDirectionAnimationComponent
    with FlamePuzzleMovingComponent, HasHitboxes, Collidable {
  /// {@macro flame_puzzle_player_component}
  WizardComponent({
    required this.game,
    required FlamePuzzleGameTiledComponent map,
    required Map<puzzle.Position, FlamePuzzleTile> tiles,
    required SimpleDirectionAnimation animation,
    required Vector2 position,
    required Vector2 size,
    bool isOverlay = false,
    this.speed = 35,
    this.gravity = 10,
    this.gravityMax = 80,
    this.jumpSpeed = 200,
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
  static Future<WizardComponent> create({
    required FlamePuzzleGame game,
    required FlamePuzzleGameTiledComponent map,
    required Map<puzzle.Position, FlamePuzzleTile> tiles,
    required Vector2 position,
    required Vector2 size,
    bool isOverlay = false,
    double speed = 35,
    double gravity = 10,
    double gravityMax = 80,
    double jumpSpeed = 280,
  }) async {
    final sprites = await TexturepackerLoader.fromJSONAtlas(
      'sprites/chara/chara_right.png',
      'images/sprites/chara/chara_right.json',
    );

    final idleRight = SpriteAnimation.spriteList(
      sprites['idle_']!,
      stepTime: 0.1,
    );
    final runRight = SpriteAnimation.spriteList(
      sprites['run_']!,
      stepTime: 0.05,
    );

    final animation = SimpleDirectionAnimation(
      idleRight: idleRight,
      runRight: runRight,
    )
      ..idleRight = idleRight
      ..runRight = runRight
      ..runUp = SpriteAnimation.spriteList(
        sprites['jump_']!,
        stepTime: 0.25,
      )
      ..play(SimpleAnimationEnum.idleRight);

    final comp = WizardComponent(
      game: game,
      map: map,
      tiles: tiles,
      animation: animation,
      position: position,
      size: size,
      isOverlay: isOverlay,
      speed: speed,
      jumpSpeed: jumpSpeed,
      gravity: gravity,
      gravityMax: gravityMax,
    );
    await comp.onLoad();
    return comp;
  }

  @override
  Future<void>? onLoad() {
    addHitbox(HitboxCircle(normalizedRadius: 0.6));
    collidableType = CollidableType.active;
    return super.onLoad();
  }

  /// Game reference
  final FlamePuzzleGame game;

  /// Movement speed
  final double speed;

  /// Movement speed
  final double jumpSpeed;

  /// Gravity
  final double gravity;

  /// Gravity max speed
  final double gravityMax;

  /// Player picked up the key
  bool hasKey = false;

  /// Player movement
  Vector2 movement = Vector2.zero();

  final Vector2 _velocity = Vector2.zero();

  SimpleAnimationEnum _lastAnimation = SimpleAnimationEnum.idleRight;

  /// Player killed
  bool _killed = false;

  double _lastX = 0;

  bool _isOnGround = false;

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
      _backtrackCollision(intersectionPoints, checkGround: true);
    } else if (other is LeverComponent) {
      _pullLever(other);
    } else if (other is DoorComponent) {
      if (!_checkOpenDoor(other)) {
        _backtrackCollision(intersectionPoints);
      }
    } else if (other is SlimeComponent) {
      _die();
    } else if (other is ExitComponent) {
      _finished();
    }
    super.onCollision(intersectionPoints, other);
  }

  void _move(double dt) {
    // update 'real position'
    _velocity.x = movement.x * speed;
    if (movement.y > 0 && _isOnGround) {
      _velocity.y = -jumpSpeed;
      _isOnGround = false;
    } else {
      _velocity.y = (_velocity.y + gravity).clamp(-jumpSpeed, gravityMax);
    }
    position += _velocity * dt;

    // check animation
    final animationType = _animation(movement.x, _lastX, false);
    if (_lastAnimation != animationType) {
      _lastAnimation = animationType;
      play(animationType);
    }

    if (movement.x != 0) {
      _lastX = movement.x;
    }
  }

  final _up = Vector2(0, -1);

  void _backtrackCollision(
    Set<Vector2> intersectionPoints, {
    bool checkGround = false,
  }) {
    if (intersectionPoints.length == 2) {
      final mid =
          (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) /
              2;
      var collisionNormal = absoluteCenter - mid;
      final separationDistance = (size.y * 0.6 / 2) - collisionNormal.length;
      collisionNormal = collisionNormal.normalized();

      if (checkGround) {
        if (_up.dot(collisionNormal) > 0.9) {
          _isOnGround = true;
          _velocity.y = 0;
        }
      }

      position += collisionNormal.scaled(separationDistance);
    }
  }

  bool _checkOpenDoor(DoorComponent door) {
    if (!hasKey) return false;
    door.playing = true;
    return true;
  }

  void _die() {
    _killed = true;

    // game.killed();
  }

  void _pullLever(LeverComponent lever) {
    hasKey = true;
    lever.playing = true;

    // TODO:  find door and open it
  }

  void _finished() {
    game.finished();
  }

  SimpleAnimationEnum _animation(double x, double lastX, bool jump) {
    final SimpleAnimationEnum animation;
    if (jump) {
      animation = SimpleAnimationEnum.runUp;
    } else {
      if (x > 0) {
        animation = SimpleAnimationEnum.runRight;
      } else if (x < 0) {
        animation = SimpleAnimationEnum.runLeft;
      } else {
        if (lastX >= 0) {
          animation = SimpleAnimationEnum.idleRight;
        } else {
          animation = SimpleAnimationEnum.idleLeft;
        }
      }
    }

    return animation;
  }
}
