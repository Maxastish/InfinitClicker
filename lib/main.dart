import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:clicker/music_player.dart';
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  final isDarkTheme = prefs.getBool('isDarkTheme') ?? true;

  runApp(MyApp(isDarkTheme: isDarkTheme));
}

class MyApp extends StatefulWidget {
  final bool isDarkTheme;

  const MyApp({super.key, required this.isDarkTheme});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isDarkTheme;
  late MusicPlayer player;
  bool isMusicStarted = false; // Флаг, чтобы музыка запускалась один раз

  @override
  void initState() {
    super.initState();
    isDarkTheme = widget.isDarkTheme;
    player = MusicPlayer();

    if (!isMusicStarted) {
      isMusicStarted = true;
      player.playNextTrack(); // Запускаем музыку при старте приложения
    }
  }

  void toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', value);
    setState(() {
      isDarkTheme = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinity Clicker',
      theme: isDarkTheme
          ? ThemeData(brightness: Brightness.dark)
          : ThemeData(brightness: Brightness.light),
      home: ClickerGame(
        onThemeChanged: toggleTheme,
        isDarkTheme: isDarkTheme,
        player: player, // Передаем игрока в игру
      ),
    );
  }
}
