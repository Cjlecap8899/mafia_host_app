// lib/screens/game_logs_screen.dart

import 'package:flutter/material.dart';

import '../game_log.dart';
import '../i18n.dart';

class GameLogsScreen extends StatelessWidget {
  const GameLogsScreen({super.key});

  String _formatTime(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      final ss = dt.second.toString().padLeft(2, '0');
      return '$y-$m-$d $hh:$mm:$ss';
    } catch (_) {
      return raw;
    }
  }

  String _formatArchiveTitle(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = (dt.year % 100).toString().padLeft(2, '0');
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$d.$m.$y at $hh:$mm';
    } catch (_) {
      return raw;
    }
  }

  Widget _buildEventTile(GameLogEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        event.message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLogCard(GameLog log, {required bool isCurrent}) {
    final started = _formatTime(log.startedAt);
    final finished = log.finishedAt == null ? '—' : _formatTime(log.finishedAt!);
    final title = isCurrent
        ? 'CURRENT GAME • ${_formatArchiveTitle(log.startedAt)}'
        : _formatArchiveTitle(log.startedAt);

    return Card(
      color: Colors.black,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ExpansionTile(
        initiallyExpanded: isCurrent,
        collapsedIconColor: Colors.white70,
        iconColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          isCurrent ? 'Current game' : 'Archived game',
          style: const TextStyle(color: Colors.white70),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Started: $started',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Finished: $finished',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Players: ${log.playerCount}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Completed: ${log.completed}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Events: ${log.events.length}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          if (log.events.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'No events',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else
            ...log.events.map(_buildEventTile),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: GameLogStore.version,
      builder: (_, __, ___) {
        final current = GameLogStore.currentLog;
        final archived = GameLogStore.getArchivedLogs();

        return ValueListenableBuilder<AppLang>(
          valueListenable: I18n.lang,
          builder: (_, __, ___) {
            return Scaffold(
              backgroundColor: const Color(0xFF1A1A1A),
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () => Navigator.pop(context),
                ),
                backgroundColor: const Color(0xFF1A1A1A),
                title: const Text(
                  'GAME LOGS',
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  IconButton(
                    onPressed: () async {
                      await GameLogStore.clearAllLogs();
                    },
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.white,
                  ),
                  const LangMenuButton(),
                ],
              ),
              body: Builder(
                builder: (_) {
                  if (current == null && archived.isEmpty) {
                    return const Center(
                      child: Text(
                        'NO LOGS YET',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                        ),
                      ),
                    );
                  }

                  return ListView(
                    children: [
                      if (current != null)
                        _buildLogCard(current, isCurrent: true),
                      ...archived.map(
                        (log) => _buildLogCard(log, isCurrent: false),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}