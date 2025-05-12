import 'package:flutter/material.dart';

class EndGameScreen extends StatelessWidget {
  final String endMessage;
  final VoidCallback onReset;
  final Function(bool) onThemeChanged; // Добавляем toggleTheme
  final bool isDarkTheme;

  const EndGameScreen({
    Key? key,
    required this.endMessage,
    required this.onReset,
    required this.onThemeChanged,
    required this.isDarkTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Over"),
        actions: [
          Switch(
            value: isDarkTheme,
            onChanged: onThemeChanged, // Переключение темы
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                endMessage,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onReset,
                child: const Text("Reset"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
