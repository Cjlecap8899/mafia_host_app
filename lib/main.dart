import 'package:flutter/material.dart';

import 'i18n.dart';
import 'screens/player_count_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await I18n.load();
  runApp(const MafiaApp());
}

class MafiaApp extends StatelessWidget {
  const MafiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Чтобы ВСЁ приложение обновлялось при смене языка
    return ValueListenableBuilder<AppLang>(
      valueListenable: I18n.lang,
      builder: (_, __, ___) {
        // ВАЖНО: НЕ const, иначе дерево может не обновляться
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const PlayerCountScreen(),
        );
      },
    );
  }
}
