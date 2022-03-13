import 'dart:ui';

import 'package:very_good_slide_puzzle/colors/colors.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/platform/platform.dart';
import 'package:very_good_slide_puzzle/theme/themes/themes.dart';

/// {@template Platform_theme}
/// The Platform puzzle theme.
/// {@endtemplate}
class PlatformTheme extends PuzzleTheme {
  /// {@macro Platform_theme}
  const PlatformTheme() : super();

  @override
  String get name => 'Platform';

  @override
  bool get hasTimer => false;

  @override
  Color get nameColor => PuzzleColors.white;

  @override
  Color get titleColor => PuzzleColors.white2;

  @override
  Color get backgroundColor => PuzzleColors.black;

  @override
  Color get defaultColor => PuzzleColors.primary5;

  @override
  Color get buttonColor => PuzzleColors.teal;

  @override
  Color get hoverColor => PuzzleColors.primary3;

  @override
  Color get pressedColor => PuzzleColors.primary7;

  @override
  bool get isLogoColored => false;

  @override
  Color get menuActiveColor => PuzzleColors.white;

  @override
  Color get menuUnderlineColor => PuzzleColors.white;

  @override
  Color get menuInactiveColor => PuzzleColors.white2;

  @override
  Color get tileOutlineColor => PuzzleColors.teal;

  @override
  String get audioControlOnAsset => 'assets/images/audio_control/simple_on.png';

  @override
  String get audioControlOffAsset =>
      'assets/images/audio_control/simple_off.png';

  @override
  PuzzleLayoutDelegate get layoutDelegate =>
      const PlatformPuzzleLayoutDelegate();

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
