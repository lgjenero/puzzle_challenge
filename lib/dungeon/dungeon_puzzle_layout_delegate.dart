import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_slide_puzzle/dungeon/dungeon.dart';
import 'package:very_good_slide_puzzle/flame/flame_puzzle.dart';
import 'package:very_good_slide_puzzle/flame/views/wasd_instructions.dart';
import 'package:very_good_slide_puzzle/joystick/joystick_view.dart';
import 'package:very_good_slide_puzzle/l10n/l10n.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/models/models.dart';
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';
import 'package:very_good_slide_puzzle/theme/theme.dart';

/// {@template dungeon_puzzle_layout_delegate}
/// A delegate for computing the layout of the puzzle UI
/// that uses a [DungeonTheme].
/// {@endtemplate}
class DungeonPuzzleLayoutDelegate extends PuzzleLayoutDelegate {
  /// {@macro dungeon_puzzle_layout_delegate}
  const DungeonPuzzleLayoutDelegate();

  @override
  Widget statusSectionBuilder(PuzzleState state) =>
      DungeonStatusSection(state: state);

  @override
  Widget joystyickSectionBuilder(PuzzleState state) =>
      const DungeonPuzzleJoystick(size: 100);

  @override
  Widget backgroundBuilder(PuzzleState state) => const SizedBox();

  @override
  Widget boardBuilder(int size, List<Tile> tiles) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: FlamePuzzleGameBoard(
          key: const Key('dungeon_puzzle_board'),
          tiles: tiles,
          spacing: 5,
          gameBuilder: (tiles, spacing, context) =>
              DungeonGame(tiles, spacing, context),
        ),
      ),
    );
  }

  @override
  List<Object?> get props => [];
}

/// {@template dungeon_status_section}
/// Displays the start section of the puzzle based on [state].
/// {@endtemplate}
@visibleForTesting
class DungeonStatusSection extends StatelessWidget {
  /// {@macro dungeon_status_section}
  const DungeonStatusSection({
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
                child: DungeonPuzzleTitle(status: state.puzzleStatus),
              ),
              const SizedBox(height: 8),
              AnimatedAlign(
                alignment: align,
                duration: PuzzleThemeAnimationDuration.textStyle,
                child: NumberOfMovesAndTilesLeft(
                  key: numberOfMovesAndTilesLeftKey,
                  numberOfMoves: state.numberOfMoves,
                  numberOfTilesLeft: state.numberOfTilesLeft,
                ),
              ),
              const SizedBox(height: 10),
              AnimatedAlign(
                alignment: align,
                duration: PuzzleThemeAnimationDuration.textStyle,
                child: const DungeonPuzzleShuffleButton(),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// {@template Dungeon_puzzle_title}
/// Displays the title of the puzzle based on [status].
///
/// Shows the success state when the puzzle is completed,
/// otherwise defaults to the Puzzle Challenge title.
/// {@endtemplate}
@visibleForTesting
class DungeonPuzzleTitle extends StatelessWidget {
  /// {@macro Dungeon_puzzle_title}
  const DungeonPuzzleTitle({
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
class DungeonPuzzleShuffleButton extends StatelessWidget {
  /// {@macro puzzle_shuffle_button}
  const DungeonPuzzleShuffleButton({Key? key}) : super(key: key);

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

/// {@template dungeon_puzzle_joystick}
/// Displays the joystick UI.
/// {@endtemplate}
@visibleForTesting
class DungeonPuzzleJoystick extends StatelessWidget {
  /// {@macro dungeon_puzzle_joystick}
  const DungeonPuzzleJoystick({required this.size, Key? key}) : super(key: key);

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
