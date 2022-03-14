import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_slide_puzzle/l10n/l10n.dart';
import 'package:very_good_slide_puzzle/theme/theme.dart';
import 'package:very_good_slide_puzzle/typography/typography.dart';

/// WASD instructions UI
class WasdInstructions extends StatelessWidget {
  /// WASD instructions UI
  const WasdInstructions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final titleColor = theme.defaultColor;

    final textStyle = PuzzleTextStyle.headline4.copyWith(color: titleColor);

    return AnimatedDefaultTextStyle(
      style: textStyle,
      duration: PuzzleThemeAnimationDuration.textStyle,
      textAlign: TextAlign.center,
      child: Text(
        context.l10n.wasdInstructions,
      ),
    );
  }
}
