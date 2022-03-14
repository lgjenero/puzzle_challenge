import 'dart:ui';

import 'package:very_good_slide_puzzle/colors/colors.dart';
import 'package:very_good_slide_puzzle/house/house.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/theme/themes/themes.dart';

/// {@template House_theme}
/// The House puzzle theme.
/// {@endtemplate}
class HouseTheme extends PuzzleTheme {
  /// {@macro House_theme}
  const HouseTheme() : super();

  @override
  String get name => 'Mansion';

  @override
  bool get hasTimer => false;

  @override
  Color get nameColor => PuzzleColors.black2;

  @override
  Color get titleColor => PuzzleColors.black;

  @override
  Color get backgroundColor => PuzzleColors.offWhite;

  @override
  Color get defaultColor => PuzzleColors.black2;

  @override
  Color get buttonColor => PuzzleColors.yellowPrimary;

  @override
  Color get hoverColor => PuzzleColors.yellowPrimary;

  @override
  Color get pressedColor => PuzzleColors.yellowPrimary;

  @override
  bool get isLogoColored => true;

  @override
  Color get menuActiveColor => PuzzleColors.black;

  @override
  Color get menuUnderlineColor => PuzzleColors.black;

  @override
  Color get menuInactiveColor => PuzzleColors.black2;

  @override
  Color get tileOutlineColor => PuzzleColors.purplePrimary;

  @override
  String get audioControlOnAsset => 'assets/images/audio_control/simple_on.png';

  @override
  String get audioControlOffAsset =>
      'assets/images/audio_control/simple_off.png';

  @override
  PuzzleLayoutDelegate get layoutDelegate => const HousePuzzleLayoutDelegate();

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
