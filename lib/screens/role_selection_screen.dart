import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game_state.dart';
import '../i18n.dart';
import 'game_panel_screen.dart';
import 'player_count_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  int currentPlayer = 1;
  bool showCards = false;
  int? selectedCardIndex;
  bool roleRevealed = false;

  bool get isLastAutoAssigned =>
      GameState.players.length == 10 &&
      currentPlayer == 10 &&
      GameState.players[9].role == Role.citizen;

  Future<bool?> _confirmReveal() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          I18n.tr('confirm_title'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          I18n.tr('continue_q'),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(I18n.tr('no')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(I18n.tr('yes')),
          ),
        ],
      ),
    );
  }

  Future<void> onPlayerTap() async {
    if (isLastAutoAssigned) {
      final confirm = await _confirmReveal();
      if (confirm != true) return;

      setState(() => roleRevealed = true);
      return;
    }

    if (GameState.rolePool.length == 1) {
      final confirm = await _confirmReveal();
      if (confirm != true) return;

      final player = GameState.players[currentPlayer - 1];
      player.role = GameState.rolePool.first;
      GameState.rolePool.removeAt(0);

      setState(() => roleRevealed = true);
      return;
    }

    final confirm = await _confirmReveal();
    if (confirm != true) return;

    setState(() => showCards = true);
  }

  void selectCard(int index) {
    final player = GameState.players[currentPlayer - 1];
    player.role = GameState.rolePool[index];
    selectedCardIndex = index;

    setState(() => roleRevealed = true);
  }

  void proceedToNext() {
    if (selectedCardIndex != null &&
        GameState.rolePool.length > selectedCardIndex!) {
      GameState.rolePool.removeAt(selectedCardIndex!);
    }

    setState(() {
      selectedCardIndex = null;
      roleRevealed = false;
      showCards = false;

      if (currentPlayer < GameState.players.length) {
        currentPlayer++;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const GamePanelScreen(),
          ),
        );
      }
    });
  }

  Future<void> confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(I18n.tr('confirm_title')),
        content: Text(I18n.tr('start_over_q')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(I18n.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(I18n.tr('yes')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PlayerCountScreen()),
        (route) => false,
      );
    }
  }

  List<Widget> buildCardRows() {
    final List<Widget> rows = [];
    final List<int> indexes =
        List<int>.generate(GameState.rolePool.length, (i) => i);

    final List<List<int>> layout = <List<int>>[
      indexes.take(3).toList(),
      indexes.skip(3).take(3).toList(),
      indexes.skip(6).take(3).toList(),
      indexes.skip(9).toList(),
    ];

    for (final row in layout) {
      if (row.isEmpty) continue;

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row
              .map(
                (i) => GestureDetector(
                  onTap: () => selectCard(i),
                  child: Container(
                    width: 90,
                    height: 140,
                    margin: const EdgeInsets.all(6),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/roles/background.png',
                          fit: BoxFit.cover,
                        ),
                        Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final player = GameState.players[currentPlayer - 1];

    return ValueListenableBuilder<AppLang>(
      valueListenable: I18n.lang,
      builder: (_, __, ___) {
        return WillPopScope(
          onWillPop: () async {
            final shouldExit = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: const Color(0xFF2A2A2A),
                title: Text(
                  I18n.tr('confirm_title'),
                  style: const TextStyle(color: Colors.white),
                ),
                content: Text(
                  I18n.tr('exit_game_q'),
                  style: const TextStyle(color: Colors.white),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(I18n.tr('no')),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(I18n.tr('yes')),
                  ),
                ],
              ),
            );

            if (shouldExit == true) {
              SystemNavigator.pop();
            }

            return false;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFF1A1A1A),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Text(
                I18n.tr('role_selection_title'),
                style: const TextStyle(color: Colors.white),
              ),
              actions: const [
                LangMenuButton(),
              ],
            ),
            body: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!showCards && !roleRevealed)
                        GestureDetector(
                          onTap: onPlayerTap,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.6,
                            margin: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage('assets/images/roles/card.png'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.bottomCenter,
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              I18n.playerNumber(currentPlayer),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (showCards && !roleRevealed && GameState.rolePool.length > 1) ...[
                        Text(
                          I18n.tr('choose_card'),
                          style: const TextStyle(fontSize: 22, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        ...buildCardRows(),
                      ],
                      if (roleRevealed) ...[
                        const SizedBox(height: 10),
                        Text(
                          I18n.tr('your_role'),
                          style: const TextStyle(fontSize: 22, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          padding: const EdgeInsets.all(16.0),
                          child: Image.asset(
                            'assets/images/roles/${player.role.toString().split('.').last}.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: proceedToNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                          child: Text(
                            I18n.tr('next'),
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: confirmReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                    child: Text(I18n.tr('new_game')),
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
