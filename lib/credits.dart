import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clicker/music_player.dart';

class CreditsPage extends StatefulWidget {
  @override
  _CreditsPageState createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _loadTapCount();
  }

  Future<void> _loadTapCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _tapCount = prefs.getInt('tapCount') ?? 0;
      });
    } catch (e) {
      print("Ошибка загрузки счётчика: $e");
    }
  }

  Future<void> _incrementTapCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _tapCount++;
      });
      await prefs.setInt('tapCount', _tapCount);
    } catch (e) {
      print("Ошибка сохранения счётчика: $e");
    }
  }

  Widget _buildList(String title, String description, BuildContext context) {
    final player = MusicPlayer();

    return Column(
      children: [
        ListTile(
          title: Text(title),
          subtitle: Text(description),
          onTap: () async {
            player.playSoundEffect('sfx/boom.mp3');
            await _incrementTapCount();
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Credits')),
      body: ListView(
        children: [
          _buildList(
            "Ambient music",
            "Title: Remembering Past Everything\n"
                "Author: Pipe Choir\n"
                "Source: www.pipechoir.com\n"
                "License: Creative Commons Attribution 4.0 International License",
            context,
          ),
          _buildList(
            "Meme sounds",
            "Random people",
            context,
          ),
        ],
      ),
    );
  }
}
