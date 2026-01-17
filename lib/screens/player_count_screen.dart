import 'package:flutter/material.dart';

import '../game_state.dart';
import '../i18n.dart';
import 'role_selection_screen.dart';

class PlayerCountScreen extends StatelessWidget {
  const PlayerCountScreen({super.key});

  void startGame(BuildContext context, int count) {
    GameState.reset(count: count);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLang>(
      valueListenable: I18n.lang,
      builder: (_, __, ___) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A1A1A),
            title: Text(
              I18n.tr('player_count_title'),
              style: const TextStyle(color: Colors.white),
            ),
            actions: const [
              LangMenuButton(),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => startGame(context, 10),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    I18n.tr('players_10'),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => startGame(context, 9),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    I18n.tr('players_9'),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => startGame(context, 8),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    I18n.tr('players_8'),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => startGame(context, 5),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    I18n.tr('test_5_cards'),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
