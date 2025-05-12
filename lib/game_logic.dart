// game_logic.dart - Основная игровая логика
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class GameLogic {
  BigInt bonusResourceCount = BigInt.zero;
  BigInt resourceCount = BigInt.from(100);
  BigInt rareResourceCount = BigInt.zero;
  BigInt resourcesPerClick = BigInt.one;
  BigInt resourcesPerSecond = BigInt.zero;
  int currentPhase = 1;
  Timer? _passiveTimer;
  bool gameStarted = false;
  bool gameEnded = false;
  late DateTime startTime;
  late Duration runTime;
  bool isAbbreviated = true;

  GameLogic() {
    _loadGameData().then((_) => _startAutoGeneration());
  }

  void _startAutoGeneration() {
    _passiveTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      resourceCount += resourcesPerSecond ~/ BigInt.from(10);
      _checkPhaseTransition();
    });
  }

  void incrementResource() {
    if (!gameStarted) {
      gameStarted = true;
      startTime = DateTime.now();
    }
    resourceCount += resourcesPerClick;
    _checkPhaseTransition();
    _saveGameData();
  }

  Future<void> _saveGameData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'bonusResourceCount': bonusResourceCount.toString(),
      'rareResourceCount': rareResourceCount.toString(),
      'resourceCount': resourceCount.toString(),
      'resourcesPerClick': resourcesPerClick.toString(),
      'resourcesPerSecond': resourcesPerSecond.toString(),
      'currentPhase': currentPhase,
    };
    await prefs.setString('gameData', jsonEncode(data));
  }

  Future<void> _loadGameData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('gameData');
    if (savedData != null) {
      final data = jsonDecode(savedData);
      bonusResourceCount = BigInt.parse(data['bonusResourceCount'] ?? '0');
      rareResourceCount = BigInt.parse(data['rareResourceCount'] ?? '0');
      resourceCount = BigInt.parse(data['resourceCount'] ?? '100');
      resourcesPerClick = BigInt.parse(data['resourcesPerClick'] ?? '1');
      resourcesPerSecond = BigInt.parse(data['resourcesPerSecond'] ?? '0');
      currentPhase = data['currentPhase'] ?? 1;
    }
    isAbbreviated = prefs.getBool('isAbbreviated') ?? true;
  }

  void _checkPhaseTransition() {
    BigInt threshold = BigInt.from(10).pow(34);
    if (resourceCount >= threshold) {
      rareResourceCount += BigInt.from(1356 * pow(log(10 * currentPhase), 10));
      currentPhase++;
      resourceCount = BigInt.from(100);
    }
  }

  Future<void> resetGameData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    resourceCount = BigInt.from(100);
    resourcesPerClick = BigInt.one;
    resourcesPerSecond = BigInt.zero;
    currentPhase = 1;
  }

  // String getFormattedResources() {
  //   return ProgressFormatter.formatPhase(resourceCount, currentPhase);
  // }
}
