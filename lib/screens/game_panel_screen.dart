import 'package:flutter/material.dart';

import '../game_state.dart';
import '../i18n.dart';
import 'player_count_screen.dart';
import 'night_phase_screen.dart';
import '../widgets/game_timer_button.dart';

class GamePanelScreen extends StatefulWidget {
  const GamePanelScreen({super.key});

  @override
  State<GamePanelScreen> createState() => _GamePanelScreenState();
}

class _GamePanelScreenState extends State<GamePanelScreen> {
  bool showNightResult = GameState.nightResult.isNotEmpty;
  bool showVictory = false;
  bool dialogShown = false;
  String victoryMessage = '';
  Color victoryColor = Colors.black;

  final GlobalKey<GameTimerButtonState> _timerKey30 = GlobalKey();
  final GlobalKey<GameTimerButtonState> _timerKey60 = GlobalKey();

  // --- Голосование (только живые игроки) ---
  final List<int> _activeOrder = <int>[];
  final Map<int, int?> _votes = <int, int?>{};

  @override
  void initState() {
    super.initState();
    GameState.applyNightResultToPlayers();
  }

  // ---------- Диалоги ----------

  Future<bool?> _showExitDialog() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(I18n.tr('confirm_title'),
            style: const TextStyle(color: Colors.white)),
        content: Text(I18n.tr('exit_q_short'),
            style: const TextStyle(color: Colors.white)),
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

  Future<bool?> _showResetDialog() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(I18n.tr('confirm_title'),
            style: const TextStyle(color: Colors.white)),
        content: Text(I18n.tr('start_over_q'),
            style: const TextStyle(color: Colors.white)),
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
  }

  Future<bool?> _showNightPhaseDialog() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(I18n.tr('confirm_title'),
            style: const TextStyle(color: Colors.white)),
        content: Text(I18n.tr('go_to_night_q'),
            style: const TextStyle(color: Colors.white)),
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
  }

  Future<int?> _showVotesPicker({required int playerNumber}) {
    final int aliveCount = GameState.players.where((p) => p.isAlive).length;
    final int maxVotes = aliveCount.clamp(1, 10);

    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          I18n.trVars('votes_against_player', {'n': '$playerNumber'}),
          style: const TextStyle(color: Colors.white),
        ),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(maxVotes, (i) {
            final v = i + 1;
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, v),
              child: Text('$v', style: const TextStyle(fontSize: 18)),
            );
          }),
        ),
      ),
    );
  }

  // ---------- Логика игры ----------

  void deletePlayer() async {
    setState(() => dialogShown = true);
  
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          I18n.tr('remove_player'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Wrap(
          children: GameState.players
              .where((p) => p.isAlive)
              .map(
                (p) => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: const Color(0xFF2A2A2A),
                        title: Text(
                          I18n.tr('confirm_title'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        content: Text(
                          I18n.trVars('remove_player_q', {'n': '${p.number}'}),
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
  
                    if (confirm == true) {
                      setState(() {
                        p.isAlive = false;
  
                        GameState.lastVictimNumber = p.number;
  
                        // ✅ ЛОКАЛИЗОВАННАЯ строка
                        GameState.nightResult =
                            I18n.trVars('player_removed', {'n': '${p.number}'});
  
                        showNightResult = true;
                      });
                    }
  
                    Navigator.pop(context);
                  },
                  child: Text(I18n.playerPlain(p.number)),
                ),
              )
              .toList(),
        ),
      ),
    );
  
    setState(() => dialogShown = false);
  }


  void proceedToNight() {
    _timerKey30.currentState?.stopTimer();
    _timerKey60.currentState?.stopTimer();

    setState(() {
      _activeOrder.clear();
      _votes.clear();
    });

    GameState.currentPlayerIndex = 0;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => NightPhaseScreen()),
    );
  }

  void processNightResult() {
    setState(() {
      showNightResult = false;

      GameState.applyNightResultToPlayers();

      _sanitizeVoteState();
    });

    final mafiaCount = GameState.players
        .where((p) => p.isAlive && (p.role == Role.mafia || p.role == Role.don))
        .length;

    final townCount = GameState.players
        .where((p) =>
            p.isAlive && (p.role == Role.citizen || p.role == Role.sheriff))
        .length;

    final mafiaNums = GameState.players
        .where((p) => p.role == Role.mafia || p.role == Role.don)
        .map((p) => p.number)
        .join(', ');

    final sheriff =
        GameState.players.firstWhere((p) => p.role == Role.sheriff).number;

    if (mafiaCount == 0) {
      setState(() {
        victoryMessage = I18n.trVars('victory_town', {
          'mafiaNums': mafiaNums,
          'sheriff': '$sheriff',
        });
        victoryColor = Colors.red;
        showVictory = true;
      });
    } else if (mafiaCount >= townCount) {
      setState(() {
        victoryMessage = I18n.trVars('victory_mafia', {
          'mafiaNums': mafiaNums,
          'sheriff': '$sheriff',
        });
        victoryColor = Colors.white;
        showVictory = true;
      });
    }
  }

  void resetGame() async {
    setState(() => dialogShown = true);
    final confirmed = await _showResetDialog();
    setState(() => dialogShown = false);

    if (confirmed == true) {
      GameState.reset();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PlayerCountScreen()),
        (route) => false,
      );
    }
  }

  void handleFoul(int number, {required bool remove}) {
    setState(() {
      final player = GameState.players.firstWhere((p) => p.number == number);
      if (remove) {
        if (player.foulCount > 0) player.foulCount--;
      } else {
        if (player.foulCount < 3) player.foulCount++;
      }
    });
  }

  // ---------- Голосование: только живые игроки ----------

  List<int> _aliveNumbers() {
    final alive = GameState.players
        .where((p) => p.isAlive)
        .map((p) => p.number)
        .toList()
      ..sort();
    return alive;
  }

  void _sanitizeVoteState() {
    final aliveSet = _aliveNumbers().toSet();
    _activeOrder.removeWhere((n) => !aliveSet.contains(n));
    _votes.removeWhere((key, value) => !aliveSet.contains(key));
  }

  List<int> _currentOrder() {
    final alive = _aliveNumbers();
    final activeAlive = _activeOrder.where((n) => alive.contains(n)).toList();
    final inactiveAlive = alive.where((n) => !activeAlive.contains(n)).toList();
    return [...activeAlive, ...inactiveAlive];
  }

  bool _isActive(int n) => _activeOrder.contains(n);

  String _labelFor(int n) {
    final v = _votes[n];
    if (v == null) return '$n';
    return '$n - $v';
  }

  void _onTapVoteButton(int n) async {
    final aliveSet = _aliveNumbers().toSet();
    if (!aliveSet.contains(n)) return;

    if (!_isActive(n)) {
      setState(() {
        _activeOrder.add(n);
        _votes[n] = null;
      });
      return;
    }

    final picked = await _showVotesPicker(playerNumber: n);
    if (picked == null) return;

    setState(() {
      _votes[n] = picked;
    });
  }

  void _onDoubleTapVoteButton(int n) {
    if (!_isActive(n)) return;

    setState(() {
      _activeOrder.remove(n);
      _votes.remove(n);
    });
  }

  Widget _buildVoteButtonsPanel() {
    _sanitizeVoteState();

    final alive = _aliveNumbers();
    if (alive.isEmpty) return const SizedBox.shrink();

    final order = _currentOrder();

    Widget buildBtn(int n) {
      final active = _isActive(n);
      final bg = active ? Colors.deepPurple : Colors.black;

      return GestureDetector(
        onTap: () => _onTapVoteButton(n),
        onDoubleTap: () => _onDoubleTapVoteButton(n),
        child: Container(
          margin: const EdgeInsets.all(6),
          width: 72,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _labelFor(n),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final List<int> topRow;
    if (_activeOrder.isEmpty) {
      topRow = [alive.first];
    } else {
      topRow = _activeOrder.where((n) => alive.contains(n)).take(3).toList();
      if (topRow.isEmpty) {
        topRow.add(alive.first);
      }
    }

    final rest = order.where((x) => !topRow.contains(x)).toList();

    final List<List<int>> rows = [];
    for (int i = 0; i < rest.length; i += 3) {
      rows.add(rest.skip(i).take(3).toList());
    }

    Widget buildTopRow() {
      if (topRow.length == 1) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 72 + 12),
            buildBtn(topRow.first),
            const SizedBox(width: 72 + 12),
          ],
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: topRow.map(buildBtn).toList(),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          I18n.tr('votes_title'),
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 8),
        buildTopRow(),
        ...rows.map(
          (r) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: r.map(buildBtn).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final hideMainUI = showNightResult || showVictory;

    return ValueListenableBuilder<AppLang>(
      valueListenable: I18n.lang,
      builder: (_, __, ___) {
        return WillPopScope(
          onWillPop: () async {
            if (dialogShown) return false;
            dialogShown = true;

            final shouldExit = await _showExitDialog();

            dialogShown = false;
            return shouldExit ?? false;
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: const Color(0xFF1A1A1A),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Text(
                I18n.tr('game_panel_title'),
                style: const TextStyle(color: Colors.white),
              ),
              actions: const [
                LangMenuButton(),
              ],
            ),
            body: _buildBody(context, hideMainUI),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, bool hideMainUI) {
    return Stack(
      children: [
        if (!hideMainUI)
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Wrap(
                        children: GameState.players
                            .where((p) => p.isAlive)
                            .map(
                              (p) => GestureDetector(
                                onTap: () =>
                                    handleFoul(p.number, remove: false),
                                onDoubleTap: () =>
                                    handleFoul(p.number, remove: true),
                                child: Card(
                                  color: Colors.grey[900],
                                  child: Container(
                                    width: 80,
                                    padding: const EdgeInsets.all(12.0),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 18),
                                        children: [
                                          TextSpan(
                                            text: '${p.number}',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          if (p.foulCount > 0)
                                            TextSpan(
                                              text: ' ${'!' * p.foulCount}',
                                              style: const TextStyle(
                                                  color: Colors.red),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: deletePlayer,
                        child: Text(
                          I18n.tr('remove_player'),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      _buildVoteButtonsPanel(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),

        if (showVictory) ...[
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: Text(
                victoryMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: victoryColor,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 14),
              ),
              onPressed: resetGame,
              child: Text(I18n.tr('start_over')),
            ),
          ),
        ],

        if (showNightResult)
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                textStyle: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              onPressed: processNightResult,
              child: Text(GameState.nightResult),
            ),
          ),

        if (!hideMainUI)
          Positioned(
            bottom: 90,
            left: 20,
            child: Row(
              children: [
                GameTimerButton(key: _timerKey30, initialSeconds: 30),
                const SizedBox(width: 10),
                GameTimerButton(key: _timerKey60, initialSeconds: 60),
              ],
            ),
          ),

        if (!hideMainUI)
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 14),
              ),
              onPressed: resetGame,
              child: Text(I18n.tr('new_game')),
            ),
          ),

        if (!hideMainUI)
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 14),
              ),
              onPressed: () async {
                setState(() => dialogShown = true);
                final confirm = await _showNightPhaseDialog();
                setState(() => dialogShown = false);
                if (confirm == true) proceedToNight();
              },
              child: Text(I18n.tr('night_phase')),
            ),
          ),

        if (dialogShown)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: Container(color: Colors.transparent),
            ),
          ),
      ],
    );
  }
}
