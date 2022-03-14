// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

/// {@macro platformRequestFullScreen}
void platformRequestFullScreen() =>
    document.documentElement?.requestFullscreen();

/// {@macro platformExitFullScreen}
void platformExitFullScreen() => document.exitFullscreen();
