import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:very_good_slide_puzzle/audio_control/audio_control.dart';
import 'package:very_good_slide_puzzle/dungeon/dungeon.dart';
import 'package:very_good_slide_puzzle/house/house.dart';
import 'package:very_good_slide_puzzle/l10n/l10n.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/layout/orientation_layout_builder.dart';
import 'package:very_good_slide_puzzle/models/models.dart';
import 'package:very_good_slide_puzzle/platform/platform.dart';
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';
import 'package:very_good_slide_puzzle/theme/theme.dart';
import 'package:very_good_slide_puzzle/theme/themes/themes.dart';
import 'package:very_good_slide_puzzle/timer/timer.dart';
import 'package:very_good_slide_puzzle/typography/typography.dart';

/// {@template puzzle_page}
/// The root page of the puzzle UI.
///
/// Builds the puzzle based on the current [PuzzleTheme]
/// from [ThemeBloc].
/// {@endtemplate}
class PuzzlePage extends StatelessWidget {
  /// {@macro puzzle_page}
  const PuzzlePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BlocProvider(
        //   create: (_) => DashatarThemeBloc(
        //     themes: const [
        //       BlueDashatarTheme(),
        //       GreenDashatarTheme(),
        //       YellowDashatarTheme()
        //     ],
        //   ),
        // ),
        // BlocProvider(
        //   create: (_) => DashatarPuzzleBloc(
        //     secondsToBegin: 3,
        //     ticker: const Ticker(),
        //   ),
        // ),
        BlocProvider(
          create: (context) => ThemeBloc(
            initialThemes: [
              const HouseTheme(),
              const DungeonTheme(),
              const PlatformTheme(),
              // context.read<DashatarThemeBloc>().state.theme,
              // const RpgTheme(),
            ],
          ),
        ),
        BlocProvider(
          create: (_) => TimerBloc(
            ticker: const Ticker(),
          ),
        ),
        BlocProvider(
          create: (_) => AudioControlBloc(),
        ),
      ],
      child: const PuzzleView(),
    );
  }
}

/// {@template puzzle_view}
/// Displays the content for the [PuzzlePage].
/// {@endtemplate}
class PuzzleView extends StatelessWidget {
  /// {@macro puzzle_view}
  const PuzzleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    /// Shuffle only if the current theme is Simple.
    final shufflePuzzle = false; //theme is SimpleTheme;

    return Scaffold(
      body: AnimatedContainer(
        duration: PuzzleThemeAnimationDuration.backgroundColorChange,
        decoration: BoxDecoration(color: theme.backgroundColor),
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => TimerBloc(
                ticker: const Ticker(),
              ),
            ),
            BlocProvider(
              create: (context) => PuzzleBloc(4)
                ..add(
                  PuzzleInitialized(
                    shufflePuzzle: shufflePuzzle,
                  ),
                ),
            ),
          ],
          child: const _Puzzle(
            key: Key('puzzle_view_puzzle'),
          ),
        ),
      ),
    );
  }
}

class _Puzzle extends StatelessWidget {
  const _Puzzle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final state = context.select((PuzzleBloc bloc) => bloc.state);

    return Stack(
      fit: StackFit.expand,
      children: [
        theme.layoutDelegate.backgroundBuilder(state),
        const SafeArea(child: PuzzleSections()),
      ],
    );
  }
}

/// {@template puzzle_logo}
/// Displays the logo of the puzzle.
/// {@endtemplate}
@visibleForTesting
class PuzzleLogo extends StatelessWidget {
  /// {@macro puzzle_logo}
  const PuzzleLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    return OrientationLayoutBuilder(
      landscape: (_, child) => child!,
      portrait: (_, child) => child!,
      child: (orientation) {
        final align = orientation == OrientationLayout.landscape
            ? Alignment.centerLeft
            : Alignment.center;
        return AnimatedAlign(
          alignment: align,
          duration: PuzzleThemeAnimationDuration.layoutChange,
          child: AppFlutterLogo(
            key: puzzleLogoKey,
            isColored: theme.isLogoColored,
          ),
        );
      },
    );
  }
}

/// {@template puzzle_sections}
/// Displays start and end sections of the puzzle.
/// {@endtemplate}
class PuzzleSections extends StatelessWidget {
  /// {@macro puzzle_sections}
  const PuzzleSections({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final state = context.select((PuzzleBloc bloc) => bloc.state);

    return PlatformLayoutBuilder(
      mobile: (context, child) => child!,
      desktop: (context, child) => child!,
      child: (platform) => OrientationLayoutBuilder(
        landscape: (context, child) => child!,
        portrait: (context, child) => child!,
        child: (orientation) => LayoutBuilder(
          builder: (context, constraints) => Stack(
            fit: StackFit.expand,
            children: [
              AnimatedPositioned(
                top: 10,
                height: 40,
                left: orientation == OrientationLayout.landscape ? 20 : 0,
                width: orientation == OrientationLayout.landscape
                    ? 150
                    : constraints.maxWidth,
                duration: PuzzleThemeAnimationDuration.layoutChange,
                child: const PuzzleLogo(),
              ),
              AnimatedPositioned(
                left: 0,
                right: 0,
                height: 40,
                top: orientation == OrientationLayout.landscape ? 10 : 50,
                duration: PuzzleThemeAnimationDuration.layoutChange,
                child: const PuzzleMenu(),
              ),
              AnimatedPositioned(
                left: 0,
                top: orientation == OrientationLayout.landscape ? 50 : 90,
                height: orientation == OrientationLayout.landscape
                    ? platform == PlatformLayout.desktop
                        ? constraints.maxHeight
                        : constraints.maxHeight / 2
                    : platform == PlatformLayout.desktop
                        ? 180
                        : 150,
                width: orientation == OrientationLayout.landscape
                    ? platform == PlatformLayout.desktop
                        ? 300
                        : 200
                    : constraints.maxWidth,
                duration: PuzzleThemeAnimationDuration.layoutChange,
                child: theme.layoutDelegate.statusSectionBuilder(state),
              ),
              AnimatedPositioned(
                left: 0,
                bottom: platform == PlatformLayout.mobile
                    ? orientation == OrientationLayout.landscape
                        ? ((constraints.maxHeight / 2 - 50) - 100) / 2
                        : 0
                    : 0,
                height: platform == PlatformLayout.mobile ? 100 : 0,
                width: orientation == OrientationLayout.landscape
                    ? platform == PlatformLayout.desktop
                        ? 300
                        : 200
                    : constraints.maxWidth,
                duration: PuzzleThemeAnimationDuration.layoutChange,
                child: theme.layoutDelegate.joystyickSectionBuilder(state),
              ),
              AnimatedPositioned(
                top: orientation == OrientationLayout.landscape
                    ? 50
                    : platform == PlatformLayout.desktop
                        ? 280
                        : 260,
                left: orientation == OrientationLayout.landscape ? 300 : 0,
                bottom: platform == PlatformLayout.mobile
                    ? orientation == OrientationLayout.landscape
                        ? 0
                        : 100
                    : 0,
                right: 0,
                duration: PuzzleThemeAnimationDuration.layoutChange,
                child: const PuzzleBoard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// {@template puzzle_board}
/// Displays the board of the puzzle.
/// {@endtemplate}
@visibleForTesting
class PuzzleBoard extends StatelessWidget {
  /// {@macro puzzle_board}
  const PuzzleBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final puzzle = context.select((PuzzleBloc bloc) => bloc.state.puzzle);

    final size = puzzle.getDimension();
    if (size == 0) return const CircularProgressIndicator();

    return BlocListener<PuzzleBloc, PuzzleState>(
      listener: (context, state) {
        if (theme.hasTimer && state.puzzleStatus == PuzzleStatus.complete) {
          context.read<TimerBloc>().add(const TimerStopped());
        }
      },
      child: Padding(
        // padding: const EdgeInsets.all(20),
        padding: EdgeInsets.zero,
        child: theme.layoutDelegate.boardBuilder(
          size,
          puzzle.tiles,
        ),
      ),
    );
  }
}

/// {@template puzzle_menu}
/// Displays the menu of the puzzle.
/// {@endtemplate}
@visibleForTesting
class PuzzleMenu extends StatelessWidget {
  /// {@macro puzzle_menu}
  const PuzzleMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themes = context.select((ThemeBloc bloc) => bloc.state.themes);

    return OrientationLayoutBuilder(
      landscape: (_, child) => child!,
      portrait: (_, child) => child!,
      child: (orientation) {
        final align = orientation == OrientationLayout.landscape
            ? Alignment.centerRight
            : Alignment.center;
        return AnimatedAlign(
          alignment: align,
          duration: PuzzleThemeAnimationDuration.layoutChange,
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  themes.length,
                  (index) => PuzzleMenuItem(
                    theme: themes[index],
                    themeIndex: index,
                  ),
                ),
                const SizedBox(width: 44),
                AudioControl(key: audioControlKey),
                const SizedBox(width: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// {@template puzzle_menu_item}
/// Displays the menu item of the [PuzzleMenu].
/// {@endtemplate}
@visibleForTesting
class PuzzleMenuItem extends StatelessWidget {
  /// {@macro puzzle_menu_item}
  const PuzzleMenuItem({
    Key? key,
    required this.theme,
    required this.themeIndex,
  }) : super(key: key);

  /// The theme corresponding to this menu item.
  final PuzzleTheme theme;

  /// The index of [theme] in [ThemeState.themes].
  final int themeIndex;

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final isCurrentTheme = theme == currentTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Tooltip(
        message: theme != currentTheme ? context.l10n.puzzleChangeTooltip : '',
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ).copyWith(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
          onPressed: () {
            // Ignore if this theme is already selected.
            if (theme == currentTheme) {
              return;
            }

            // Update the currently selected theme.
            context.read<ThemeBloc>().add(ThemeChanged(themeIndex: themeIndex));

            // Reset the timer of the currently running puzzle.
            context.read<TimerBloc>().add(const TimerReset());

            // Initialize the puzzle board for the newly selected theme.
            context
                .read<PuzzleBloc>()
                .add(const PuzzleInitialized(shufflePuzzle: false));
          },
          child: AnimatedDefaultTextStyle(
            duration: PuzzleThemeAnimationDuration.textStyle,
            style: PuzzleTextStyle.headline5.copyWith(
              color: isCurrentTheme
                  ? currentTheme.menuActiveColor
                  : currentTheme.menuInactiveColor,
            ),
            child: Text(theme.name),
          ),
        ),
      ),
    );
  }
}

/// The global key of [PuzzleLogo].
///
/// Used to animate the transition of [PuzzleLogo] when changing a theme.
final puzzleLogoKey = GlobalKey(debugLabel: 'puzzle_logo');

/// The global key of [PuzzleName].
///
/// Used to animate the transition of [PuzzleName] when changing a theme.
final puzzleNameKey = GlobalKey(debugLabel: 'puzzle_name');

/// The global key of [PuzzleTitle].
///
/// Used to animate the transition of [PuzzleTitle] when changing a theme.
final puzzleTitleKey = GlobalKey(debugLabel: 'puzzle_title');

/// The global key of [NumberOfMovesAndTilesLeft].
///
/// Used to animate the transition of [NumberOfMovesAndTilesLeft]
/// when changing a theme.
final numberOfMovesAndTilesLeftKey =
    GlobalKey(debugLabel: 'number_of_moves_and_tiles_left');

/// The global key of [AudioControl].
///
/// Used to animate the transition of [AudioControl]
/// when changing a theme.
final audioControlKey = GlobalKey(debugLabel: 'audio_control');
