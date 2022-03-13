import 'package:flutter/widgets.dart';

/// Represents the layout orientation passed to [OrientationLayoutBuilder.child].
enum OrientationLayout {
  /// Lansdcape layout
  landscape,

  /// Portrait layout
  portrait,
}

/// Signature for the individual builders (`landscape`, `portrait`).
typedef OrientationLayoutWidgetBuilder = Widget Function(BuildContext, Widget?);

/// {@template orientation_layout_builder}
/// A wrapper around [LayoutBuilder] which exposes builders for
/// various responsive breakpoints.
/// {@endtemplate}
class OrientationLayoutBuilder extends StatelessWidget {
  /// {@macro orientation_layout_builder}
  const OrientationLayoutBuilder({
    Key? key,
    required this.landscape,
    required this.portrait,
    this.child,
  }) : super(key: key);

  /// [OrientationLayoutWidgetBuilder] for landscape layout.
  final OrientationLayoutWidgetBuilder landscape;

  /// [OrientationLayoutWidgetBuilder] for portrait layout.
  final OrientationLayoutWidgetBuilder portrait;

  /// Optional child widget builder based on the current layout size
  /// which will be passed to the `small`, `medium` and `large` builders
  /// as a way to share/optimize shared layout.
  final Widget Function(OrientationLayout currentOrientation)? child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        if (screenWidth > screenHeight) {
          return landscape(context, child?.call(OrientationLayout.landscape));
        }

        return portrait(context, child?.call(OrientationLayout.portrait));
      },
    );
  }
}
