import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';

import '../i18n.dart';

class GameTimerButton extends StatefulWidget {
  final int initialSeconds;
  final Key? key;

  const GameTimerButton({required this.initialSeconds, this.key})
      : super(key: key);

  @override
  State<GameTimerButton> createState() => GameTimerButtonState();
}

class GameTimerButtonState extends State<GameTimerButton> {
  late int countdown;
  Timer? timer;
  bool isRunning = false;
  DateTime? lastTap;

  final FlutterTts tts = FlutterTts();
  VoidCallback? _langListener;

  bool saidTenSeconds = false;
  bool saidFinalPhrase = false;
  bool vibratedAt10 = false;
  bool vibratedAtEnd = false;

  @override
  void initState() {
    super.initState();
    countdown = widget.initialSeconds;

    _initTts();

    _langListener = () async {
      await _applyTtsLanguage(I18n.lang.value);
      if (mounted) setState(() {});
    };
    I18n.lang.addListener(_langListener!);
  }

  Future<void> _initTts() async {
    // Ключевое: просим движок разрешить await окончания речи
    await tts.awaitSpeakCompletion(true);

    await tts.setSpeechRate(0.5);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);

    await _applyTtsLanguage(I18n.lang.value);
  }

  Future<void> _applyTtsLanguage(AppLang lang) async {
    final String desired = switch (lang) {
      AppLang.rus => 'ru-RU',
      AppLang.eng => 'en-US',
      AppLang.ukr => 'uk-UA',
      AppLang.esp => 'es-ES',
    };

    // Здесь НЕ делаем stop() — иначе можно оборвать текущую речь
    try {
      final List<dynamic>? langs = await tts.getLanguages;
      final bool supported = langs != null && langs.contains(desired);
      await tts.setLanguage(supported ? desired : 'en-US');
    } catch (_) {
      await tts.setLanguage(desired);
    }
  }

  Future<void> _speakQueued(String text) async {
    try {
      // Добавляем в очередь (не flush), чтобы не резать предыдущую фразу
      await tts.setQueueMode(1); // add
      await tts.speak(text);
      // speak вернётся быстро, но awaitSpeakCompletion(true) делает так,
      // что следующий await speak() будет ждать завершения.
    } catch (_) {
      // молча: если TTS снова глючит, таймер должен продолжать работать
    }
  }

  void startTimer() {
    timer?.cancel();

    saidTenSeconds = false;
    saidFinalPhrase = false;
    vibratedAt10 = false;
    vibratedAtEnd = false;

    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (countdown == 12 && !saidTenSeconds) {
        saidTenSeconds = true;
        await _speakQueued(I18n.tr('tts_ten_seconds'));
      }

      if (countdown == 10 && !vibratedAt10) {
        vibratedAt10 = true;
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 200]);
        }
      }

      if (countdown == 3 && !saidFinalPhrase) {
        saidFinalPhrase = true;

        // Важно: говорим строго последовательно в очередь
        await _speakQueued(I18n.tr('tts_time_is_up_part1'));
        await _speakQueued(I18n.tr('tts_time_is_up_part2'));
      }

      if (countdown <= 1) {
        if (!vibratedAtEnd && (await Vibration.hasVibrator() ?? false)) {
          vibratedAtEnd = true;
          Vibration.vibrate(duration: 600);
        }

        stopTimer();
        setState(() => countdown = widget.initialSeconds);
      } else {
        setState(() => countdown--);
      }
    });

    setState(() => isRunning = true);
  }

  void pauseTimer() {
    timer?.cancel();
    timer = null;
    setState(() => isRunning = false);
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
    setState(() => isRunning = false);
  }

  void handleTap() {
    final now = DateTime.now();
    if (lastTap != null &&
        now.difference(lastTap!) < const Duration(milliseconds: 400)) {
      stopTimer();
      setState(() => countdown = widget.initialSeconds);
    } else {
      if (!isRunning && countdown == widget.initialSeconds) {
        startTimer();
      } else if (isRunning) {
        pauseTimer();
      } else {
        startTimer();
      }
    }
    lastTap = now;
  }

  @override
  void dispose() {
    timer?.cancel();
    tts.stop();
    if (_langListener != null) {
      I18n.lang.removeListener(_langListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isRunning ? Colors.deepPurple : Colors.black;

    return ElevatedButton(
      onPressed: handleTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Column(
        children: [
          Text(I18n.tr('timer_label'), style: const TextStyle(fontSize: 14)),
          Text(
            '$countdown ${I18n.tr('timer_seconds_suffix')}',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
