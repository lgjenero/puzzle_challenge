import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_slide_puzzle/l10n/l10n.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/layout/orientation_layout_builder.dart';
import 'package:very_good_slide_puzzle/theme/theme.dart';
import 'package:very_good_slide_puzzle/typography/typography.dart';

/// {@template number_of_moves_and_tiles_left}
/// Displays how many moves have been made on the current puzzle
/// and how many puzzle tiles are not in their correct position.
/// {@endtemplate}
class NumberOfMovesAndTilesLeft extends StatelessWidget {
  /// {@macro number_of_moves_and_tiles_left}
  const NumberOfMovesAndTilesLeft({
    Key? key,
    required this.numberOfMoves,
    required this.numberOfTilesLeft,
    this.color,
  }) : super(key: key);

  /// The number of moves to be displayed.
  final int numberOfMoves;

  /// The number of tiles left to be displayed.
  final int numberOfTilesLeft;

  /// The color of texts that display [numberOfMoves] and [numberOfTilesLeft].
  /// Defaults to [PuzzleTheme.defaultColor].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final l10n = context.l10n;
    final textColor = color ?? theme.defaultColor;

    return PlatformLayoutBuilder(
      mobile: (_, child) => child!,
      desktop: (_, child) => child!,
      child: (platform) {
        final bodyTextStyle = platform == PlatformLayout.mobile
            ? PuzzleTextStyle.bodyXSmall
            : PuzzleTextStyle.bodySmall;

        return Semantics(
          label: l10n.puzzleNumberOfMovesAndTilesLeftLabelText(
            numberOfMoves.toString(),
            numberOfTilesLeft.toString(),
          ),
          child: ExcludeSemantics(
            child: Row(
              key: const Key('number_of_moves_and_tiles_left'),
              crossAxisAlignment: CrossAxisAlignment.baseline,
              mainAxisSize: MainAxisSize.min,
              textBaseline: TextBaseline.alphabetic,
              children: [
                AnimatedDefaultTextStyle(
                  key: const Key('number_of_moves_and_tiles_left_moves'),
                  style: PuzzleTextStyle.headline4.copyWith(
                    color: textColor,
                  ),
                  duration: PuzzleThemeAnimationDuration.textStyle,
                  child: Text(numberOfMoves.toString()),
                ),
                AnimatedDefaultTextStyle(
                  style: bodyTextStyle.copyWith(
                    color: textColor,
                  ),
                  duration: PuzzleThemeAnimationDuration.textStyle,
                  child: Text(' ${l10n.puzzleNumberOfMoves} | '),
                ),
                AnimatedDefaultTextStyle(
                  key: const Key('number_of_moves_and_tiles_left_tiles_left'),
                  style: PuzzleTextStyle.headline4.copyWith(
                    color: textColor,
                  ),
                  duration: PuzzleThemeAnimationDuration.textStyle,
                  child: Text(numberOfTilesLeft.toString()),
                ),
                AnimatedDefaultTextStyle(
                  style: bodyTextStyle.copyWith(
                    color: textColor,
                  ),
                  duration: PuzzleThemeAnimationDuration.textStyle,
                  child: Text(' ${l10n.puzzleNumberOfTilesLeft}'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
