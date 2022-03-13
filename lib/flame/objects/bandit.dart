import 'dart:async';
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flame/geometry.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:very_good_slide_puzzle/flame/utils/texture_packer.dart';
import 'package:very_good_slide_puzzle/models/position.dart';

const _pi_4 = pi / 4;
const _pi_3_4 = 3 * pi / 4;
const _pi_5_4 = 5 * pi / 4;
const _pi_7_4 = 7 * pi / 4;

/// {@template flame_puzzle_bandit_component}
/// The RPG bandit component.
/// {@endtemplate}
class BanditComponent extends FlamePuzzleDirectionAnimationComponent
    with FlamePuzzleMovingComponent, HasHitboxes, Collidable {
  /// {@macro flame_puzzle_bandit_component}
  BanditComponent({
    required FlamePuzzleGameTiledComponent map,
    required Map<Position, FlamePuzzleTile> tiles,
    required SimpleDirectionAnimation animation,
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
    _initialPosition = position;
  }

  /// creates Bandit component
  static Future<BanditComponent> create({
    required FlamePuzzleGameTiledComponent map,
    required Map<Position, FlamePuzzleTile> tiles,
    required Vector2 position,
    required Vector2 size,
    bool isOverlay = false,
  }) async {
    final spritesUp = await TexturepackerLoader.fromJSONAtlas(
      'sprites/bandit/up.png',
      'images/sprites/bandit/up.json',
    );

    final spritesDown = await TexturepackerLoader.fromJSONAtlas(
      'sprites/bandit/down.png',
      'images/sprites/bandit/down.json',
    );

    final spritesRight = await TexturepackerLoader.fromJSONAtlas(
      'sprites/bandit/right.png',
      'images/sprites/bandit/right.json',
    );

    final idleRight = SpriteAnimation.spriteList(
      spritesRight['Side Idle Character 9']!,
      stepTime: 0.1,
    );
    final runRight = SpriteAnimation.spriteList(
      spritesRight['Side Run Character 9']!,
      stepTime: 0.1,
    );

    final idleDown = SpriteAnimation.spriteList(
      spritesDown['Down Idle Character 9']!,
      stepTime: 0.1,
    );
    final runDown = SpriteAnimation.spriteList(
      spritesDown['Down Run Character 9']!,
      stepTime: 0.1,
    );

    final idleUp = SpriteAnimation.spriteList(
      spritesUp['Up Idle Character 9']!,
      stepTime: 0.1,
    );
    final runUp = SpriteAnimation.spriteList(
      spritesUp['Up Run Character 9']!,
      stepTime: 0.1,
    );

    final attackRight = SpriteAnimation.spriteList(
      spritesRight['Side Swing Character 9']!,
      stepTime: 0.1,
      loop: false,
    );
    final attackDown = SpriteAnimation.spriteList(
      spritesDown['Down Swing Character 9']!,
      stepTime: 0.1,
      loop: false,
    );
    final attackUp = SpriteAnimation.spriteList(
      spritesUp['Up Swing Character 9']!,
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

    await animation.addOtherAnimation(_attackRight, attackRight);
    await animation.addOtherAnimation(_attackUp, attackUp);
    await animation.addOtherAnimation(_attackDown, attackDown);

    animation.play(SimpleAnimationEnum.idleRight);

    final comp = BanditComponent(
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
    addHitbox(HitboxCircle(normalizedRadius: 0.7));
    collidableType = CollidableType.active;
    return super.onLoad();
  }

  static const _attackRight = 'attackRight';
  static const _attackUp = 'attackUp';
  static const _attackDown = 'attackDown';

  bool _attacking = false;

  double _patrolStep = 0;

  final double _speed = 30;

  late final Vector2 _initialPosition;

  SimpleAnimationEnum _lastAnimation = SimpleAnimationEnum.idleRight;

  double _attackStep = 0;
  double _attackDuration = 0;

  @override
  void update(double dt) {
    super.update(dt);

    // stay in place when attacking
    if (_attacking) {
      _attackStep += dt;
      if (_attackStep > _attackDuration) {
        _attacking = false;
      }
    } else {
      _move(dt);
    }

    // update animation
    animation.update(dt, Vector2.zero(), size, 1);

    updateTileAndPosition();
  }

  void _move(double dt) {
    final routeLenght = width * 2;

    _patrolStep += (dt * _speed) / routeLenght;
    while (_patrolStep > 4) {
      _patrolStep -= 4;
    }

    final SimpleAnimationEnum animation;
    if (_patrolStep < 1) {
      position = _initialPosition + Vector2(_patrolStep * routeLenght, 0);
      animation = SimpleAnimationEnum.runRight;
    } else if (_patrolStep < 2) {
      position = _initialPosition +
          Vector2(
            routeLenght,
            -(_patrolStep - 1) * routeLenght,
          );
      animation = SimpleAnimationEnum.runUp;
    } else if (_patrolStep < 3) {
      position = _initialPosition +
          Vector2(
            (3 - _patrolStep) * routeLenght,
            -routeLenght,
          );
      animation = SimpleAnimationEnum.runLeft;
    } else {
      position = _initialPosition +
          Vector2(
            0,
            -(4 - _patrolStep) * routeLenght,
          );
      animation = SimpleAnimationEnum.runDown;
    }

    if (_lastAnimation != animation) {
      _lastAnimation = animation;
      play(animation);
    }
  }

  void attack(PositionComponent player) {
    _attacking = true;

    final String animationKey;
    final bool flip;

    final direction = player.position - position;
    var angle = direction.angleTo(Vector2(0, 1));
    if (direction.x < 0) angle = -angle;

    if (angle > -_pi_3_4) {
      if (angle < -_pi_4) {
        animationKey = _attackRight;
        flip = true;
      } else if (angle < _pi_4) {
        animationKey = _attackDown;
        flip = false;
      } else if (angle < _pi_3_4) {
        animationKey = _attackRight;
        flip = false;
      } else if (angle < _pi_5_4) {
        animationKey = _attackUp;
        flip = false;
      } else if (angle < _pi_7_4) {
        animationKey = _attackRight;
        flip = true;
      } else {
        animationKey = _attackDown;
        flip = false;
      }
    } else {
      animationKey = _attackUp;
      flip = false;
    }

    animation.playOther(animationKey, flipX: flip);

    _lastAnimation = SimpleAnimationEnum.custom;

    _attackDuration = animation.others[animationKey]!.totalDuration();
  }
}
