// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

// ignore_for_file: public_member_api_docs, avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:very_good_slide_puzzle/helpers/helpers.dart';
import 'package:very_good_slide_puzzle/l10n/l10n.dart';
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';

class App extends StatefulWidget {
  const App({Key? key, ValueGetter<PlatformHelper>? platformHelperFactory})
      : _platformHelperFactory = platformHelperFactory ?? getPlatformHelper,
        super(key: key);

  final ValueGetter<PlatformHelper> _platformHelperFactory;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  /// The path to local assets folder.
  static const localAssetsPrefix = 'assets/';

  static final audioControlAssets = [
    'assets/images/audio_control/simple_on.png',
    'assets/images/audio_control/simple_off.png',
  ];

  static final audioAssets = [
    'assets/audio/shuffle.mp3',
    'assets/audio/click.mp3',
    'assets/audio/dumbbell.mp3',
    'assets/audio/sandwich.mp3',
    'assets/audio/skateboard.mp3',
    'assets/audio/success.mp3',
    'assets/audio/tile_move.mp3',
  ];

  static final gameImageAssets = [
    'assets/images/tiles/Dungeon@64x64.png',
    'assets/images/tiles/Interior@64x64.png',
    'assets/images/tiles/Mossy - TileSet_128.png',
    'assets/images/tiles/Mossy - DecorationBackground_128.png',
    'assets/images/sprites/bandit/up.png',
    'assets/images/sprites/bandit/down.png',
    'assets/images/sprites/bandit/right.png',
    'assets/images/sprites/person/up.png',
    'assets/images/sprites/person/down.png',
    'assets/images/sprites/person/right.png',
    'assets/images/sprites/chara/right.png',
    'assets/images/sprites/fire/fire.png',
    'assets/images/sprites/plants/blueflower/idle_0.png',
    'assets/images/sprites/plants/blueflower/idle_1.png',
    'assets/images/sprites/plants/multiplant/idle_0.png',
    'assets/images/sprites/plants/plant/idle_0.png',
    'assets/images/sprites/plants/smallplant/idle_0.png',
    'assets/images/sprites/plants/waveplant/idle_0.png',
    'assets/images/sprites/plants/windplant/idle_0.png',
    'assets/images/sprites/slime/orange/idle_0.png',
    'assets/images/sprites/slime/green/idle_0.png',
  ];

  static final gameDataAssets = [
    'assets/tiles/dungeon.tmx',
    'assets/tiles/house.tmx',
    'assets/tiles/moss.tmx',
    'assets/images/sprites/bandit/up.json',
    'assets/images/sprites/bandit/down.json',
    'assets/images/sprites/bandit/right.json',
    'assets/images/sprites/person/up.json',
    'assets/images/sprites/person/down.json',
    'assets/images/sprites/person/right.json',
    'assets/images/sprites/chara/right.json',
    'assets/images/sprites/fire/fire.json',
    'assets/images/sprites/plants/blueflower/idle_0.json',
    'assets/images/sprites/plants/blueflower/idle_1.json',
    'assets/images/sprites/plants/multiplant/idle_0.json',
    'assets/images/sprites/plants/plant/idle_0.json',
    'assets/images/sprites/plants/smallplant/idle_0.json',
    'assets/images/sprites/plants/waveplant/idle_0.json',
    'assets/images/sprites/plants/windplant/idle_0.json',
    'assets/images/sprites/slime/orange/idle_0.json',
    'assets/images/sprites/slime/green/idle_0.json',
  ];

  late final PlatformHelper _platformHelper;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();

    _platformHelper = widget._platformHelperFactory();

    if (!_platformHelper.isWeb) return;

    _timer = Timer(const Duration(milliseconds: 20), () {
      precacheImage(
        Image.asset('assets/images/logo_flutter_color.png').image,
        context,
      );
      precacheImage(
        Image.asset('assets/images/logo_flutter_white.png').image,
        context,
      );
      precacheImage(
        Image.asset('assets/images/shuffle_icon.png').image,
        context,
      );
      precacheImage(
        Image.asset('assets/images/timer_icon.png').image,
        context,
      );

      for (final audioControlAsset in audioControlAssets) {
        precacheImage(
          Image.asset(audioControlAsset).image,
          context,
        );
      }

      // for (final audioAsset in audioAssets) {
      //   prefetchToMemory(audioAsset);
      // }

      // // game assets
      // for (final gameImageAsset in gameImageAssets) {
      //   precacheImage(
      //     Image.asset(gameImageAsset).image,
      //     context,
      //   );
      // }

      // for (final gameDataAsset in gameDataAssets) {
      //   prefetchToMemory(gameDataAsset);
      // }
    });
  }

  /// Prefetches the given [filePath] to memory.
  Future<void> prefetchToMemory(String filePath) async {
    if (_platformHelper.isWeb) {
      // We rely on browser caching here. Once the browser downloads the file,
      // the native implementation should be able to access it from cache.
      await http.get(Uri.parse('$localAssetsPrefix$filePath'));
      return;
    }
    throw UnimplementedError(
      'The function `prefetchToMemory` is not implemented '
      'for platforms other than Web.',
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(color: Color(0xFF13B9FF)),
        colorScheme: ColorScheme.fromSwatch(
          accentColor: const Color(0xFF13B9FF),
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const PuzzlePage(),
    );
  }
}
