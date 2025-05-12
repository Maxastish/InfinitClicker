import 'package:clicker/music_player.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) onSwitchChanged;
  final Function onReset;
  final Function(bool) onThemeChanged;
  final bool isDarkTheme;

  const SettingsPage({
    Key? key,
    required this.onSwitchChanged,
    required this.onReset,
    required this.onThemeChanged,
    required this.isDarkTheme,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isAbbreviated = true;

  bool isMusicEnabled = true;
  bool isSoundEnabled = true;
  double musicVolume = 1.0;
  double soundVolume = 1.0;

  final player = MusicPlayer();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAbbreviated = prefs.getBool('isAbbreviated') ?? true;

      isMusicEnabled = prefs.getBool('isMusicEnabled') ?? true;
      isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;
      musicVolume = prefs.getDouble('musicVolume') ?? 1.0;
      soundVolume = prefs.getDouble('soundVolume') ?? 1.0;
    });
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMusicEnabled', isMusicEnabled);
    await prefs.setBool('isSoundEnabled', isSoundEnabled);
    await prefs.setDouble('musicVolume', musicVolume);
    await prefs.setDouble('soundVolume', soundVolume);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SwitchListTile(
              title: const Text('Enable Music'),
              value: isMusicEnabled,
              onChanged: (bool value) {
                player.playSoundEffect('sfx/switch.wav');
                setState(() {
                  isMusicEnabled = value;
                  player.toggleMusic(value);
                });
                _saveSettings();
              },
            ),
            Slider(
              value: musicVolume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: "${(musicVolume * 100).toInt()}%",
              onChanged: (double value) {
                player.playSoundEffect('sfx/switch.wav');
                setState(() {
                  musicVolume = value;
                  player.setMusicVolume(value);
                });
                _saveSettings();
              },
            ),
            SwitchListTile(
              title: const Text('Enable Sound Effects'),
              value: isSoundEnabled,
              onChanged: (bool value) {
                player.playSoundEffect('sfx/switch.wav');
                setState(() {
                  isSoundEnabled = value;
                  player.toggleSound(value);
                });
                _saveSettings();
              },
            ),
            Slider(
              value: soundVolume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: "${(soundVolume * 100).toInt()}%",
              onChanged: (double value) {
                player.playSoundEffect('sfx/switch.wav');
                setState(() {
                  soundVolume = value;
                  player.setSoundVolume(value);
                });
                _saveSettings();
              },
            ),
            SwitchListTile(
              title: const Text('Display abbreviated numbers'),
              value: isAbbreviated,
              onChanged: (bool value) {
                widget.onSwitchChanged(value);
                player.playSoundEffect('sfx/_show-numbers.mp3');
                setState(() {
                  isAbbreviated = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Dark Theme'),
              value: widget.isDarkTheme,
              onChanged: (bool value) {
                player.playSoundEffect('sfx/switch.wav');
                widget.onThemeChanged(value);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                player.playSoundEffect('sfx/boom.mp3');
                widget.onReset(); // Сброс данных
                Navigator.pop(context);
              },
              child: const Text("Reset Game Data"),
            ),
          ],
        ),
      ),
    );
  }
}
