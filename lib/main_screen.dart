import 'package:clicker/auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:clicker/ArcPainter.dart';
import 'settings.dart';
import 'package:clicker/cheatShop.dart';
import 'package:clicker/shop.dart';
import 'package:clicker/credits.dart';
import 'package:clicker/endGameScreen.dart';
import 'package:clicker/achievements.dart';
import 'package:clicker/leaderboard.dart';
import 'package:clicker/music_player.dart';

class ClickerGame extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkTheme;
  final MusicPlayer player; // Получаем player из MyApp

  const ClickerGame({
    super.key,
    required this.onThemeChanged,
    required this.isDarkTheme,
    required this.player, // Получаем player через конструктор
  });

  @override
  State<ClickerGame> createState() => _ClickerGameState();
}

class _ClickerGameState extends State<ClickerGame> {
  BigInt bonusResourceCount = BigInt.zero;
  BigInt bonusClickIncrease = BigInt.one;
  BigInt bonusPassiveIncrease = BigInt.one;
  BigInt resourceCount = BigInt.from(100);
  BigInt rareResourceCount =
      BigInt.zero; // Начальное количество редких ресурсов
  BigInt resourcesPerClick = BigInt.one;
  BigInt resourcesPerSecond = BigInt.zero;
  int currentPhase = 1; // Текущая фаза
  Timer? _passiveTimer;
  Timer? _longPressTimer;

  bool gameStarted = false;
  late DateTime startTime;
  late Duration runTime;

  bool isAbbreviated = true;
  bool _showSecretButton = false;

  String formatDurationWithDays(Duration d) {
    return "${d.inDays} days "
        "${d.inHours.toString().padLeft(2, '0')}:"
        "${(d.inMinutes % 60).toString().padLeft(2, '0')}:"
        "${(d.inSeconds % 60).toString().padLeft(2, '0')}:"
        "${(d.inMilliseconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    widget.player.playNextTrack();
    _loadGameData().then((_) {
      _startAutoGeneration();
      _checkTapCount();
    });
  }

  Future<void> _checkTapCount() async {
    final prefs = await SharedPreferences.getInstance();
    int tapCount = prefs.getInt('tapCount') ?? 0;

    if (tapCount >= 10) {
      setState(() {
        _showSecretButton = true;
        SnackBar(
          content: Text("Developer Mode Unlocked, restart the game"),
        );
      });
    }
  }

  @override
  void dispose() {
    _passiveTimer?.cancel();
    _longPressTimer?.cancel();
    super.dispose();
  }

  void _startAutoGeneration() {
    _passiveTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        resourceCount += BigInt.from(
            (resourcesPerSecond * bonusPassiveIncrease) / BigInt.from(10));
        _checkPhaseTransition();
      });
    });
  }

  void _incrementResource() {
    setState(() {
      _checkPhaseTransition();
      if (currentPhase != 9) {
        resourceCount += resourcesPerClick * bonusClickIncrease;
      } else {
        resourceCount += BigInt.one;
      }
    });
  }

  Future<void> _saveGameData() async {
    if (!gameStarted) {
      gameStarted = true;
      startTime = DateTime.now();
    }

    final prefs = await SharedPreferences.getInstance();
    final data = {
      'bonusResourceCount': bonusResourceCount.toString(),
      'bonusClickIncrease': bonusClickIncrease.toString(),
      'bonusPassiveIncrease': bonusPassiveIncrease.toString(),
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
      bonusClickIncrease = BigInt.parse(data['bonusClickIncrease'] ?? '1');
      bonusPassiveIncrease = BigInt.parse(data['bonusPassiveIncrease'] ?? '1');
      rareResourceCount = BigInt.parse(data['rareResourceCount'] ?? '0');
      resourceCount = BigInt.parse(data['resourceCount'] ?? '0');
      resourcesPerClick = BigInt.parse(data['resourcesPerClick'] ?? '1');
      resourcesPerSecond = BigInt.parse(data['resourcesPerSecond'] ?? '0');
      currentPhase = data['currentPhase'] ?? 1;
    }

    setState(() {
      isAbbreviated =
          prefs.getBool('isAbbreviated') ?? true; // По умолчанию true
    });
  }

  // Метод для обновления баланса основных ресурсов
  void _updateResourceCount(BigInt newCount) {
    setState(() {
      resourceCount = newCount;
    });
  }

  // Метод для обновления баланса редких ресурсов
  void _updateRareResourceCount(BigInt newCount) {
    setState(() {
      rareResourceCount = newCount;
    });
  }

  void _updateResourcePerClick(BigInt newCount) {
    setState(() {
      resourcesPerClick = newCount;
    });
  }

  void _updateResourcePerSecond(BigInt newCount) {
    setState(() {
      resourcesPerSecond = newCount;
    });
  }

  void _updateBonusResource(BigInt newCount) {
    setState(() {
      bonusResourceCount = newCount;
    });
  }

  void _updateBonusClick(BigInt newCount) {
    setState(() {
      bonusClickIncrease = newCount;
    });
  }

  void _updateBonusPassive(BigInt newCount) {
    setState(() {
      bonusPassiveIncrease = newCount;
    });
  }

  String formatResourceCount(BigInt value) {
    // Массив функций для обработки каждой фазы
    final phaseFormatters = [
      _formatPhase1,
      _formatPhase2,
      _formatPhase3,
      _formatPhase4,
      _formatPhase5,
      _formatPhase6,
      _formatPhase7,
      _formatPhase8,
      _formatPhase9,
      _formatPhase10,
      _formatPhase11,
      _formatPhase12,
      _formatPhase13,
      _formatPhase14,
      _formatPhase15,
      _formatPhase16,
      _formatPhase17,
      _formatPhase18,
      _formatPhase19,
      _formatPhase20,
      _formatPhase21,
      _formatPhase22,
      _formatPhase23,
      _formatPhase24,
      _formatPhase25,
      _formatPhase26,
      _formatPhase27,
      _formatPhase28,
      _formatPhase29,
      _formatPhase30,
      _formatPhase31,
      _formatPhase32,
      _formatPhase33,
      _formatPhase34,
      _formatPhase35,
    ];

    // Проверяем, что текущая фаза в допустимых пределах
    if (currentPhase >= 1 && currentPhase <= phaseFormatters.length) {
      return phaseFormatters[currentPhase - 1](
          value); // Вызов соответствующей функции
    }
    currentPhase = 1;
    return value.toString(); // Для фаз за пределами диапазона
  }

  late final phaseData = [
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 1 100
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 2 10^100
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 3 10^10^100
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 4 3↑↑↑100
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 5 4↑↑↑100
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 6 5↑↑↑100
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 7 100↑↑↑100
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 8 g100
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10)
    }, // Фаза 9 ∞
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 10 "ω+100";  [φ (1, 1) = ω ^ 1]
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 11 "ω*100
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 12 "ω^100
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 13
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 14
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 15
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 16
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 17
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 18
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 19
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 20
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 21
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 22
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 23
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 24
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 25
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 26
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 27
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 28
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 29
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 30
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 31
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 32
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 33
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.from(10).pow(34)
    }, // Фаза 34
    {
      'resourcesPerClick': BigInt.one,
      'resourcesPerSecond': BigInt.zero,
      'resourceCount': BigInt.zero,
      'threshold': BigInt.one,
    }, // Фаза 35

    // Добавить данные для других фаз
  ];

  void _showCenteredSnackbar() {
    print('Minecraft/_$currentPhase.mp3');
    widget.player.playSoundEffect('Minecraft/_$currentPhase.mp3');

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black26,
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.isDarkTheme ? Colors.white70 : Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Congratulations!",
                    style: TextStyle(
                      color:
                          widget.isDarkTheme ? Colors.black87 : Colors.white70,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    currentPhase != 9
                        ? "Phase $currentPhase!"
                        : "Unlocked next phase: MORE THAN INFINITY!!!",
                    style: TextStyle(
                      color:
                          widget.isDarkTheme ? Colors.black87 : Colors.white70,
                      fontSize: 28,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Убираем через 2 секунды
    Future.delayed(Duration(seconds: currentPhase != 9 ? 3 : 5), () {
      overlayEntry.remove();
    });
  }

  Future<void> _saveSpecialUpgrades() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'specialUpgrades',
        jsonEncode({
          'bonusResourceCount': bonusResourceCount.toString(),
          'bonusClickIncrease': bonusClickIncrease.toString(),
          'bonusPassiveIncrease': bonusPassiveIncrease.toString(),
        }));
  }

  void _checkPhaseTransition() {
    if (currentPhase < phaseData.length &&
        resourceCount >=
            (phaseData[currentPhase - 1]['threshold'] ?? BigInt.zero)) {
      setState(() {
        rareResourceCount += BigInt.from(
            1356 * pow(log(10 * ((currentPhase - 1) / 4 + 1.1)) / log(10), 10));
        _saveSpecialUpgrades();
        currentPhase++;

        // Проверяем наличие данных в phaseData
        if (currentPhase - 1 < phaseData.length) {
          resourceCount =
              phaseData[currentPhase - 1]['resourceCount'] ?? BigInt.zero;
          resourcesPerClick =
              phaseData[currentPhase - 1]['resourcesPerClick'] ?? BigInt.zero;
          resourcesPerSecond =
              phaseData[currentPhase - 1]['resourcesPerSecond'] ?? BigInt.zero;
        }
      });

      if (currentPhase != 9) {
        resourceCount += bonusResourceCount;
      }

      // Показываем всплывающее сообщение
      if (currentPhase < phaseData.length) {
        _showCenteredSnackbar();
      }
      // else{
      //   widget.player.playSoundEffect('Minecraft/_$currentPhase.mp3');
      // }
    }
  }

  final units = [
    "",
    "K",
    "M",
    "B",
    "T",
    "Qa",
    "Qi",
    "Sx",
    "Sp",
    "Oc",
    "No",
    "lim→∞"
  ];

  String formate_symbols(BigInt value, int symbol_num) {
    // Список символов для форматирования
    final symbols = ['↑', 'ω ^ ', 'ε ^ ', 'φ( ', 'Ω ^ ', 'Ξ( '];

    // Если значение меньше 50, то просто формируем строку с символами
    if (value < BigInt.from(15)) {
      int intValue = value.toInt(); // Безопасное преобразование в int
      return List.filled(intValue, symbols[symbol_num]).join();
    }

    // Индекс для работы с числами
    int index = -1;
    while (value >= BigInt.from(1000) && index < symbols.length - 1) {
      value ~/= BigInt.from(1000);
      index++;
    }

    // Убедимся, что индекс не выходит за границы массива
    if (index < 0 || index >= symbols.length) {
      index =
          0; // Возвращаемся к первому элементу, если индекс выходит за пределы
    }

    // Форматируем строку в зависимости от флага isAbbreviated
    if (isAbbreviated) {
      return "$value${units[index]}${symbols[symbol_num]}";
    }
    return "$value${symbols[symbol_num]}";
  }

  String formate_data(BigInt value) {
    if (value < BigInt.from(1000)) return value.toString();

    if (isAbbreviated) {
      int index = -1;
      while (value >= BigInt.from(1000) && index < units.length - 1) {
        value ~/= BigInt.from(1000);
        index++;
      }
      return "$value ${units[index + 1]}";
    }
    return value.toString();
  }

  String formate_indexes(BigInt value) {
    String input = value.toString();
    const subscriptDigits = ['₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'];
    return input.split('').map((char) {
      final index = int.tryParse(char);
      return index != null ? subscriptDigits[index] : char;
    }).join();
  }

  String _formatPhase1(BigInt value) {
    return formate_data(value);
  }

  String _formatPhase2(BigInt value) {
    return "10 ^ ${formate_data(value)}";
  }

  String _formatPhase3(BigInt value) {
    return "10 ^ 10 ^ ${formate_data(value)}";
  }

  String _formatPhase4(BigInt value) {
    return "3↑↑↑${formate_data(value)}";
  }

  String _formatPhase5(BigInt value) {
    return "4↑↑↑${formate_data(value)}";
  }

  String _formatPhase6(BigInt value) {
    return "5↑↑↑${formate_data(value)}";
  }

  String _formatPhase7(BigInt value) {
    return "${formate_data(value)}↑↑↑${formate_data(value)}";
  }

  String _formatPhase8(BigInt value) {
    return "g${formate_data(value)}"; // Числа G
  }

  String _formatPhase9(BigInt value) {
    // "∞\n${formate_data(BigInt.from(1000) - value)} clicks left until overcoming infinity!!!"
    return "∞?";
  }

  String _formatPhase10(BigInt value) {
    return "ω + ${formate_data(value)}"; // Ординалы Омега
  }

  String _formatPhase11(BigInt value) {
    return "ω * ${formate_data(value)}"; // Ординалы Омега
  }

  String _formatPhase12(BigInt value) {
    return "ω ^ ${formate_data(value)}"; // Ординалы Омега
  }

  String _formatPhase13(BigInt value) {
    return "ω ${formate_symbols(value, 0)}ω"; // Ординалы Омега
  }

  String _formatPhase14(BigInt value) {
    return "ε₀ + ${formate_data(value)}";
  }

  String _formatPhase15(BigInt value) {
    return "ω ^ ε₀ *${formate_data(value)}";
  }

  String _formatPhase16(BigInt value) {
    return "ω ${formate_symbols(value, 0)}ε₀+1";
  }

  String _formatPhase17(BigInt value) {
    return "ε₁ + ${formate_data(value)}";
  }

  String _formatPhase18(BigInt value) {
    return "ω ${formate_symbols(value, 0)}ε₁+1";
  }

  String _formatPhase19(BigInt value) {
    return "ω ^ ε₁ *${formate_data(value)}";
  }

  String _formatPhase20(BigInt value) {
    return "ε${formate_indexes(value)}";
  }

  String _formatPhase21(BigInt value) {
    return "ε${formate_symbols(value, 2)}ω";
  }

  String _formatPhase22(BigInt value) {
    return "ζ₀ + ${formate_data(value)}";
  }

  String _formatPhase23(BigInt value) {
    return "ε₀ ^ ζ₀ * ${formate_data(value)}";
  }

  String _formatPhase24(BigInt value) {
    return "${formate_symbols(value, 2)}ζ₀ + 1";
  }

  String _formatPhase25(BigInt value) {
    return "φ (${formate_data(value)}, 1)";
  }

  String _formatPhase26(BigInt value) {
    return "${formate_symbols(value, 3)}...";
  }

  String _formatPhase27(BigInt value) {
    return "φ(${formate_data(value)}, ..., 0, 0)";
  }

  String _formatPhase28(BigInt value) {
    return "Ξ(1, ${formate_data(value)}) = ω${formate_indexes(value + BigInt.one)} ^ (CK)";
  }

  String _formatPhase29(BigInt value) {
    return "Ξ(2, ${formate_data(value)}) = ε${formate_indexes(value + BigInt.one)} ^ (CK)";
  }

  String _formatPhase30(BigInt value) {
    return "Ξ(3, ${formate_data(value)}) = ζ${formate_indexes(value + BigInt.one)} ^ (CK)";
  }

  String _formatPhase31(BigInt value) {
    return "Ξ(${formate_data(value)}, 0) = Ψ${formate_symbols(value, 4)}Ω)₁^(CK)";
  }

  String _formatPhase32(BigInt value) {
    return "Ξ(1, 0, ${formate_data(value)})";
  }

  String _formatPhase33(BigInt value) {
    return "Ξ(1, 0, ${formate_symbols(value, 5)}...";
  }

  String _formatPhase34(BigInt value) {
    return "Ξ(${formate_symbols(value, 4)}Ω)";
  }

  String _formatPhase35(BigInt value) {
    if (gameStarted) {
      gameStarted = false;
      runTime = DateTime.now().difference(startTime);

      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) saveCompletionTime(user, runTime);
      });

      _resetGameData();
    }

    // Переход на новый экран
    Future.delayed(Duration.zero, () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EndGameScreen(
            endMessage:
                "Here's the end of the game now.\nCongratulations!!!\nYour Time: ${formatDurationWithDays(runTime)}",
            onReset: () {
              _resetGameData();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ClickerGame(
                    onThemeChanged: widget.onThemeChanged,
                    isDarkTheme: widget.isDarkTheme,
                    player: widget.player,
                  ),
                ),
              );
            },
            onThemeChanged: widget.onThemeChanged,
            isDarkTheme: widget.isDarkTheme,
          ),
        ),
      );
    });

    return ""; // Возвращаем пустую строку, так как текст будет отображаться на новом экране.
  }

  Future<void> _resetGameData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Очистка всех сохраненных данных
    setState(() {
      resourceCount = BigInt.from(100);
      resourcesPerClick = BigInt.one;
      resourcesPerSecond = BigInt.zero;
      currentPhase = 1;
      gameStarted = false;
      rareResourceCount = BigInt.zero;

      // resourceCount = BigInt.zero;
      // resourcesPerClick = BigInt.one;
      // resourcesPerSecond  = BigInt.one;
      // currentPhase = 13;

      // resourceCount = BigInt.from(10).pow(30);
      // resourcesPerClick = BigInt.from(10).pow(30);
      // resourcesPerSecond  = BigInt.from(10).pow(30);
      // currentPhase = 23;
      // rareResourceCount = BigInt.from(9999);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final player = MusicPlayer();

    // Функция для быстрого возведения BigInt в степень (алгоритм "возведение в степень по быстрому возведению")
    BigInt bigIntPow(BigInt base, int exponent) {
      BigInt result = BigInt.one;
      while (exponent > 0) {
        if (exponent % 2 == 1) {
          result *= base;
        }
        base *= base;
        exponent ~/= 2;
      }
      return result;
    }

    double calculateProgress(BigInt value) {
      // Определяем индекс текущей единицы измерения.
      int currentIndex = 0;
      while (currentIndex < units.length - 1 &&
          value >= bigIntPow(BigInt.from(1000), currentIndex + 1)) {
        currentIndex++;
      }

      final BigInt currentThreshold =
          bigIntPow(BigInt.from(1000), currentIndex);
      final BigInt nextThreshold =
          bigIntPow(BigInt.from(1000), currentIndex + 1);

      // Расчитываем диапазон для текущей единицы измерения.
      final BigInt range = nextThreshold - currentThreshold;
      final BigInt progress = value - currentThreshold;

      // Переводим BigInt в double.
      // При этом возможно потеря точности, однако, так как возвращаемое значение — прогресс от 0 до 1, это обычно допустимо.
      double progressRatio = progress.toDouble() / range.toDouble();
      return progressRatio.clamp(0.0, 1.0);
    }

    double calculateRareResourceProgress(BigInt value) {
      // Индекс текущей "приписки" для редких ресурсов
      int currentIndex = 0;

      // Используем тот же принцип, что и для обычных ресурсов
      while (value >= BigInt.from(pow(1000, currentIndex + 1))) {
        currentIndex++;
      }

      final BigInt currentThreshold = BigInt.from(pow(1000, currentIndex));
      final BigInt nextThreshold = BigInt.from(pow(1000, currentIndex + 1));

      // Прогресс от текущей "приписки" до следующей для редких ресурсов
      final BigInt range = nextThreshold - currentThreshold;
      final BigInt progress = value - currentThreshold;

      // Возвращаем нормализованный прогресс (от 0 до 1)
      return (progress / range).toDouble().clamp(0.0, 1.0);
    }

    return Scaffold(
      appBar: AppBar(title: Text("Phase $currentPhase"), actions: [
        if (_showSecretButton)
          IconButton(
            icon: Icon(
              Icons.build_rounded,
            ),
            onPressed: () async {
              widget.player.playSoundEffect('sfx/_illegal-shop.mp3');
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheatShop(
                    resourceCount: resourceCount,
                    rareResourceCount: rareResourceCount,
                    resourcePerClick: resourcesPerClick,
                    currentPhase: currentPhase,
                    resourcesPerSecond: resourcesPerSecond,
                    onUpdateResourceCount: _updateResourceCount,
                    onUpdateRareResourceCount: _updateRareResourceCount,
                    onUpdateResourcePerClick: _updateResourcePerClick,
                    onUpdateResourcesPerSecond: _updateResourcePerSecond,
                  ),
                ),
              );
              _saveGameData();
            },
          ),
        IconButton(
          icon: Icon(Icons.emoji_events),
          onPressed: () {
            widget.player.playSoundEffect('sfx/aboba.mp3');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LeaderboardPage()),
            );
          },
        ),
        IconButton(
            icon: Text(
              "G",
              style: TextStyle(fontSize: 25),
            ),
            onPressed: () async {
              widget.player.playSoundEffect('sfx/tililin.wav');
              print("🔹 Начинаем вход через Google...");
              User? user = await signInWithGoogle();

              if (user != null) {
                print("✅ Успешный вход! Пользователь: ${user.displayName}");
              } else {
                print("❌ Вход не удался!");
              }
            }),
        IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () async {
            widget.player.playSoundEffect('sfx/aboba.mp3');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreditsPage(),
              ),
            );
            _checkTapCount();
          },
        ),
      ]),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.player.playSoundEffect('sfx/tap.wav');
          _incrementResource();
          _saveGameData();
        },
        onLongPressStart: (_) {
          _longPressTimer =
              Timer.periodic(const Duration(milliseconds: 500), (_) {
            Random().nextBool() == true
                ? widget.player
                    .playSoundEffect('sfx/cartoon-mr-krab-walking.mp3')
                : widget.player.playSoundEffect('sfx/_long_press.mp3');
            _incrementResource();
          });
        },
        onLongPressEnd: (_) {
          _longPressTimer?.cancel();
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentPhase < 10 ? 'Resources' : 'Infinities',
                style: TextStyle(
                  fontSize: 36,
                  color: widget.isDarkTheme ? Colors.amber[300] : Colors.indigo,
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 160,
                    child: Align(
                      child: Text(
                        formatResourceCount(resourceCount),
                        style: TextStyle(
                          fontSize: 28,
                          color: widget.isDarkTheme
                              ? Colors.amber[100]
                              : Colors.indigo,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center, // Центрируем текст
                        softWrap: true, // Включаем перенос
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 240,
                    child: CustomPaint(
                      painter: ArcPainter(
                        progress: calculateProgress(resourceCount),
                        // Прогресс для ресурсов
                        color1: Colors.greenAccent,
                        color2: widget.isDarkTheme
                            ? Colors.white12
                            : Colors.black26,
                        radius: 120,
                        // Радиус круга для ресурсов
                        start_angle: 3 * 3.14 / 5,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Stack(alignment: Alignment.center, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Infinity  ',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.purpleAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Stack(
                      alignment: Alignment.center,
                      // Центрируем всё содержимое
                      children: [
                        SizedBox(
                          width: 100, // Размер окружности
                          height: 100,
                          child: CustomPaint(
                            painter: ArcPainter(
                              progress: calculateRareResourceProgress(
                                  BigInt.from(currentPhase * 1000 / 35)),
                              // progress: calculateProgress(resourceCount),
                              color1: Colors.purpleAccent,
                              color2: widget.isDarkTheme
                                  ? Colors.white12
                                  : Colors.black26,
                              radius: 50,
                              start_angle: 0,
                            ),
                          ),
                        ),
                        // SizedBox(
                        //   width: 100, // Совпадает с окружностью
                        //   height: 130,
                        //   child: Align(
                        //     alignment: Alignment.centerRight,
                        //     child: Text(
                        //       "${rareResourceCount.toString().substring(0, rareResourceCount.toString().length ~/ 2)}  ",
                        //
                        //       style: TextStyle(
                        //         fontSize: 20,
                        //         color: widget.isDarkTheme
                        //             ? Colors.purple[100]
                        //             : Colors.purple,
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //       textAlign: TextAlign.center,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.center,
                      // Центрируем всё содержимое
                      children: [
                        SizedBox(
                          width: 100, // Размер окружности
                          height: 100,
                          child: CustomPaint(
                            painter: ArcPainter(
                              progress: calculateRareResourceProgress(
                                  BigInt.from(currentPhase * 1000 / 35)),
                              // progress: calculateProgress(resourceCount),
                              color1: Colors.purpleAccent,
                              color2: widget.isDarkTheme
                                  ? Colors.white12
                                  : Colors.black26,
                              radius: 50,
                              start_angle: 3.14,
                            ),
                          ),
                        ),
                        // SizedBox(
                        //   width: 100, // Совпадает с окружностью
                        //   height: 130,
                        //   child: Align(
                        //     alignment: Alignment.centerLeft,
                        //     // Центрируем текст внутри
                        //     child: Text(
                        //       " ${rareResourceCount.toString().substring(rareResourceCount.toString().length ~/ 2)}",
                        //
                        //       style: TextStyle(
                        //         fontSize: 20,
                        //         color: widget.isDarkTheme
                        //             ? Colors.purple[100]
                        //             : Colors.purple,
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //       textAlign: TextAlign.center,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    Text(
                      ' points',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.purpleAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Text(
                  rareResourceCount.toString(),
                  style: TextStyle(
                    color:
                        widget.isDarkTheme ? Colors.amber[100] : Colors.indigo,
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
              ]),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                spacing: 30,
                children: [
                  // Круг вокруг "Resources per click"
                  Column(
                    children: [
                      const Text(
                        'Resources per click',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.redAccent),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 170,
                            child: CustomPaint(
                              painter: ArcPainter(
                                progress: calculateProgress(
                                    resourcesPerClick * bonusClickIncrease),
                                color1: Colors.redAccent,
                                color2: widget.isDarkTheme
                                    ? Colors.white12
                                    : Colors.black26,
                                radius: 80,
                                start_angle: 3 * 3.14 / 5,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 140,
                            height: 100,
                            child: Text(
                              formatResourceCount(
                                  resourcesPerClick * bonusClickIncrease),
                              style: TextStyle(
                                fontSize: 22,
                                color: widget.isDarkTheme
                                    ? Colors.amber[100]
                                    : Colors.indigo,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center, // Центрируем текст
                              softWrap: true, // Включаем перенос
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Круг вокруг "Passive Generation"

                  Column(
                    children: [
                      const Text(
                        'Resources per second',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 18, color: Colors.blueAccent),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 170,
                            child: CustomPaint(
                              painter: ArcPainter(
                                progress: calculateProgress(
                                    resourcesPerSecond * bonusPassiveIncrease),
                                color1: Colors.blueAccent,
                                color2: widget.isDarkTheme
                                    ? Colors.white12
                                    : Colors.black26,
                                radius: 80,
                                // Радиус круга для resourcesPerSecond
                                start_angle: 3 * 3.14 / 5,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 140,
                            height: 100,
                            child: Text(
                              formatResourceCount(
                                  resourcesPerSecond * bonusPassiveIncrease),
                              style: TextStyle(
                                fontSize: 22,
                                color: widget.isDarkTheme
                                    ? Colors.amber[100]
                                    : Colors.indigo,
                              ),
                              textAlign: TextAlign.center, // Центрируем текст
                              softWrap: true, // Включаем перенос
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Row(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.shopping_cart_outlined,
                size: 45,
                color: widget.isDarkTheme ? Colors.white60 : Colors.black87,
              ),
              onPressed: () async {
                if (currentPhase == 9) {
                  widget.player
                      .playSoundEffect('sfx/loading-lost-connection.mp3');
                } else {
                  widget.player.playSoundEffect('sfx/menu_click.wav');
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Shop(
                        bonusResourceCount: bonusResourceCount,
                        bonusClickIncrease: bonusClickIncrease,
                        bonusPassiveIncrease: bonusPassiveIncrease,
                        resourceCount: resourceCount,
                        rareResourceCount: rareResourceCount,
                        resourcePerClick: resourcesPerClick,
                        currentPhase: currentPhase,
                        resourcesPerSecond: resourcesPerSecond,
                        onUpdateBonusResource: _updateBonusResource,
                        onUpdateBonusClick: _updateBonusClick,
                        onUpdateBonusPassive: _updateBonusPassive,
                        onUpdateResourceCount: _updateResourceCount,
                        onUpdateRareResourceCount: _updateRareResourceCount,
                        onUpdateResourcePerClick: _updateResourcePerClick,
                        onUpdateResourcesPerSecond: _updateResourcePerSecond,
                      ),
                    ),
                  );
                }
                _saveGameData();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.workspace_premium,
                size: 45,
                color: widget.isDarkTheme ? Colors.white38 : Colors.black38,
              ),
              onPressed: () async {
                widget.player.playSoundEffect('sfx/menu_click.wav');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AchievementsPage(
                      resources: resourceCount,
                      currentPhase: currentPhase,
                    ),
                  ),
                );
                _saveGameData();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.settings,
                size: 45,
                color: widget.isDarkTheme ? Colors.white60 : Colors.black87,
              ),
              onPressed: () async {
                widget.player.playSoundEffect('sfx/menu_click.wav');
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(
                      onSwitchChanged: (bool value) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isAbbreviated', value);
                        setState(() {
                          isAbbreviated = value;
                        });
                      },
                      onReset: () async {
                        await _resetGameData();
                      },
                      onThemeChanged: widget.onThemeChanged,
                      isDarkTheme: widget.isDarkTheme,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
