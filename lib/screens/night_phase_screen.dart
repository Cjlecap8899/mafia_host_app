import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game_state.dart';
import '../i18n.dart';
import 'game_panel_screen.dart';

class NightPhaseScreen extends StatefulWidget {
  const NightPhaseScreen({super.key});

  @override
  State<NightPhaseScreen> createState() => _NightPhaseScreenState();
}

class _NightPhaseScreenState extends State<NightPhaseScreen> {
  Timer? _timer;
  int secondsLeft = 15;
  Player? currentPlayer;
  bool showActionUI = false;
  String inputAnswer = '';
  String mathQuestion = '';
  int correctAnswer = 0;
  String? roleResult;
  bool donChecked = false;
  bool mafiaShot = false;
  bool finishedAll = false;
  Color resultColor = Colors.black;

  @override
  void initState() {
    super.initState();
    nextPlayer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ---------- Helpers ----------

  String _roleLabel(Role? role) {
    switch (role) {
      case Role.citizen:
        return I18n.tr('role_citizen');
      case Role.mafia:
        return I18n.tr('role_mafia');
      case Role.don:
        return I18n.tr('role_don');
      case Role.sheriff:
        return I18n.tr('role_sheriff');
      default:
        return '???';
    }
  }

  Future<bool?> _showExitDialog() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          I18n.tr('confirm_title'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          I18n.tr('exit_game_confirm'),
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

  Future<bool?> _showOpenRoleDialog() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          I18n.tr('confirm_title'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          I18n.tr('open_role_confirm'),
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

  // ---------- Night logic ----------

  void nextPlayer() {
    if (GameState.currentPlayerIndex >= GameState.players.length) {
      setState(() => finishedAll = true);
      return;
    }

    currentPlayer = GameState.players[GameState.currentPlayerIndex];

    if (!(currentPlayer?.isAlive ?? false)) {
      GameState.currentPlayerIndex++;
      nextPlayer();
      return;
    }

    generateMathTask();

    setState(() {
      showActionUI = false;
      inputAnswer = '';
      roleResult = null;
      resultColor = Colors.black;
      donChecked = false;
      mafiaShot = false;
    });
  }

  void generateMathTask() {
    final rand = Random();
    int a = rand.nextInt(20) + 1;
    int b = rand.nextInt(20) + 1;

    if (rand.nextBool()) {
      mathQuestion = '$a + $b = ?';
      correctAnswer = a + b;
    } else {
      if (a < b) {
        final temp = a;
        a = b;
        b = temp;
      }
      mathQuestion = '$a - $b = ?';
      correctAnswer = a - b;
    }
  }

  void startTimer() {
    secondsLeft = 15;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => secondsLeft--);
      if (secondsLeft <= 0) {
        timer.cancel();
        GameState.currentPlayerIndex++;
        nextPlayer();
      }
    });
  }

  void submitAction() {
    _timer?.cancel();
    GameState.currentPlayerIndex++;
    nextPlayer();
  }

  void goToDayPhase() {
    GameState.resolveNight();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GamePanelScreen()),
    );
  }

  Widget buildResultBox(String text, Color background) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text.toUpperCase(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLang>(
      valueListenable: I18n.lang,
      builder: (_, __, ___) {
        return WillPopScope(
          onWillPop: () async {
            final shouldExit = await _showExitDialog();
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
                I18n.tr('night_phase_title'),
                style: const TextStyle(color: Colors.white),
              ),
              actions: const [
                LangMenuButton(),
                SizedBox(width: 8),
              ],
            ),
            body: finishedAll ? _buildDayPhaseButton() : _buildNightPhaseContent(),
          ),
        );
      },
    );
  }

  Widget _buildDayPhaseButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        onPressed: goToDayPhase,
        child: Text(
          I18n.tr('day_phase'),
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }

  Widget _buildNightPhaseContent() {
    if (currentPlayer == null) return const SizedBox.shrink();

    final role = currentPlayer!.role;
    final alivePlayers = GameState.players.where((p) => p.isAlive).toList();

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!showActionUI) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  I18n.tr('are_you_ready'),
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image.asset('assets/images/roles/card.png'),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: SizedBox(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        I18n.playerNumber(currentPlayer!.number),
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 3,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final confirm = await _showOpenRoleDialog();
                            if (confirm == true) {
                              setState(() => showActionUI = true);
                              startTimer();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              if (!(role == Role.mafia && mafiaShot))
                Text(
                  I18n.trVars('you_are_role', {'role': _roleLabel(role)}),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: GameState.getRoleColor(role),
                    shadows: const [
                      Shadow(
                        color: Colors.white,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                '$secondsLeft',
                style: const TextStyle(
                  fontSize: 44,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (role == Role.citizen) ...[
                Text(
                  mathQuestion,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.red,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: TextField(
                    onChanged: (val) => setState(() => inputAnswer = val),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: int.tryParse(inputAnswer) == correctAnswer ? submitAction : null,
                  child: Text(
                    I18n.tr('next'),
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ] else if (role == Role.sheriff) ...[
                if (roleResult == null) ...[
                  Text(
                    I18n.tr('who_to_check'),
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.red,
                    ),
                  ),
                  Wrap(
                    children: alivePlayers
                        .map(
                          (p) => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              final isMafia = p.role == Role.mafia || p.role == Role.don;

                              setState(() {
                                roleResult = isMafia
                                    ? I18n.trVars('player_is_mafia', {'n': '${p.number}'})
                                    : I18n.trVars('player_is_civilian', {'n': '${p.number}'});
                                resultColor = isMafia ? Colors.black : Colors.red;
                              });
                            },
                            child: Text(
                              I18n.playerNumber(p.number),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ] else ...[
                  buildResultBox(roleResult!, resultColor),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: submitAction,
                    child: Text(
                      I18n.tr('next'),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ],
              ] else if (role == Role.don) ...[
                if (!mafiaShot) ...[
                  Text(
                    I18n.tr('choose_player_to_shoot'),
                    style: const TextStyle(fontSize: 22, color: Colors.red),
                  ),
                  Wrap(
                    children: alivePlayers
                        .map(
                          (p) => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              GameState.mafiaVotes.add(p.number);
                              setState(() => mafiaShot = true);
                            },
                            child: Text(
                              I18n.playerNumber(p.number),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ] else if (!donChecked) ...[
                  Text(
                    I18n.tr('who_is_sheriff'),
                    style: const TextStyle(fontSize: 22, color: Colors.red),
                  ),
                  Wrap(
                    children: alivePlayers
                        .map(
                          (p) => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              final isSheriff = p.role == Role.sheriff;

                              setState(() {
                                roleResult = isSheriff
                                    ? I18n.trVars('player_is_sheriff', {'n': '${p.number}'})
                                    : I18n.trVars('player_is_not_sheriff', {'n': '${p.number}'});
                                resultColor = isSheriff ? Colors.red : Colors.black;
                                donChecked = true;
                              });
                            },
                            child: Text(
                              I18n.playerNumber(p.number),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ] else if (roleResult != null) ...[
                  buildResultBox(roleResult!, resultColor),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: submitAction,
                    child: Text(
                      I18n.tr('next'),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ],
              ] else if (role == Role.mafia) ...[
                if (!mafiaShot) ...[
                  Text(
                    I18n.tr('choose_player_to_shoot'),
                    style: const TextStyle(fontSize: 22, color: Colors.red),
                  ),
                  Wrap(
                    children: alivePlayers
                        .map(
                          (p) => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              GameState.mafiaVotes.add(p.number);
                              setState(() => mafiaShot = true);
                            },
                            child: Text(
                              I18n.playerNumber(p.number),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (mafiaShot)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: submitAction,
                    child: Text(
                      I18n.tr('next'),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
