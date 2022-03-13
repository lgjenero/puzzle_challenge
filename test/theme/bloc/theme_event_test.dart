// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:very_good_slide_puzzle/house/house_theme.dart';
import 'package:very_good_slide_puzzle/platform/platform.dart';
import 'package:very_good_slide_puzzle/theme/theme.dart';

void main() {
  group('ThemeEvent', () {
    group('ThemeChanged', () {
      test('supports value comparisons', () {
        expect(
          ThemeChanged(themeIndex: 1),
          equals(ThemeChanged(themeIndex: 1)),
        );
        expect(
          ThemeChanged(themeIndex: 2),
          isNot(ThemeChanged(themeIndex: 1)),
        );
      });
    });

    group('ThemeUpdated', () {
      test('supports value comparisons', () {
        expect(
          ThemeUpdated(theme: HouseTheme()),
          equals(ThemeUpdated(theme: HouseTheme())),
        );
        expect(
          ThemeUpdated(theme: PlatformTheme()),
          isNot(ThemeUpdated(theme: HouseTheme())),
        );
      });
    });
  });
}
