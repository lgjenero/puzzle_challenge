import 'dart:ui';

import 'package:very_good_slide_puzzle/colors/colors.dart';
import 'package:very_good_slide_puzzle/dungeon/dungeon.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/theme/themes/themes.dart';

/// {@template Dungeon_theme}
/// The Dungeon puzzle theme.
/// {@endtemplate}
class DungeonTheme extends PuzzleTheme {
  /// {@macro Dungeon_theme}
  const DungeonTheme() : super();

  @override
  String get name => 'Dungeon';

  @override
  bool get hasTimer => false;

  @override
  Color get nameColor => PuzzleColors.yellow50;

  @override
  Color get titleColor => PuzzleColors.darkPurple;

  @override
  Color get backgroundColor => PuzzleColors.blueWhite;

  @override
  Color get defaultColor => PuzzleColors.midPurple;

  @override
  Color get buttonColor => PuzzleColors.lightPurple;

  @override
  Color get hoverColor => PuzzleColors.yellowPrimary;

  @override
  Color get pressedColor => PuzzleColors.yellowPrimary;

  @override
  bool get isLogoColored => true;

  @override
  Color get menuActiveColor => PuzzleColors.darkPurple;

  @override
  Color get menuUnderlineColor => PuzzleColors.midPurple;

  @override
  Color get menuInactiveColor => PuzzleColors.midPurple;

  @override
  Color get tileOutlineColor => PuzzleColors.nicePurple;

  @override
  String get audioControlOnAsset => 'assets/images/audio_control/simple_on.png';

  @override
  String get audioControlOffAsset =>
      'assets/images/audio_control/simple_off.png';

  @override
  PuzzleLayoutDelegate get layoutDelegate =>
      const DungeonPuzzleLayoutDelegate();

  @override
  List<Object?> get props => [
        name,
        audioControlOnAsset,
        audioControlOffAsset,
        hasTimer,
        nameColor,
        titleColor,
        backgroundColor,
        defaultColor,
        buttonColor,
        hoverColor,
        pressedColor,
        isLogoColored,
        menuActiveColor,
        menuUnderlineColor,
        menuInactiveColor,
        layoutDelegate,
      ];
}
