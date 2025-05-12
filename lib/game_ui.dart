// game_ui.dart - UI игры
import 'package:flutter/material.dart';
import 'game_logic.dart';
import 'music_player.dart';

class ClickerGame extends StatefulWidget {
  final bool isDarkTheme;
  final MusicPlayer player;

  const ClickerGame({super.key, required this.isDarkTheme, required this.player});

  @override
  State<ClickerGame> createState() => _ClickerGameState();
}

class _ClickerGameState extends State<ClickerGame> {
  final GameLogic gameLogic = GameLogic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phase \${gameLogic.currentPhase}")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Resources: \${gameLogic.resourceCount}", style: TextStyle(fontSize: 24)),
            ElevatedButton(
              onPressed: () {
                gameLogic.incrementResource();
                setState(() {});
              },
              child: Text("Click!"),
            ),
          ],
        ),
      ),
    );
  }
}
