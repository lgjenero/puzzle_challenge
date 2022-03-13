import 'dart:math' as _math;

import 'package:flutter/material.dart';
import 'package:very_good_slide_puzzle/joystick/circle_view.dart';

/// Joystick callback
typedef JoystickDirectionCallback = void Function(
  double degrees,
  double distance,
);

/// Joystick view
class JoystickView extends StatelessWidget {
  /// Joystick view
  JoystickView({
    this.size,
    this.iconsColor = Colors.white54,
    this.backgroundColor = Colors.blueGrey,
    this.innerCircleColor = Colors.blueGrey,
    this.opacity,
    this.onDirectionChanged,
    this.interval,
    this.showArrows = true,
  });

  /// The size of the joystick.
  ///
  /// Defaults to half of the width in the portrait
  /// or half of the height in the landscape mode
  final double? size;

  /// Color of the icons
  ///
  /// Defaults to [Colors.white54]
  final Color iconsColor;

  /// Color of the joystick background
  ///
  /// Defaults to [Colors.blueGrey]
  final Color backgroundColor;

  /// Color of the inner (smaller) circle background
  ///
  /// Defaults to [Colors.blueGrey]
  final Color innerCircleColor;

  /// Opacity of the joystick
  ///
  /// The opacity applies to the whole joystick including icons
  ///
  /// Defaults to [null] which means there will be no [Opacity] widget used
  final double? opacity;

  /// Callback to be called when user pans the joystick
  ///
  /// Defaults to [null]
  final JoystickDirectionCallback? onDirectionChanged;

  /// Indicates how often the [onDirectionChanged] should be called.
  ///
  /// Defaults to [null] which means there will be no lower limit.
  /// Setting it to ie. 1 second will cause the callback to be not called more often
  /// than once per second.
  ///
  /// The exception is the [onDirectionChanged] callback being called
  /// on the [onPanStart] and [onPanEnd] callbacks. It will be called immediately.
  final Duration? interval;

  /// Shows top/right/bottom/left arrows on top of Joystick
  ///
  /// Defaults to [true]
  final bool showArrows;

  @override
  Widget build(BuildContext context) {
    final actualSize = size ??
        _math.min(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ) *
            0.5;
    final innerCircleSize = actualSize / 2;
    var lastPosition = Offset(innerCircleSize, innerCircleSize);
    var joystickInnerPosition = _calculatePositionOfInnerCircle(
      lastPosition,
      innerCircleSize,
      actualSize,
      Offset.zero,
    );

    DateTime? _callbackTimestamp;

    return Center(
      child: StatefulBuilder(
        builder: (context, setState) {
          final joystick = Stack(
            children: <Widget>[
              CircleView.joystickCircle(
                actualSize,
                backgroundColor,
              ),
              Positioned(
                top: joystickInnerPosition.dy,
                left: joystickInnerPosition.dx,
                child: CircleView.joystickInnerCircle(
                  actualSize / 2,
                  innerCircleColor,
                ),
              ),
              if (showArrows) ...createArrows(),
            ],
          );

          return GestureDetector(
            onPanStart: (details) {
              _callbackTimestamp = _processGesture(
                actualSize,
                actualSize / 2,
                details.localPosition,
                _callbackTimestamp,
              );
              setState(() => lastPosition = details.localPosition);
            },
            onPanEnd: (details) {
              _callbackTimestamp = null;
              if (onDirectionChanged != null) {
                onDirectionChanged?.call(0, 0);
              }
              joystickInnerPosition = _calculatePositionOfInnerCircle(
                Offset(innerCircleSize, innerCircleSize),
                innerCircleSize,
                actualSize,
                Offset.zero,
              );
              setState(
                () => lastPosition = Offset(innerCircleSize, innerCircleSize),
              );
            },
            onPanUpdate: (details) {
              _callbackTimestamp = _processGesture(
                actualSize,
                actualSize / 2,
                details.localPosition,
                _callbackTimestamp,
              );
              joystickInnerPosition = _calculatePositionOfInnerCircle(
                lastPosition,
                innerCircleSize,
                actualSize,
                details.localPosition,
              );

              setState(() => lastPosition = details.localPosition);
            },
            child: (opacity != null)
                ? Opacity(opacity: opacity!, child: joystick)
                : joystick,
          );
        },
      ),
    );
  }

  /// Create arrows
  List<Widget> createArrows() {
    return [
      Positioned(
        top: 16,
        left: 0,
        right: 0,
        child: Icon(
          Icons.arrow_upward,
          color: iconsColor,
        ),
      ),
      Positioned(
        top: 0,
        bottom: 0,
        left: 16,
        child: Icon(
          Icons.arrow_back,
          color: iconsColor,
        ),
      ),
      Positioned(
        top: 0,
        bottom: 0,
        right: 16,
        child: Icon(
          Icons.arrow_forward,
          color: iconsColor,
        ),
      ),
      Positioned(
        bottom: 16,
        left: 0,
        right: 0,
        child: Icon(
          Icons.arrow_downward,
          color: iconsColor,
        ),
      ),
    ];
  }

  DateTime? _processGesture(
    double size,
    double ignoreSize,
    Offset offset,
    DateTime? callbackTimestamp,
  ) {
    final middle = size / 2.0;

    final angle = _math.atan2(offset.dy - middle, offset.dx - middle);
    var degrees = angle * 180 / _math.pi + 90;
    if (offset.dx < middle && offset.dy < middle) {
      degrees = 360 + degrees;
    }

    final dx = _math.max(0, _math.min(offset.dx, size));
    final dy = _math.max(0, _math.min(offset.dy, size));

    final distance =
        _math.sqrt(_math.pow(middle - dx, 2) + _math.pow(middle - dy, 2));

    final normalizedDistance = _math.min(distance / (size / 2), 1).toDouble();

    var _callbackTimestamp = callbackTimestamp;
    if (onDirectionChanged != null &&
        _canCallOnDirectionChanged(callbackTimestamp)) {
      _callbackTimestamp = DateTime.now();
      onDirectionChanged?.call(degrees, normalizedDistance);
    }

    return _callbackTimestamp;
  }

  /// Checks if the [onDirectionChanged] can be called.
  ///
  /// Returns true if enough time has passed since last time it was called
  /// or when there is no [interval] set.
  bool _canCallOnDirectionChanged(DateTime? callbackTimestamp) {
    if (interval != null && callbackTimestamp != null) {
      final intervalMilliseconds = interval!.inMilliseconds;
      final timestampMilliseconds = callbackTimestamp.millisecondsSinceEpoch;
      final currentTimeMilliseconds = DateTime.now().millisecondsSinceEpoch;

      if (currentTimeMilliseconds - timestampMilliseconds <=
          intervalMilliseconds) {
        return false;
      }
    }

    return true;
  }

  Offset _calculatePositionOfInnerCircle(
    Offset lastPosition,
    double innerCircleSize,
    double size,
    Offset offset,
  ) {
    final middle = size / 2.0;

    final angle = _math.atan2(offset.dy - middle, offset.dx - middle);
    var degrees = angle * 180 / _math.pi;
    if (offset.dx < middle && offset.dy < middle) {
      degrees = 360 + degrees;
    }
    final isStartPosition = lastPosition.dx == innerCircleSize &&
        lastPosition.dy == innerCircleSize;
    final lastAngleRadians = isStartPosition ? 0 : degrees * (_math.pi / 180.0);

    final rBig = size / 2;
    final rSmall = innerCircleSize / 2;

    final x = (lastAngleRadians == -1)
        ? rBig - rSmall
        : (rBig - rSmall) + (rBig - rSmall) * _math.cos(lastAngleRadians);
    final y = (lastAngleRadians == -1)
        ? rBig - rSmall
        : (rBig - rSmall) + (rBig - rSmall) * _math.sin(lastAngleRadians);

    var xPosition = lastPosition.dx - rSmall;
    var yPosition = lastPosition.dy - rSmall;

    final angleRadianPlus = lastAngleRadians + _math.pi / 2;
    if (angleRadianPlus < _math.pi / 2) {
      if (xPosition > x) {
        xPosition = x;
      }
      if (yPosition < y) {
        yPosition = y;
      }
    } else if (angleRadianPlus < _math.pi) {
      if (xPosition > x) {
        xPosition = x;
      }
      if (yPosition > y) {
        yPosition = y;
      }
    } else if (angleRadianPlus < 3 * _math.pi / 2) {
      if (xPosition < x) {
        xPosition = x;
      }
      if (yPosition > y) {
        yPosition = y;
      }
    } else {
      if (xPosition < x) {
        xPosition = x;
      }
      if (yPosition < y) {
        yPosition = y;
      }
    }
    return Offset(xPosition, yPosition);
  }
}
