// lib/main.dart

import 'package:flutter/material.dart';
import 'game_log.dart';
import 'i18n.dart';
import 'screens/player_count_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await I18n.load();
  await GameLogStore.ensureInitialized();
  runApp(const MafiaApp());
}

class MafiaApp extends StatefulWidget {
  const MafiaApp({super.key});

  @override
  State<MafiaApp> createState() => _MafiaAppState();
}

class _MafiaAppState extends State<MafiaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    GameLogStore.handleLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLang>(
      valueListenable: I18n.lang,
      builder: (_, __, ___) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const PlayerCountScreen(),
        );
      },
    );
  }
}