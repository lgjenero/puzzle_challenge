import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_slide_puzzle/layout/platform_layout_builder.dart';
import 'package:very_good_slide_puzzle/theme/theme.dart';
import 'package:very_good_slide_puzzle/typography/typography.dart';

/// {@template puzzle_title}
/// Displays the title of the puzzle in the given color.
/// {@endtemplate}
class PuzzleTitle extends StatelessWidget {
  /// {@macro puzzle_title}
  const PuzzleTitle({
    Key? key,
    required this.title,
    this.color,
  }) : super(key: key);

  /// The title to be displayed.
  final String title;

  /// The color of [title], defaults to [PuzzleTheme.titleColor].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final titleColor = color ?? theme.titleColor;

    return PlatformLayoutBuilder(
      mobile: (_, child) => child!,
      desktop: (_, child) => child!,
      child: (platform) {
        final textStyle = platform == PlatformLayout.mobile
            ? PuzzleTextStyle.headline5.copyWith(color: titleColor)
            : PuzzleTextStyle.headline3.copyWith(color: titleColor);

        return AnimatedDefaultTextStyle(
          style: textStyle,
          duration: PuzzleThemeAnimationDuration.textStyle,
          child: Text(
            title,
          ),
        );
      },
    );
  }
}
