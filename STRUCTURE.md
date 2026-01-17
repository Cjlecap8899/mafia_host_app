# Mafia 2 — структура файлов

## lib/
- lib/main.dart — точка входа (runApp), подключение экранов
- lib/game_state.dart — глобальное состояние игры (GameState, Player, Role и логика ночи)

## lib/screens/
- lib/screens/player_count_screen.dart — выбор количества игроков
- lib/screens/role_selection_screen.dart — раздача ролей
- lib/screens/game_panel_screen.dart — дневная панель игры (фолы, удаление, голоса, таймеры)
- lib/screens/night_phase_screen.dart — ночная фаза

## lib/widgets/
- lib/widgets/game_timer_button.dart — таймер 30/60 сек (кнопка с логикой)
