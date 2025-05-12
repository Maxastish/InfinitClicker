import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicPlayer {
  static final MusicPlayer _instance = MusicPlayer._internal();
  factory MusicPlayer() => _instance;

  final AudioPlayer player = AudioPlayer();
  final List<String> trackList = [
    'music/P C III - Remembering Past Everything.mp3',
    'music/P C III - 1. Brumby At Full Gallop.mp3',
    'music/P C III - 2. SlowTime.mp3',
    'music/P C III - 3. The Opening Closing.mp3',
    'music/P C III - 4. Snow Ticket.mp3',
    'music/P C III - 5. Response Data.mp3',
    'music/P C III - 6. Blue Hope New Sky.mp3',
    'music/P C III - 7. Walking The Wall.mp3',
    'music/P C III - 8. Klichi.mp3',
    'music/P C III - 9. Trampled.mp3',
    'music/P C III - 10. Decade Continue.mp3',
    'music/P C III - 11. Exit Exit.mp3',
  ];
  final Random _random = Random();
  int currentTrackIndex = 3;
  bool isMusicEnabled = true;
  bool isSoundEnabled = true;
  double musicVolume = 1.0;
  double soundVolume = 0.5;

  StreamSubscription? _playerCompleteSubscription; // Контроллер завершения трека

  MusicPlayer._internal() {
    _loadSettings();
    _shuffleTracks();
  }

  void _shuffleTracks() {
    trackList.shuffle(_random);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isMusicEnabled = prefs.getBool('isMusicEnabled') ?? true;
    isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;
    musicVolume = prefs.getDouble('musicVolume') ?? 1.0;
    soundVolume = prefs.getDouble('soundVolume') ?? 0.5;
    player.setVolume(isMusicEnabled ? musicVolume : 0.0);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMusicEnabled', isMusicEnabled);
    await prefs.setBool('isSoundEnabled', isSoundEnabled);
    await prefs.setDouble('musicVolume', musicVolume);
    await prefs.setDouble('soundVolume', soundVolume);
  }

  Future<void> playNextTrack() async {
    if (!isMusicEnabled) return;

    _playerCompleteSubscription?.cancel();

    currentTrackIndex = _random.nextInt(trackList.length);
    await player.play(AssetSource(trackList[currentTrackIndex]), volume: musicVolume);

    _playerCompleteSubscription = player.onPlayerComplete.listen((_) {
      playNextTrack();
    });
  }

  void stop() {
    player.stop();
    _playerCompleteSubscription?.cancel();
  }

  void toggleMusic(bool enabled) {
    isMusicEnabled = enabled;
    player.setVolume(enabled ? musicVolume : 0.0);
    _saveSettings();
    if (enabled) playNextTrack();
  }

  void toggleSound(bool enabled) {
    isSoundEnabled = enabled;
    _saveSettings();
  }

  void setMusicVolume(double volume) {
    musicVolume = volume;
    if (isMusicEnabled) player.setVolume(volume);
    _saveSettings();
  }

  void setSoundVolume(double volume) {
    soundVolume = volume;
    _saveSettings();
  }

  void playSoundEffect(String soundFile) {
    if (isSoundEnabled) {
      final effectPlayer = AudioPlayer();
      effectPlayer.play(AssetSource(soundFile), volume: soundVolume);
    }
  }
}