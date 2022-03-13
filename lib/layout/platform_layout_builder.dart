import 'package:universal_platform/universal_platform.dart'
    show UniversalPlatform;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

import 'package:flutter/widgets.dart';

/// Represents the layout platform passed to [PlatformLayoutBuilder.child].
enum PlatformLayout {
  /// Mobile layout
  mobile,

  /// Desktop layout
  desktop,
}

/// Signature for the individual builders (`mobile`, `desktop`).
typedef PlatformLayoutWidgetBuilder = Widget Function(BuildContext, Widget?);

/// {@template platform_layout_builder}
/// A wrapper around [LayoutBuilder] which exposes builders for
/// various responsive breakpoints.
/// {@endtemplate}
class PlatformLayoutBuilder extends StatelessWidget {
  /// {@macro platform_layout_builder}
  const PlatformLayoutBuilder({
    Key? key,
    required this.mobile,
    required this.desktop,
    this.child,
  }) : super(key: key);

  /// [PlatformLayoutWidgetBuilder] for mobile layout.
  final PlatformLayoutWidgetBuilder mobile;

  /// [PlatformLayoutWidgetBuilder] for desktop layout.
  final PlatformLayoutWidgetBuilder desktop;

  /// Optional child widget builder based on the current platform
  /// which will be passed to the `mobile` and `desktop` builders
  /// as a way to share/optimize shared layout.
  final Widget Function(PlatformLayout currentPlatform)? child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (UniversalPlatform.isAndroid ||
            UniversalPlatform.isIOS ||
            defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android) {
          return mobile(context, child?.call(PlatformLayout.mobile));
        }

        return desktop(context, child?.call(PlatformLayout.desktop));
      },
    );
  }
}
