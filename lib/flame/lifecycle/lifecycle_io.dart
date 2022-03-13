import 'package:flutter/material.dart';
import 'package:very_good_slide_puzzle/flame/lifecycle/lifecycle.dart';

/// {@macro platformRegisterLifecycleObserver}
void platformRegisterLifecycleObserver(LifecycleObserver observer) {
  WidgetsBinding.instance!.addObserver(observer);
}

/// {@macro platformUnregisterLifecycleObserver}
void platformUnregisterLifecycleObserver(LifecycleObserver observer) {
  WidgetsBinding.instance!.removeObserver(observer);
}
