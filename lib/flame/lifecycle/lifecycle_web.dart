// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:very_good_slide_puzzle/flame/lifecycle/lifecycle.dart';

/// {@macro platformRegisterLifecycleObserver}
void platformRegisterLifecycleObserver(LifecycleObserver observer) {
  window
    ..addEventListener('focus', observer.onFocus)
    ..addEventListener('blur', observer.onBlur);
}

/// {@macro platformUnregisterLifecycleObserver}
void platformUnregisterLifecycleObserver(LifecycleObserver observer) {
  window
    ..removeEventListener('focus', observer.onFocus)
    ..removeEventListener('blur', observer.onBlur);
}
