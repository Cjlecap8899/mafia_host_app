// lib/game_log.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameLogEvent {
  final int seq;
  final String time;
  final String type;
  final String message;
  final Map<String, dynamic> data;

  GameLogEvent({
    required this.seq,
    required this.time,
    required this.type,
    required this.message,
    Map<String, dynamic>? data,
  }) : data = data ?? <String, dynamic>{};

  Map<String, dynamic> toJson() => <String, dynamic>{
        'seq': seq,
        'time': time,
        'type': type,
        'message': message,
        'data': data,
      };

  factory GameLogEvent.fromJson(Map<String, dynamic> json) {
    return GameLogEvent(
      seq: json['seq'] as int? ?? 0,
      time: json['time'] as String? ?? '',
      type: json['type'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: Map<String, dynamic>.from(
        json['data'] as Map? ?? <String, dynamic>{},
      ),
    );
  }
}

class GameLog {
  final String id;
  final String startedAt;
  String? finishedAt;
  final int playerCount;
  final List<GameLogEvent> events;
  bool completed;

  GameLog({
    required this.id,
    required this.startedAt,
    required this.playerCount,
    List<GameLogEvent>? events,
    this.finishedAt,
    this.completed = false,
  }) : events = events ?? <GameLogEvent>[];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'startedAt': startedAt,
        'finishedAt': finishedAt,
        'playerCount': playerCount,
        'completed': completed,
        'events': events.map((e) => e.toJson()).toList(),
      };

  factory GameLog.fromJson(Map<String, dynamic> json) {
    return GameLog(
      id: json['id'] as String? ?? '',
      startedAt: json['startedAt'] as String? ?? '',
      finishedAt: json['finishedAt'] as String?,
      playerCount: json['playerCount'] as int? ?? 10,
      completed: json['completed'] as bool? ?? false,
      events: (json['events'] as List? ?? <dynamic>[])
          .map(
            (e) => GameLogEvent.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }
}

class GameLogStore {
  static const String _currentLogKey = 'mafia_current_game_log_v1';
  static const String _archivedLogsKey = 'mafia_archived_game_logs_v1';
  static const int _maxArchivedLogs = 10;

  static final ValueNotifier<int> version = ValueNotifier<int>(0);

  static GameLog? _currentLog;
  static List<GameLog> _archivedLogs = <GameLog>[];

  static bool _initialized = false;
  static bool _persistInProgress = false;
  static bool _persistRequestedAgain = false;

  static GameLog? get currentLog => _currentLog;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();

    final currentRaw = prefs.getString(_currentLogKey);
    if (currentRaw != null && currentRaw.isNotEmpty) {
      try {
        _currentLog = GameLog.fromJson(
          Map<String, dynamic>.from(jsonDecode(currentRaw) as Map),
        );
      } catch (_) {
        _currentLog = null;
      }
    }

    final archivedRaw = prefs.getString(_archivedLogsKey);
    if (archivedRaw != null && archivedRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(archivedRaw) as List<dynamic>;
        _archivedLogs = decoded
            .map(
              (e) => GameLog.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      } catch (_) {
        _archivedLogs = <GameLog>[];
      }
    }

    _archivedLogs.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    _trimArchived();

    _initialized = true;
    _notifyChanged();
  }

  static void startNewGame({required int playerCount}) {
    _ensureReadySync();

    if (_currentLog != null) {
      _archiveCurrentGameSync(
        resultMessage: 'Game ended: new game started',
        extraData: <String, dynamic>{
          'reason': 'new_game_started',
        },
      );
    }

    final now = DateTime.now().toIso8601String();

    _currentLog = GameLog(
      id: now,
      startedAt: now,
      playerCount: playerCount,
      completed: false,
    );

    _appendEvent(
      type: 'game_started',
      message: 'New game started with $playerCount players',
      data: <String, dynamic>{
        'playerCount': playerCount,
      },
      notify: false,
    );

    _notifyChanged();
    _requestPersist();
  }

  static void logEvent({
    required String type,
    required String message,
    Map<String, dynamic>? data,
  }) {
    _ensureReadySync();
    if (_currentLog == null) return;

    _appendEvent(
      type: type,
      message: message,
      data: data ?? <String, dynamic>{},
      notify: true,
    );

    _requestPersist();
  }

  static void saveCurrentSnapshot() {
    _ensureReadySync();
    _requestPersist();
  }

  static Future<void> archiveCurrentGame({
    String? resultMessage,
    Map<String, dynamic>? extraData,
  }) async {
    _ensureReadySync();

    final changed = _archiveCurrentGameSync(
      resultMessage: resultMessage,
      extraData: extraData,
    );

    if (!changed) return;

    await _persistNow();
  }

  static Future<void> finishCurrentGame({
    String? resultMessage,
    Map<String, dynamic>? extraData,
  }) async {
    await archiveCurrentGame(
      resultMessage: resultMessage,
      extraData: extraData,
    );
  }

  static List<GameLog> getArchivedLogs() {
    _ensureReadySync();
    return List<GameLog>.from(_archivedLogs);
  }

  static Future<void> clearAllLogs() async {
    _ensureReadySync();

    _currentLog = null;
    _archivedLogs = <GameLog>[];

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentLogKey);
    await prefs.remove(_archivedLogsKey);

    _notifyChanged();
  }

  static void handleLifecycleState(AppLifecycleState state) {
    _ensureReadySync();

    switch (state) {
      case AppLifecycleState.resumed:
        return;
      case AppLifecycleState.inactive:
        saveCurrentSnapshot();
        return;
      case AppLifecycleState.hidden:
        saveCurrentSnapshot();
        return;
      case AppLifecycleState.paused:
        saveCurrentSnapshot();
        return;
      case AppLifecycleState.detached:
        saveCurrentSnapshot();
        return;
    }
  }

  static void _appendEvent({
    required String type,
    required String message,
    required Map<String, dynamic> data,
    required bool notify,
  }) {
    final log = _currentLog;
    if (log == null) return;

    log.events.add(
      GameLogEvent(
        seq: log.events.length + 1,
        time: DateTime.now().toIso8601String(),
        type: type,
        message: message,
        data: data,
      ),
    );

    if (notify) {
      _notifyChanged();
    }
  }

  static bool _archiveCurrentGameSync({
    String? resultMessage,
    Map<String, dynamic>? extraData,
  }) {
    final log = _currentLog;
    if (log == null) return false;

    if (resultMessage != null && resultMessage.isNotEmpty) {
      log.events.add(
        GameLogEvent(
          seq: log.events.length + 1,
          time: DateTime.now().toIso8601String(),
          type: 'game_ended',
          message: resultMessage,
          data: extraData ?? <String, dynamic>{},
        ),
      );
    }

    log.finishedAt = DateTime.now().toIso8601String();
    log.completed = true;

    _archivedLogs.removeWhere((item) => item.id == log.id);
    _archivedLogs.insert(0, log);
    _trimArchived();

    _currentLog = null;

    _notifyChanged();
    return true;
  }

  static void _trimArchived() {
    while (_archivedLogs.length > _maxArchivedLogs) {
      _archivedLogs.removeLast();
    }
  }

  static void _ensureReadySync() {
    if (_initialized) return;
  }

  static void _notifyChanged() {
    version.value++;
  }

  static void _requestPersist() {
    if (_persistInProgress) {
      _persistRequestedAgain = true;
      return;
    }

    unawaited(_persistNow());
  }

  static Future<void> _persistNow() async {
    if (_persistInProgress) {
      _persistRequestedAgain = true;
      return;
    }

    _persistInProgress = true;

    try {
      do {
        _persistRequestedAgain = false;

        final prefs = await SharedPreferences.getInstance();

        if (_currentLog == null) {
          await prefs.remove(_currentLogKey);
        } else {
          await prefs.setString(
            _currentLogKey,
            jsonEncode(_currentLog!.toJson()),
          );
        }

        await prefs.setString(
          _archivedLogsKey,
          jsonEncode(_archivedLogs.map((e) => e.toJson()).toList()),
        );
      } while (_persistRequestedAgain);
    } finally {
      _persistInProgress = false;
    }
  }
}