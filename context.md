# PROJECT CONTEXT — Mafia Host Assistant

## 1. Project Overview

Mafia Host Assistant is an offline Flutter application for a host/moderator of a classic sports/tournament-style Mafia game.

The app allows the host to run the full game flow, manage the table, resolve night actions, and keep a built-in full debug game log.

The logging system is now an important part of the product:
- it records the actual history of the game,
- it helps debug night logic,
- it helps verify actions and outcomes,
- it allows post-game review.

### Core goals
- fast in-game control,
- deterministic game logic,
- simple host workflow,
- reliable full debug logging,
- readable archived game history.

---

## 2. Runtime Flow

### 2.1 App startup

`main.dart`:
- initializes Flutter bindings,
- loads saved language via `I18n.load()`,
- initializes log storage via `GameLogStore.ensureInitialized()`,
- launches the app,
- opens `PlayerCountScreen`.

### 2.2 New game setup

On `PlayerCountScreen` the host selects player count.

Then:
1. `GameLogStore.startNewGame(playerCount: ...)`
2. `GameState.reset(count: ...)`
3. navigation to `RoleSelectionScreen`

Important:
- a new current log is created before role distribution begins,
- if an older current log exists, it is archived automatically with:
  - `Game ended: new game started`

---

## 3. Core Game Flow

The normal game flow is:

1. **PlayerCountScreen**
   - choose player count
   - start a new game

2. **RoleSelectionScreen**
   - players take cards
   - the app assigns roles
   - every received card is written to the debug log

3. **GamePanelScreen**
   - this is the main daytime control screen
   - host can nominate players
   - host can remove a player
   - host can start night
   - host can process night result
   - host can detect victory / end game

4. **NightPhaseScreen**
   - players perform their night actions one by one
   - mafia shoots
   - don shoots and checks
   - sheriff checks
   - citizens solve a task
   - after all players finish, the app resolves the night

5. **GameLogsScreen**
   - view current game log
   - view archived logs
   - clear logs

---

## 4. Core Logic

## 4.1 `GameState` — source of truth

`GameState` is the main source of truth for the game.

It stores:
- `players`
- `rolePool`
- `mafiaVotes`
- `currentPlayerIndex`
- `selectedPlayerCount`
- `nightResult`
- `lastVictimNumber`
- `gameEnded`
- `nightNumber`
- `dayNumber`

### `dayNumber` / `nightNumber` rules
- `Day 1` starts immediately when the game reaches `GamePanelScreen`
- `Night 1` is the first night phase
- after resolving `Night 1`, the game moves to `Day 2`
- after resolving `Night 2`, the game moves to `Day 3`
- and so on without any fixed limit

### Important values
- `lastVictimNumber` is the source of truth for who died at night
- `nightResult` is the UI message shown after the night
- `mafiaVotes` stores all mafia-side shots for current night resolution

---

## 4.2 Night resolution

`GameState.resolveNight()`:
- counts mafia-side shots,
- determines whether there is a victim,
- writes `lastVictimNumber`,
- builds `nightResult`,
- applies the victim to players,
- clears `mafiaVotes`,
- increments:
  - `nightNumber`
  - `dayNumber`

---

## 5. Game Logging System

## 5.1 Purpose

The logging system is used to:
- reconstruct full game history,
- debug night kill inconsistencies,
- verify player actions,
- verify game outcome,
- inspect archived games after they end.

This is now a **full debug log**.

That means the log may contain:
- roles,
- received cards,
- night actions,
- checks,
- outcomes,
- victory result.

Important:
- this is intentional,
- hidden roles are allowed in logs,
- logs are meant for post-game debug/review.

---

## 5.2 Architecture

Logs are split into two layers:

### Current Game Log
- active game
- updated in real time
- saved after every event

### Archived Logs
- completed games
- maximum 10 logs
- FIFO behavior
- oldest logs are removed when limit is exceeded

---

## 5.3 Storage Model

Stored in `SharedPreferences`:

- `mafia_current_game_log_v1`
- `mafia_archived_game_logs_v1`

---

## 5.4 Lifecycle of a Log

### Start game
`GameLogStore.startNewGame(...)`
- archives previous current game if needed
- creates new current log
- writes:
  - `New game started with N players`

### During game
`GameLogStore.logEvent(...)`
- appends the event
- persists immediately

### End game
`GameLogStore.finishCurrentGame(...)`
- appends final event
- marks log completed
- sets finish time
- moves log to archive
- clears current log

Examples of final messages:
- `Game ended: town victory`
- `Game ended: mafia victory`
- `Game ended: app closed`
- `Game ended: new game started`

### App lifecycle
`main.dart` passes lifecycle state into `GameLogStore.handleLifecycleState(...)`

Current behavior:
- lifecycle is used mainly to save snapshot,
- lifecycle noise is not intentionally added as visible gameplay history.

---

## 5.5 Current Logging Philosophy

The game log should contain only **important gameplay events**.

### Good log entries
- `New game started with 10 players`
- `Player 1 received card 2 (Citizen)`
- `Day 1: Player 4 (Mafia) was nominated for voting`
- `Day 1: Player 4 (Mafia) was removed`
- `Night 1: Player 7 (Mafia) shot Player 3 (Citizen)`
- `Night 1: Player 8 (Don) shot Player 3 (Citizen) and checked Player 5 (Sheriff)`
- `Night 1: Player 2 (Sheriff) checked Player 8 (Don)`
- `Night 1: Player 10 (Citizen) solved the task`
- `Night 1 result: Player 3 (Citizen) was killed`
- `Game ended: town victory`

### Bad / unwanted log entries
Avoid noisy UI/debug-only events like:
- dialog opened
- dialog confirmed
- timer started
- timer expired
- panel opened
- transition started
- role opened
- generic technical state changes

The log should read like a human-readable history of the match.

---

## 6. Screen-by-Screen Behavior

## 6.1 `PlayerCountScreen`
Purpose:
- choose player count
- start a new game
- open logs screen

Behavior:
- calls `GameLogStore.startNewGame(...)`
- calls `GameState.reset(...)`
- navigates to `RoleSelectionScreen`

Important:
- this is the actual entry point for every new match

---

## 6.2 `RoleSelectionScreen`
Purpose:
- distribute roles/cards to players

Behavior:
- each player confirms and reveals role flow
- chosen card is assigned to the player
- role image is displayed
- proceeds to next player
- after the last player, opens `GamePanelScreen`

Logging:
- logs card assignment in full debug format:
  - `Player X received card Y (Role)`

Important:
- in 9-player mode, special player 10 is a forced citizen
- this also must be reflected correctly in debug logic/logs

Also handles:
- ending game if app is closed during role selection
- ending game as `Game ended: new game started` if reset is triggered here

---

## 6.3 `GamePanelScreen`
Purpose:
- main daytime control screen

Behavior:
- host sees alive players
- host can:
  - nominate players for voting
  - remove a player manually
  - move to night phase
  - process night result
  - detect and finalize victory
  - reset into a new game

Logging responsibilities:
- nomination:
  - `Day N: Player X (Role) was nominated for voting`
- removal:
  - `Day N: Player X (Role) was removed`
- end game:
  - `Game ended: town victory`
  - `Game ended: mafia victory`
  - `Game ended: new game started`
  - `Game ended: app closed`

Important:
- `Day 1` starts here immediately after role distribution
- after each resolved night, the next visit is next day number

---

## 6.4 `NightPhaseScreen`
Purpose:
- run all night actions in order

Behavior:
- processes alive players one by one
- skips dead players
- each role performs its night action

### Role actions

#### Citizen
- receives a math task
- may solve it or fail to solve it

Logging:
- `Night N: Player X (Citizen) solved the task`
- `Night N: Player X (Citizen) failed to solve the task`

#### Mafia
- chooses one target to shoot

Logging:
- `Night N: Player X (Mafia) shot Player Y (Role)`
- if no shot happened:
  - `Night N: Player X (Mafia) made no shot`

#### Don
- chooses one target to shoot
- chooses one target to check

Logging:
- `Night N: Player X (Don) shot Player Y (Role) and checked Player Z (Role)`
- partial fallback cases may also be logged if needed

#### Sheriff
- chooses one target to check

Logging:
- `Night N: Player X (Sheriff) checked Player Y (Role)`

### Special 9-player mode logic
There is special player 10 logic in 9-player mode.

This logic must remain consistent with:
- game rules,
- forced citizen setup,
- mafiaVotes behavior,
- debug log output.

### End of night
When all players finish:
- `GameState.resolveNight()` is called
- a result log is written:
  - `Night N result: Player X (Role) was killed`
  - or
  - `Night N result: No one was killed`

Then navigation returns to `GamePanelScreen`.

---

## 6.5 `GameLogsScreen`
Purpose:
- display current and archived logs

Behavior:
- reads from `GameLogStore`
- does not write logs
- can clear all logs

UI rules:
- intentionally in English
- intentionally simple
- shows log history as readable event lines

Archive title format:
- `dd.MM.yy at HH:mm`
- example:
  - `17.03.26 at 18:58`

Current feedback direction:
- per-event time is not required in visible list
- expandable details are not required for normal viewing
- emphasis is on readable match history

---

## 6.6 `GameTimerButton`
Purpose:
- day timers for host convenience

Behavior:
- independent utility widget
- not part of core game state
- not part of critical gameplay log

---

## 7. Project File Structure

```text
lib/
│   game_log.dart
│   game_state.dart
│   i18n.dart
│   main.dart
│
├───screens
│       game_logs_screen.dart
│       game_panel_screen.dart
│       night_phase_screen.dart
│       player_count_screen.dart
│       role_selection_screen.dart
│
├───tool
│       find_hardcoded_ru.dart
│
└───widgets
        game_timer_button.dart
8. File Responsibilities
lib/game_log.dart 🔥 CRITICAL

Logging system.

Responsible for:

current game log

archived logs

persistence to SharedPreferences

log creation

log finalization

archive trimming

notifying UI via ValueNotifier

Important:

max archived logs = 10

saves after each event

final archive happens through finishCurrentGame(...)

lib/game_state.dart 🔥 CRITICAL

Core game logic and source of truth.

Responsible for:

player list

role pool

mafia votes

current player index during night

night/day counters

night resolution

last victim tracking

game reset

Important:

resolveNight() is one of the most important functions in the app

lib/i18n.dart

Localization system.

Responsible for:

current language

localized UI strings

ValueListenable for current language

helper translations

Important:

gameplay UI uses i18n

logs screen intentionally remains English-oriented

lib/main.dart

App bootstrap and lifecycle wiring.

Responsible for:

WidgetsFlutterBinding.ensureInitialized()

I18n.load()

GameLogStore.ensureInitialized()

attaching lifecycle observer

launching root widget

lib/screens/player_count_screen.dart

Start screen.

Responsible for:

selecting player count

opening logs

starting new game correctly

Important:

this file must always call:

GameLogStore.startNewGame(...)

GameState.reset(...)

in this order.

lib/screens/role_selection_screen.dart

Role/card distribution screen.

Responsible for:

player-by-player role reveal

card selection

moving to next player

entering day panel after distribution

Important:

writes full debug card assignment logs

handles early game ending if app closes here

handles reset/new-game path from this screen

lib/screens/game_panel_screen.dart

Main day phase screen.

Responsible for:

alive player overview

nominations

removals

moving to night

processing night result

victory detection

manual reset/new game

Important:

writes Day N gameplay logs

finishes game with correct final message

lib/screens/night_phase_screen.dart

Night phase engine screen.

Responsible for:

iterating through players

citizen task

mafia shot

don shot + check

sheriff check

special 9-player mode logic

night-to-day transition

Important:

writes Night N gameplay logs

writes readable role-aware full debug history

lib/screens/game_logs_screen.dart

Logs viewer screen.

Responsible for:

reading current log

reading archived logs

rendering archive names

clearing logs

Important:

should stay simple

should remain readable

should not contain log-writing logic

lib/tool/find_hardcoded_ru.dart

Utility tool for development.

Responsible for:

helping detect hardcoded Russian strings in the project

Important:

developer helper only

not part of gameplay runtime

lib/widgets/game_timer_button.dart

Reusable timer widget.

Responsible for:

simple countdown button/timer behavior on day screen

Important:

utility UI element

not a core game engine file

9. Important Cross-File Dependencies

main.dart → GameLogStore

app startup

lifecycle save

player_count_screen.dart → GameLogStore + GameState

new game creation

role_selection_screen.dart → GameState + GameLogStore

card assignment

role distribution logs

game_panel_screen.dart → GameState + GameLogStore

day actions

end-game logic

night_phase_screen.dart → GameState + GameLogStore

night actions

night result flow

game_logs_screen.dart ← GameLogStore

read-only viewer

10. Critical Constraints

logs must be saved immediately after each important event

current log must not be lost on:

new game

app close

end game

max archived logs = 10

current game is stored separately from archives

log content should stay readable and useful

avoid noisy technical UI logs

roles/cards are allowed in logs because this is now full debug mode

11. Current Logging Rules
Always log

game start

card assignment

nominations

removals

night role actions

night result

game end reason/result

Avoid logging

dialog opens

button confirmations

timer start

timer expire as standalone UI noise

generic navigation state changes

non-gameplay technical events unless truly needed for debugging

12. Known Design Decisions
Full debug logs are intentional

Logs now may contain:

exact roles

exact cards

exact targets

exact checks

exact outcomes

This is allowed because:

logs are for post-game review/debug,

this improves bug investigation,

this helps verify host flow,

this makes archived logs actually useful.

Logs are part of product behavior now

The log is no longer just a low-level debug trace.
It is now a readable match history.

13. Developer Notes for Future Changes

When changing game logic, always check whether logging must also be updated.

Especially review logs when changing:

role distribution

mafiaVotes behavior

night resolution

day voting flow

removal flow

victory conditions

special player 10 behavior

app-close / reset flows

First place to inspect when a bug appears

Open GameLogsScreen.

If night logic breaks, inspect:

mafia shots

don actions

sheriff checks

citizen task result

Night N result

mafiaVotes

lastVictimNumber

If adding a new gameplay mechanic

Ask:

Does it affect GameState?

Does it affect end-game conditions?

Does it need a readable log entry?

Should it appear as Day N or Night N event?

14. Current Expected Log Style

Example target history:

New game started with 10 players

Player 1 received card 2 (Citizen)

Player 2 received card 5 (Sheriff)

Day 1: Player 4 (Mafia) was nominated for voting

Day 1: Player 4 (Mafia) was removed

Night 1: Player 7 (Mafia) shot Player 3 (Citizen)

Night 1: Player 8 (Don) shot Player 3 (Citizen) and checked Player 5 (Sheriff)

Night 1: Player 2 (Sheriff) checked Player 8 (Don)

Night 1: Player 10 (Citizen) solved the task

Night 1 result: Player 3 (Citizen) was killed

Game ended: town victory

This is the style future logging should follow.