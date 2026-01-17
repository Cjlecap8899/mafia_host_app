import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLang { rus, eng, ukr, esp }

class I18n {
  static const String _prefsKey = 'app_lang';

  static final ValueNotifier<AppLang> lang = ValueNotifier<AppLang>(AppLang.rus);

  static const Map<String, Map<AppLang, String>> _t = {
    // --- PlayerCountScreen ---
    'player_count_title': {
      AppLang.rus: 'Количество игроков',
      AppLang.eng: 'Number of players',
      AppLang.ukr: 'Кількість гравців',
      AppLang.esp: 'Número de jugadores',
    },
    'players_10': {
      AppLang.rus: '10 игроков',
      AppLang.eng: '10 players',
      AppLang.ukr: '10 гравців',
      AppLang.esp: '10 jugadores',
    },
    'players_9': {
      AppLang.rus: '9 игроков',
      AppLang.eng: '9 players',
      AppLang.ukr: '9 гравців',
      AppLang.esp: '9 jugadores',
    },
    'players_8': {
      AppLang.rus: '8 игроков',
      AppLang.eng: '8 players',
      AppLang.ukr: '8 гравців',
      AppLang.esp: '8 jugadores',
    },
    'test_5_cards': {
      AppLang.rus: 'Тест (5 карт)',
      AppLang.eng: 'Test (5 cards)',
      AppLang.ukr: 'Тест (5 карт)',
      AppLang.esp: 'Prueba (5 cartas)',
    },

    // --- Shared / RoleSelectionScreen ---
    'confirm_title': {
      AppLang.rus: 'Подтверждение',
      AppLang.eng: 'Confirmation',
      AppLang.ukr: 'Підтвердження',
      AppLang.esp: 'Confirmación',
    },
    'continue_q': {
      AppLang.rus: 'Продолжить?',
      AppLang.eng: 'Continue?',
      AppLang.ukr: 'Продовжити?',
      AppLang.esp: '¿Continuar?',
    },
    'no': {
      AppLang.rus: 'Нет',
      AppLang.eng: 'No',
      AppLang.ukr: 'Ні',
      AppLang.esp: 'No',
    },
    'yes': {
      AppLang.rus: 'Да',
      AppLang.eng: 'Yes',
      AppLang.ukr: 'Так',
      AppLang.esp: 'Sí',
    },
    'cancel': {
      AppLang.rus: 'Отмена',
      AppLang.eng: 'Cancel',
      AppLang.ukr: 'Скасувати',
      AppLang.esp: 'Cancelar',
    },

    'role_selection_title': {
      AppLang.rus: 'Раздача ролей',
      AppLang.eng: 'Role assignment',
      AppLang.ukr: 'Роздача ролей',
      AppLang.esp: 'Distribución de roles',
    },
    'exit_game_q': {
      AppLang.rus: 'Вы уверены, что хотите выйти из игры?',
      AppLang.eng: 'Are you sure you want to quit the game?',
      AppLang.ukr: 'Ви впевнені, що хочете вийти з гри?',
      AppLang.esp: '¿Estás seguro de que deseas salir del juego?',
    },
    'choose_card': {
      AppLang.rus: 'Выберите карту',
      AppLang.eng: 'Choose a card',
      AppLang.ukr: 'Виберіть картку',
      AppLang.esp: 'Seleccione una tarjeta',
    },
    'your_role': {
      AppLang.rus: 'Ваша роль:',
      AppLang.eng: 'Your role:',
      AppLang.ukr: 'Ваша роль:',
      AppLang.esp: 'Tu rol:',
    },
    'next': {
      AppLang.rus: 'Далее',
      AppLang.eng: 'Next',
      AppLang.ukr: 'Далі',
      AppLang.esp: 'Próximo',
    },
    'new_game': {
      AppLang.rus: 'Новая игра',
      AppLang.eng: 'New game',
      AppLang.ukr: 'Нова гра',
      AppLang.esp: 'Nuevo juego',
    },
    'start_over_q': {
      AppLang.rus: 'Вы уверены, что хотите начать заново?',
      AppLang.eng: 'Are you sure you want to start over?',
      AppLang.ukr: 'Ви впевнені, що хочете почати заново?',
      AppLang.esp: '¿Estás seguro que deseas empezar de nuevo?',
    },

    // --- GamePanelScreen ---
    'game_panel_title': {
      AppLang.rus: 'Панель игры',
      AppLang.eng: 'Game panel',
      AppLang.ukr: 'Панель гри',
      AppLang.esp: 'Panel de juego',
    },
    'night_phase': {
      AppLang.rus: 'Фаза ночи',
      AppLang.eng: 'Night phase',
      AppLang.ukr: 'Фаза ночі',
      AppLang.esp: 'Fase nocturna',
    },
    'votes_title': {
      AppLang.rus: 'Голоса',
      AppLang.eng: 'Votes',
      AppLang.ukr: 'Голоси',
      AppLang.esp: 'Votos',
    },
    'remove_player': {
      AppLang.rus: 'Удалить игрока',
      AppLang.eng: 'Remove player',
      AppLang.ukr: 'Видалити гравця',
      AppLang.esp: 'Eliminar jugador',
    },
    'start_over': {
      AppLang.rus: 'Начать заново',
      AppLang.eng: 'Start over',
      AppLang.ukr: 'Почати заново',
      AppLang.esp: 'Empezar de nuevo',
    },
    'exit_q_short': {
      AppLang.rus: 'Вы уверены, что хотите выйти?',
      AppLang.eng: 'Are you sure you want to quit?',
      AppLang.ukr: 'Ви впевнені, що хочете вийти?',
      AppLang.esp: '¿Estás seguro que deseas salir?',
    },
    'go_to_night_q': {
      AppLang.rus: 'Перейти к фазе ночи?',
      AppLang.eng: 'Ready to move to the night phase?',
      AppLang.ukr: 'Перейти до фази ночі?',
      AppLang.esp: '¿Pasar a la fase nocturna?',
    },
    'remove_player_q': {
      AppLang.rus: 'Удалить игрока №{n}?',
      AppLang.eng: 'Remove player №{n}?',
      AppLang.ukr: 'Видалити гравця №{n}?',
      AppLang.esp: 'Eliminar jugador №{n}?',
    },
    'votes_against_player': {
      AppLang.rus: 'Голоса против игрока {n}',
      AppLang.eng: 'Votes against the player {n}',
      AppLang.ukr: 'Голоси проти гравця {n}',
      AppLang.esp: 'Votos en contra del jugador {n}',
    },
    'victory_town': {
      AppLang.rus:
          'Стоп игра, победа мирных!\nМафия игроки номер {mafiaNums}, шериф игрок номер {sheriff}',
      AppLang.eng:
          'Game over, the civilians win!\nThe mafia players are numbers {mafiaNums}, The sheriff is player number {sheriff}',
      AppLang.ukr:
          'Стоп гра, перемога мирних!\nМафія гравці номер {mafiaNums}, шериф гравець номер {sheriff}',
      AppLang.esp:
          '¡Detengan el juego, victoria para los pacíficos!\nJugadores de la mafia {mafiaNums}, Jugador número {sheriff} del Sheriff',
    },
    'victory_mafia': {
      AppLang.rus:
          'Стоп игра, победа мафии!\nМафия игроки номер {mafiaNums}, шериф игрок номер {sheriff}',
      AppLang.eng:
          'Game over, the mafia wins!\nThe mafia players are numbers {mafiaNums}, The sheriff is player number {sheriff}',
      AppLang.ukr:
          'Стоп гра, перемога мафії!\nМафія гравці номер {mafiaNums}, шериф гравець номер {sheriff}',
      AppLang.esp:
          '¡Detén el juego, la mafia gana!\nJugadores de la mafia {mafiaNums}, Jugador número {sheriff} del Sheriff',
    },

    // --- NEW: сообщения результата дня/удаления ---
    'player_removed': {
      AppLang.rus: 'Игрок №{n} был удален',
      AppLang.eng: 'Player #{n} was removed',
      AppLang.ukr: 'Гравця №{n} було видалено',
      AppLang.esp: 'El jugador #{n} fue eliminado',
    },



    // --- Шаблоны ---
    'player_number': {
      AppLang.rus: 'Игрок №{n}',
      AppLang.eng: 'Player №{n}',
      AppLang.ukr: 'Гравець №{n}',
      AppLang.esp: 'Jugador №{n}',
    },
    'player_plain': {
      AppLang.rus: 'Игрок {n}',
      AppLang.eng: 'Player {n}',
      AppLang.ukr: 'Гравець {n}',
      AppLang.esp: 'Jugador {n}',
    },
	'night_no_victims': {
	  AppLang.rus: 'Ночь прошла без жертв',
	  AppLang.eng: 'The night passed without victims',
	  AppLang.ukr: 'Ніч минула без жертв',
	  AppLang.esp: 'La noche transcurrió sin víctimas',
	},
	'night_killed_player': {
	  AppLang.rus: 'Ночью убит игрок номер {n}',
	  AppLang.eng: 'Player number {n} was killed tonight',
	  AppLang.ukr: 'Вночі вбито гравця номер {n}',
	  AppLang.esp: 'Esta noche fue eliminado el jugador número {n}',
	},
	'night_phase_title': {
	  AppLang.rus: 'Ночная фаза',
	  AppLang.eng: 'Night phase',
	  AppLang.ukr: 'Фаза ночі',
	  AppLang.esp: 'Fase nocturna',
	},
	'day_phase': {
	  AppLang.rus: 'Фаза дня',
	  AppLang.eng: 'Day phase',
	  AppLang.ukr: 'Фаза дня',
	  AppLang.esp: 'Fase del día',
	},
	'are_you_ready': {
	  AppLang.rus: 'Вы готовы?',
	  AppLang.eng: 'Are you ready?',
	  AppLang.ukr: 'Ви готові?',
	  AppLang.esp: '¿Estás listo?',
	},
	'open_role_confirm': {
	  AppLang.rus: 'Вы уверены, что хотите открыть роль?',
	  AppLang.eng: 'Are you sure you want to open the role?',
	  AppLang.ukr: 'Ви впевнені, що бажаєте відкрити роль?',
	  AppLang.esp: '¿Estás seguro que deseas abrir el rol?',
	},
	'you_are_role': {
	  AppLang.rus: 'Вы {role}!',
	  AppLang.eng: 'You are the {role}!',
	  AppLang.ukr: 'Ви {role}!',
	  AppLang.esp: '¡Eres {role}!',
	},
	'who_to_check': {
	  AppLang.rus: 'Кого проверить?',
	  AppLang.eng: 'Who will you check?',
	  AppLang.ukr: 'Кого перевірити?',
	  AppLang.esp: '¿A quién consultar?',
	},
	'choose_player_to_shoot': {
	  AppLang.rus: 'Выберите игрока для отстрела:',
	  AppLang.eng: 'Choose a player to shoot:',
	  AppLang.ukr: 'Виберіть гравця для відстрілу:',
	  AppLang.esp: 'Selecciona un jugador para disparar:',
	},
	'who_is_sheriff': {
	  AppLang.rus: 'Кто шериф?',
	  AppLang.eng: 'Who is the sheriff?',
	  AppLang.ukr: 'Хто шериф?',
	  AppLang.esp: '¿Quién es el sheriff?',
	},
	'player_is_mafia': {
	  AppLang.rus: 'Игрок {n} - мафия',
	  AppLang.eng: 'Player {n} is mafia',
	  AppLang.ukr: 'Гравець {n} - мафія',
	  AppLang.esp: 'Jugador {n} - mafia',
	},
	'player_is_civilian': {
	  AppLang.rus: 'Игрок {n} - мирный',
	  AppLang.eng: 'Player {n} is civilian',
	  AppLang.ukr: 'Гравець {n} - мирний',
	  AppLang.esp: 'El jugador {n} es civil',
	},
	'player_is_sheriff': {
	  AppLang.rus: 'Игрок {n} - шериф',
	  AppLang.eng: 'Player {n} is the sheriff',
	  AppLang.ukr: 'Гравець {n} - шериф',
	  AppLang.esp: 'El jugador {n} es el sheriff',
	},
	'player_is_not_sheriff': {
	  AppLang.rus: 'Игрок {n} - не шериф',
	  AppLang.eng: 'Player {n} is not the sheriff',
	  AppLang.ukr: 'Гравець {n} - не шериф',
	  AppLang.esp: 'El jugador {n} no es el sheriff',
	},
	'role_citizen': {
	  AppLang.rus: 'мирный',
	  AppLang.eng: 'civilian',
	  AppLang.ukr: 'мирний',
	  AppLang.esp: 'civil',
	},
	'role_mafia': {
	  AppLang.rus: 'мафия',
	  AppLang.eng: 'mafia',
	  AppLang.ukr: 'мафія',
	  AppLang.esp: 'mafia',
	},
	'role_don': {
	  AppLang.rus: 'Дон мафии',
	  AppLang.eng: 'Mafia Don',
	  AppLang.ukr: 'Дон мафії',
	  AppLang.esp: 'Don de la mafia',
	},
	'role_sheriff': {
	  AppLang.rus: 'шериф',
	  AppLang.eng: 'sheriff',
	  AppLang.ukr: 'шериф',
	  AppLang.esp: 'alguacil',
	},
	'unknown': {
	  AppLang.rus: '???',
	  AppLang.eng: '???',
	  AppLang.ukr: '???',
	  AppLang.esp: '???',
	},

	'timer_label': {
	  AppLang.rus: 'таймер',
	  AppLang.eng: 'timer',
	  AppLang.ukr: 'таймер',
	  AppLang.esp: 'minutero',
	},
	'timer_seconds_suffix': {
	  AppLang.rus: 'сек',
	  AppLang.eng: 'sec',
	  AppLang.ukr: 'сек',
	  AppLang.esp: 's',
	},
	'tts_ten_seconds': {
	  AppLang.rus: 'десять секунд',
	  AppLang.eng: 'ten seconds',
	  AppLang.ukr: 'десять секунд',
	  AppLang.esp: 'diez segundos',
	},
	'tts_time_is_up_part1': {
	  AppLang.rus: 'и у вас врееЕ!',
	  AppLang.eng: "and your time is",
	  AppLang.ukr: 'і у вас чааас!',
	  AppLang.esp: '¡y tu tiempo se',
	},
	'tts_time_is_up_part2': {
	  AppLang.rus: 'МЯ!',
	  AppLang.eng: 'up!',
	  AppLang.ukr: 'вийшов!',
	  AppLang.esp: 'acabó!',
	},
  };

  static String tr(String key) {
    final map = _t[key];
    if (map == null) return key;
    return map[lang.value] ?? map[AppLang.rus] ?? key;
  }

  static String trVars(String key, Map<String, String> vars) {
    String s = tr(key);
    vars.forEach((k, v) {
      s = s.replaceAll('{$k}', v);
    });
    return s;
  }

  static String playerNumber(int n) => trVars('player_number', {'n': '$n'});
  static String playerPlain(int n) => trVars('player_plain', {'n': '$n'});

  // NEW: locale для flutter_tts
  static String ttsLocale(AppLang l) {
    switch (l) {
      case AppLang.rus:
        return 'ru-RU';
      case AppLang.eng:
        return 'en-US';
      case AppLang.ukr:
        return 'uk-UA';
      case AppLang.esp:
        return 'es-ES';
    }
  }

  static String ttsLocaleCurrent() => ttsLocale(lang.value);

  static String langLabel(AppLang l) {
    switch (l) {
      case AppLang.rus:
        return 'RUS';
      case AppLang.eng:
        return 'ENG';
      case AppLang.ukr:
        return 'UKR';
      case AppLang.esp:
        return 'ESP';
    }
  }

  static String _code(AppLang l) {
    switch (l) {
      case AppLang.rus:
        return 'rus';
      case AppLang.eng:
        return 'eng';
      case AppLang.ukr:
        return 'ukr';
      case AppLang.esp:
        return 'esp';
    }
  }

  static AppLang _fromCode(String? code) {
    switch (code) {
      case 'eng':
        return AppLang.eng;
      case 'ukr':
        return AppLang.ukr;
      case 'esp':
        return AppLang.esp;
      case 'rus':
      default:
        return AppLang.rus;
    }
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    lang.value = _fromCode(prefs.getString(_prefsKey));
  }

  static Future<void> setLang(AppLang newLang) async {
    lang.value = newLang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _code(newLang));
  }
}

class LangMenuButton extends StatelessWidget {
  const LangMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLang>(
      valueListenable: I18n.lang,
      builder: (_, current, __) {
        return PopupMenuButton<AppLang>(
          tooltip: 'Language',
          color: const Color(0xFF2A2A2A),
          onSelected: (v) => I18n.setLang(v),
          itemBuilder: (_) => AppLang.values
              .map(
                (l) => PopupMenuItem<AppLang>(
                  value: l,
                  child: Text(
                    I18n.langLabel(l),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
              .toList(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              I18n.langLabel(current),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
