// ignore: always_use_package_imports
import 'fullscreen_core.dart' //
    if (dart.library.io) 'fullscreen_io.dart'
    if (dart.library.html) 'fullscreen_web.dart';

/// {@template platformRequestFullScreen}
/// Request fullscreen display.
/// {@endtemplate}
void requestFullScreen() => platformRequestFullScreen();

/// {@template platformExitFullScreen}
/// Exit fullscreen display.
/// {@endtemplate}
void exitFullScreen() => platformExitFullScreen();
