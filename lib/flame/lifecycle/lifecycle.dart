import 'package:flutter/material.dart';

// ignore: always_use_package_imports
import 'lifecycle_core.dart' //
    if (dart.library.io) 'lifecycle_io.dart'
    if (dart.library.html) 'lifecycle_web.dart';

/// Lifecycle mixin
mixin LifecycleObserver on WidgetsBindingObserver {
  /// Called when javascript onFocus is triggered
  void onFocus(dynamic e) {
    didChangeAppLifecycleState(AppLifecycleState.resumed);
  }

  /// Called when javascript onBlur is triggered
  void onBlur(dynamic e) {
    didChangeAppLifecycleState(AppLifecycleState.paused);
  }
}

/// {@template platformRegisterLifecycleObserver}
/// Register lifecycle observer.
/// {@endtemplate}
void registerLifecycleObserver(LifecycleObserver observer) =>
    platformRegisterLifecycleObserver(observer);

/// {@template platformUnegisterLifecycleObserver}
/// Unegister lifecycle observer.
/// {@endtemplate}
void unregisterLifecycleObserver(LifecycleObserver observer) =>
    platformUnregisterLifecycleObserver(observer);
