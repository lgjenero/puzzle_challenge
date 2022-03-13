// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:very_good_slide_puzzle/dungeon/dungeon.dart';
import 'package:very_good_slide_puzzle/house/house_theme.dart';
import 'package:very_good_slide_puzzle/platform/platform_theme.dart';
import 'package:very_good_slide_puzzle/theme/theme.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ThemeState', () {
    test('supports value comparisons', () {
      final themes = [MockPuzzleTheme(), MockPuzzleTheme()];

      expect(
        ThemeState(
          themes: themes,
          theme: themes[0],
        ),
        equals(
          ThemeState(
            themes: themes,
            theme: themes[0],
          ),
        ),
      );
    });

    test('default theme is SimpleTheme', () {
      expect(
        ThemeState(themes: const [HouseTheme()]).theme,
        equals(HouseTheme()),
      );
    });

    group('copyWith', () {
      test('updates themes', () {
        final themesA = [HouseTheme(), DungeonTheme()];
        final themesB = [HouseTheme(), PlatformTheme()];

        expect(
          ThemeState(
            themes: themesA,
            theme: HouseTheme(),
          ).copyWith(themes: themesB),
          equals(
            ThemeState(
              themes: themesB,
              theme: HouseTheme(),
            ),
          ),
        );
      });

      test('updates theme', () {
        final themes = [HouseTheme(), DungeonTheme()];
        final themeA = HouseTheme();
        final themeB = DungeonTheme();

        expect(
          ThemeState(
            themes: themes,
            theme: themeA,
          ).copyWith(theme: themeB),
          equals(
            ThemeState(
              themes: themes,
              theme: themeB,
            ),
          ),
        );
      });
    });
  });
}
