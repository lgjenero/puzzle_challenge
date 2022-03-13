import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';

/// {@template flame_puzzle_texture_packer_loader}
/// The RPG Texture packer loader.
/// {@endtemplate}
class TexturepackerLoader {
  /// Loads Sprite sheets from Texture packer data
  static Future<Map<String, List<Sprite>>> fromJSONAtlas(
    String imagePath,
    String dataPath, {
    List<String>? animations,
  }) async {
    final json = await Flame.assets.readJson(dataPath);

    final dynamic jsonFrames = json['frames'];

    if (jsonFrames is! List) return {};

    final sprites = <String, List<_SpriteInfo>>{};
    final spriteSizes = <String, Vector2>{};

    for (var i = 0; i < jsonFrames.length; i++) {
      final dynamic frameData = jsonFrames[i];
      if (frameData is! Map<String, dynamic>) continue;

      final sprite = _loadSprite(frameData);
      if (sprite == null) continue;
      if (animations?.contains(sprite.animation) == false) continue;

      (sprites[sprite.animation] ??= <_SpriteInfo>[]).add(sprite);

      var updateSize = false;
      final maxSize = spriteSizes[sprite.animation] ?? Vector2.zero();
      if (maxSize.x < sprite.srcSize.x) {
        maxSize.x = sprite.srcSize.x;
        updateSize = true;
      }
      if (maxSize.y < sprite.srcSize.y) {
        maxSize.y = sprite.srcSize.y;
        updateSize = true;
      }
      if (updateSize) spriteSizes[sprite.animation] = maxSize;
    }

    if (sprites.isEmpty) return {};

    final image = await Flame.images.load(imagePath);

    final spriteMap = <String, List<Sprite>>{};
    for (final entry in sprites.entries) {
      final spriteList = entry.value
        ..sort((lhs, rhs) => lhs.frame.compareTo(rhs.frame));

      spriteMap[entry.key] = spriteList
          .map(
            (e) => PaddedSprite(
              image,
              insets: e.srcInsets,
              srcPosition: e.srcPosition,
              srcSize: e.srcSize,
            ),
          )
          .toList();
    }

    return spriteMap;
  }

  static _SpriteInfo? _loadSprite(Map<String, dynamic> frame) {
    final dynamic filename = frame['filename'];
    if (filename is! String) return null;

    final dynamic frameData = frame['frame'];
    if (frameData is! Map<String, dynamic>) return null;

    final dynamic x = frameData['x'];
    if (x is! num) return null;

    final dynamic y = frameData['y'];
    if (y is! num) return null;

    final dynamic w = frameData['w'];
    if (w is! num) return null;

    final dynamic h = frameData['h'];
    if (h is! num) return null;

    final dynamic rotated = frame['rotated'];
    if (rotated is! bool) return null;

    final dynamic trimmed = frame['trimmed'];
    if (trimmed is! bool) return null;

    final match = _regExp.firstMatch(filename);
    if (match == null) return null;

    final matchString = match.group(0);
    if (matchString == null) return null;

    final animation =
        filename.substring(0, filename.length - matchString.length).trim();

    final frameIdx = int.tryParse(matchString);
    if (frameIdx == null) return null;

    final Vector4 srcInsets;
    final dynamic spriteSourceSize = frame['spriteSourceSize'];
    final dynamic sourceSize = frame['sourceSize'];
    if (spriteSourceSize is Map<String, dynamic> &&
        sourceSize is Map<String, dynamic>) {
      final x =
          spriteSourceSize['x'] is num ? spriteSourceSize['x'] as num : null;
      final y =
          spriteSourceSize['y'] is num ? spriteSourceSize['y'] as num : null;
      final w =
          spriteSourceSize['w'] is num ? spriteSourceSize['w'] as num : null;
      final h =
          spriteSourceSize['h'] is num ? spriteSourceSize['h'] as num : null;

      final sizeWidth = sourceSize['w'] is num ? sourceSize['w'] as num : null;
      final sizeHeight = sourceSize['h'] is num ? sourceSize['h'] as num : null;

      if (x != null &&
          y != null &&
          w != null &&
          h != null &&
          sizeWidth != null &&
          sizeHeight != null) {
        srcInsets = Vector4(
          x.toDouble(),
          y.toDouble(),
          (sizeWidth - w - x).toDouble(),
          (sizeHeight - h - y).toDouble(),
        );
      } else {
        srcInsets = Vector4.zero();
      }
    } else {
      srcInsets = Vector4.zero();
    }

    return _SpriteInfo(
      srcPosition: Vector2(x.toDouble(), y.toDouble()),
      srcSize: Vector2(
        w.toDouble(),
        h.toDouble(),
      ),
      srcInsets: srcInsets,
      animation: animation,
      frame: frameIdx,
      rotated: rotated,
      trimmed: trimmed,
    );
  }

  static final RegExp _regExp = RegExp(r'\d+$', caseSensitive: false);
}

class _SpriteInfo {
  const _SpriteInfo({
    required this.srcPosition,
    required this.srcSize,
    required this.srcInsets,
    required this.animation,
    required this.frame,
    required this.rotated,
    required this.trimmed,
  });

  final Vector2 srcPosition;
  final Vector2 srcSize;
  final Vector4 srcInsets;
  final String animation;
  final int frame;
  final bool rotated;
  final bool trimmed;
}

/// {@template flame_puzzle_padded_sprite}
/// The RPG padded sprite used to load texture packer sprites.
/// {@endtemplate}
class PaddedSprite extends Sprite {
  /// {@macro flame_puzzle_padded_sprite}
  PaddedSprite(
    Image image, {
    Vector4? insets,
    Vector2? srcPosition,
    Vector2? srcSize,
  })  : _insets = insets ?? Vector4.zero(),
        _sourceImageSize = Vector2(
          (srcSize ?? image.size).x + (insets?.x ?? 0) + (insets?.z ?? 0),
          (srcSize ?? image.size).y + (insets?.y ?? 0) + (insets?.w ?? 0),
        ),
        super(
          image,
          srcPosition: srcPosition,
          srcSize: srcSize,
        );

  /// Padding offset
  final Vector4 _insets;

  /// original image size
  final Vector2 _sourceImageSize;

  @override
  void render(
    Canvas canvas, {
    Vector2? position,
    Vector2? size,
    Anchor anchor = Anchor.topLeft,
    Paint? overridePaint,
  }) {
    final pos = (position ?? Vector2.zero()).clone();
    final sz = (size ?? srcSize).clone();
    final scale = Vector2(sz.x / _sourceImageSize.x, sz.y / _sourceImageSize.y);

    if (_insets != Vector4.zero()) {
      pos
        ..x += _insets.x * scale.x
        ..y += _insets.y * scale.y;
      sz
        ..x -= (_insets.x + _insets.z) * scale.x
        ..y -= (_insets.y + _insets.w) * scale.y;
    }

    super.render(
      canvas,
      position: pos,
      size: sz,
      anchor: anchor,
      overridePaint: overridePaint,
    );
  }
}
