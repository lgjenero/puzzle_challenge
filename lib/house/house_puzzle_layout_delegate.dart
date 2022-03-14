import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:very_good_slide_puzzle/flame/views/wasd_instructions.dart';
import 'package:very_good_slide_puzzle/house/house.dart';
import 'package:very_good_slide_puzzle/joystick/joystick_view.dart';
import 'package:very_good_slide_puzzle/l10n/l10n.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/models/models.dart' as puzzle;
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';
import 'package:very_good_slide_puzzle/theme/theme.dart';
import 'package:very_good_slide_puzzle/typography/typography.dart';

/// {@template house_puzzle_layout_delegate}
/// A delegate for computing the layout of the puzzle UI
/// that uses a [HouseTheme].
/// {@endtemplate}
class HousePuzzleLayoutDelegate extends PuzzleLayoutDelegate {
  /// {@macro house_puzzle_layout_delegate}
  const HousePuzzleLayoutDelegate();

  @override
  Widget statusSectionBuilder(PuzzleState state) =>
      HouseStatusSection(state: state);

  @override
  Widget joystyickSectionBuilder(PuzzleState state) =>
      const HousePuzzleJoystick(size: 100);

  @override
  Widget backgroundBuilder(PuzzleState state) => const SizedBox();

  @override
  Widget boardBuilder(int size, List<puzzle.Tile> tiles) {
    return FlamePuzzleGameBoard(
      key: const Key('house_puzzle_board'),
      tiles: tiles,
      spacing: 5,
      gameBuilder: (tiles, spacing, context) =>
          HouseGame(tiles, spacing, context),
    );
  }

  @override
  List<Object?> get props => [];
}

/// {@template house_status_section}
/// Displays the start section of the puzzle based on [state].
/// {@endtemplate}
@visibleForTesting
class HouseStatusSection extends StatelessWidget {
  /// {@macro house_status_section}
  const HouseStatusSection({
    Key? key,
    required this.state,
  }) : super(key: key);

  /// The state of the puzzle.
  final PuzzleState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: OrientationLayoutBuilder(
        landscape: (_, child) => child!,
        portrait: (_, child) => child!,
        child: (orientation) {
          final align = orientation == OrientationLayout.landscape
              ? Alignment.centerLeft
              : Alignment.center;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedAlign(
                alignment: align,
                duration: PuzzleThemeAnimationDuration.textStyle,
                child: HousePuzzleTitle(status: state.puzzleStatus),
              ),
              const SizedBox(height: 12),
              AnimatedAlign(
                alignment: align,
                duration: PuzzleThemeAnimationDuration.textStyle,
                child: NumberOfMovesAndTilesLeft(
                  key: numberOfMovesAndTilesLeftKey,
                  numberOfMoves: state.numberOfMoves,
                  numberOfTilesLeft: state.numberOfTilesLeft,
                ),
              ),
              const SizedBox(height: 16),
              AnimatedAlign(
                alignment: align,
                duration: PuzzleThemeAnimationDuration.textStyle,
                child: const HousePuzzleShuffleButton(),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// {@template House_puzzle_title}
/// Displays the title of the puzzle based on [status].
///
/// Shows the success state when the puzzle is completed,
/// otherwise defaults to the Puzzle Challenge title.
/// {@endtemplate}
@visibleForTesting
class HousePuzzleTitle extends StatelessWidget {
  /// {@macro House_puzzle_title}
  const HousePuzzleTitle({
    Key? key,
    required this.status,
  }) : super(key: key);

  /// The status of the puzzle.
  final PuzzleStatus status;

  @override
  Widget build(BuildContext context) {
    return PuzzleTitle(
      key: puzzleTitleKey,
      title: status == PuzzleStatus.complete
          ? context.l10n.puzzleCompleted
          : context.l10n.puzzleChallengeTitle,
    );
  }
}

/// {@template puzzle_shuffle_button}
/// Displays the button to shuffle the puzzle.
/// {@endtemplate}
@visibleForTesting
class HousePuzzleShuffleButton extends StatelessWidget {
  /// {@macro puzzle_shuffle_button}
  const HousePuzzleShuffleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PuzzleButton(
      onPressed: () => context.read<PuzzleBloc>().add(const PuzzleReset()),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/shuffle_icon.png',
            width: 17,
            height: 17,
          ),
          // const Gap(10),
          const SizedBox(width: 10, height: 10),
          Text(context.l10n.puzzleShuffle),
        ],
      ),
    );
  }
}

/// {@template house_puzzle_joystick}
/// Displays the joystick UI.
/// {@endtemplate}
@visibleForTesting
class HousePuzzleJoystick extends StatelessWidget {
  /// {@macro house_puzzle_joystick}
  const HousePuzzleJoystick({required this.size, Key? key}) : super(key: key);

  /// Joystick size
  final double size;

  @override
  Widget build(BuildContext context) => PlatformLayoutBuilder(
        mobile: (_, __) => JoystickView(
          size: size,
          onDirectionChanged: (degrees, distance) =>
              context.read<PuzzleBloc>().add(
                    JoystickEvent(degrees, distance),
                  ),
        ),
        // desktop: (_, __) => JoystickView(
        //   size: 100,
        //   onDirectionChanged: (degrees, distance) =>
        //       context.read<PuzzleBloc>().add(
        //             JoystickEvent(degrees, distance),
        //           ),
        // ),
        desktop: (_, __) => const WasdInstructions(),
      );
}
