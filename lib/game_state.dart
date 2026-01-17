// lib/game_state.dart
import 'package:flutter/material.dart';
import 'i18n.dart';

enum Role { citizen, mafia, don, sheriff }

class Player {
  final int number;
  Role? role;
  bool isAlive = true;
  int foulCount = 0;

  Player(this.number);
}

class GameState {
  static List<Player> players = [];
  static List<Role> rolePool = [];

  static final List<int> mafiaVotes = <int>[];

  static int currentPlayerIndex = 0;
  static bool gameEnded = false;

  // UI-строка (локализуется теперь через I18n)
  static String nightResult = '';

  // ✅ Источник правды для "кто умер" (без парсинга строки)
  static int? lastVictimNumber;

  static void reset({int count = 10}) {
    final realCount = (count == 9) ? 10 : count;
    players = List.generate(realCount, (i) => Player(i + 1));

    final int mafia = count >= 9 ? 2 : 1;
    const int sheriff = 1;
    const int don = 1;
    final int citizens = count - mafia - don - sheriff;

    rolePool = <Role>[
      ...List<Role>.generate(citizens, (_) => Role.citizen),
      ...List<Role>.generate(mafia, (_) => Role.mafia),
      Role.don,
      Role.sheriff,
    ]..shuffle();

    if (count == 9 && players.length >= 10) {
      players[9].role = Role.citizen;
    }

    mafiaVotes.clear();
    currentPlayerIndex = 0;

    nightResult = '';
    lastVictimNumber = null;

    gameEnded = false;
  }

  static String getRoleLabel(Role? role) {
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
        return I18n.tr('unknown');
    }
  }



  static Color getRoleColor(Role? role) {
    if (role == Role.citizen || role == Role.sheriff) return Colors.red;
    return Colors.black;
  }

  /// Идемпотентно применяет lastVictimNumber к players.
  static void applyNightResultToPlayers() {
    final victimNumber = lastVictimNumber;
    if (victimNumber == null) return;

    final victim = players.where((p) => p.number == victimNumber).toList();
    if (victim.isEmpty) return;

    victim.first.isAlive = false;
  }

  /// Резолвит ночь БЕЗ навигации.
  static void resolveNight() {
    final Map<int, int> voteCount = <int, int>{};
    for (final v in mafiaVotes) {
      voteCount[v] = (voteCount[v] ?? 0) + 1;
    }

    final int mafiaAlive = players
        .where((p) => p.isAlive && (p.role == Role.mafia || p.role == Role.don))
        .length;

    int? victim;

    if (mafiaAlive == 3 || mafiaAlive == 2) {
      voteCount.forEach((key, value) {
        if (value == mafiaAlive) {
          victim = key;
        }
      });
    } else if (mafiaAlive == 1 && mafiaVotes.isNotEmpty) {
      victim = mafiaVotes.last;
    }

    if (victim != null) {
      lastVictimNumber = victim;
      nightResult = I18n.trVars('night_killed_player', {'n': '$victim'});
    } else {
      lastVictimNumber = null;
      nightResult = I18n.tr('night_no_victims');
    }

    applyNightResultToPlayers();
    mafiaVotes.clear();
  }
}
