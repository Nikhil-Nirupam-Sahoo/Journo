import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ThemeController themeController = ThemeController(SettingsService());
  await themeController.load();
  runApp(JournoApp(themeController: themeController));
}

class JournoApp extends StatelessWidget {
  const JournoApp({super.key, required this.themeController});
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (BuildContext context, _) {
        return MaterialApp(
          title: 'Journo',
          theme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.light,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          themeMode: themeController.themeMode,
          home: HomePage(themeController: themeController),
        );
      },
    );
  }
}
