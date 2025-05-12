import 'dart:async';
import 'dart:math';
import 'package:clicker/music_player.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Upgrade {
  final String name;
  final BigInt cost;
  BigInt clickIncrease;
  BigInt genIncrease;
  final String type;
  final BigInt bonusResourceIncrease;
  final BigInt bonusClickIncrease;
  final BigInt bonusPassiveIncrease;
  final int efficiency;
  int purchaseCount; // Количество покупок (только для specials)
  final int maxPurchases; // Максимальное количество покупок

  Upgrade({
    required this.name,
    required this.cost,
    BigInt? clickIncrease,
    BigInt? genIncrease,
    required this.type,
    this.efficiency = 10,
    this.purchaseCount = 0,
    this.maxPurchases = 1,
    BigInt? bonusResourceIncrease,
    BigInt? bonusClickIncrease,
    BigInt? bonusPassiveIncrease,
  })  : clickIncrease = clickIncrease ?? BigInt.zero,
        genIncrease = genIncrease ?? BigInt.zero,
        bonusResourceIncrease = bonusResourceIncrease ?? BigInt.zero,
        bonusClickIncrease = bonusClickIncrease ?? BigInt.one,
        bonusPassiveIncrease = bonusPassiveIncrease ?? BigInt.one;
}

class Shop extends StatefulWidget {
  late BigInt resourceCount;
  late final int currentPhase;
  late BigInt rareResourceCount;
  final BigInt bonusResourceCount;
  final BigInt bonusClickIncrease;
  final BigInt bonusPassiveIncrease;

  final BigInt resourcePerClick;
  final BigInt resourcesPerSecond;

  final Function(BigInt newResourceCount) onUpdateResourceCount;
  final Function(BigInt newRareResourceCount) onUpdateRareResourceCount;

  final Function(BigInt newResourceCount) onUpdateResourcePerClick;
  final Function(BigInt newResourceCount) onUpdateResourcesPerSecond;
  final Function(BigInt newResourceCount) onUpdateBonusResource;
  final Function(BigInt newResourceCount) onUpdateBonusClick;
  final Function(BigInt newResourceCount) onUpdateBonusPassive;


  Shop({
    Key? key,
    required this.bonusResourceCount,
    required this.bonusClickIncrease,
    required this.bonusPassiveIncrease,
    required this.resourceCount,
    required this.currentPhase,
    required this.rareResourceCount,
    required this.resourcePerClick,
    required this.resourcesPerSecond,

    required this.onUpdateResourceCount,
    required this.onUpdateRareResourceCount,
    required this.onUpdateResourcePerClick,
    required this.onUpdateResourcesPerSecond,
    required this.onUpdateBonusResource,
    required this.onUpdateBonusClick,
    required this.onUpdateBonusPassive,

  }) : super(key: key);

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  late List<Upgrade> upgrades;
  Timer? _passiveTimer;
  BigInt totalCost = BigInt.zero;
  String upgradeType = "";
  bool _isLoading = true;
  final player = MusicPlayer();

  _purchaseUpgrade(effectiveCost, clickIncrease, genIncrease, int quantity, Upgrade? upgrade) {
    totalCost = effectiveCost * BigInt.from(quantity);
    upgradeType = upgrade!.type;

    if (upgrade.type == 'special') {
      // print("buy special");

      // Для 'special' ресурсов используем rareResourceCount
      if (widget.rareResourceCount >= totalCost && (upgrade.purchaseCount + quantity <= upgrade.maxPurchases)) {
        // print("true");
        player.playSoundEffect('sfx/tililin.wav');

        setState(() {
          widget.onUpdateRareResourceCount(widget.rareResourceCount - totalCost);

          // Обновляем параметры в зависимости от типа улучшения
          if (upgrade.name.contains('Start')) {
            widget.onUpdateBonusResource(widget.bonusResourceCount + upgrade.bonusResourceIncrease);
          } else if (upgrade.name.contains('Click')) {
            widget.onUpdateBonusClick(widget.bonusClickIncrease + upgrade.bonusClickIncrease);
          } else if (upgrade.name.contains('Passive')) {
            widget.onUpdateBonusPassive(widget.bonusPassiveIncrease + upgrade.bonusPassiveIncrease);
          } else if (upgrade.name.contains('Right')) {
            widget.onUpdateResourceCount(widget.resourceCount + upgrade.bonusResourceIncrease); // увеличиваем ресурс
            widget.resourceCount += upgrade.bonusResourceIncrease;
          }

          widget.rareResourceCount -= totalCost;
          upgrade.purchaseCount += quantity;
          _saveSpecialPurchaseCount(upgrade);
        });
      }
    } else {
      // Для обычных улучшений используем обычные ресурсы
      if (widget.resourceCount >= totalCost) {
        // print("true");
        player.playSoundEffect('sfx/thin.wav');
        setState(() {
          widget.onUpdateResourceCount(widget.resourceCount - totalCost);

          widget.onUpdateResourcePerClick(widget.resourcePerClick + clickIncrease * BigInt.from(quantity));
          widget.onUpdateResourcesPerSecond(widget.resourcesPerSecond + genIncrease * BigInt.from(quantity));

          widget.resourceCount -= totalCost;
          upgrade.purchaseCount += quantity;
          _saveSpecialPurchaseCount(upgrade);
        });
      }
    }
  }

// Функция для сохранения данных о генераторах
  void _saveSpecialPurchaseCount(Upgrade upgrade) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(upgrade.name, upgrade.purchaseCount);
  }

  // Функция для вычисления максимального количества покупок
  int _calculateMaxPurchases(BigInt availableResources, BigInt cost, String upgradeType) {
    if (cost <= BigInt.zero) return 0; // Предотвращение деления на 0
    if (upgradeType == 'special') {
      return (widget.rareResourceCount ~/ cost).toInt(); // Для "special" используем редкие ресурсы
    } else {
      return (availableResources ~/ cost).toInt(); // Для остальных — обычные ресурсы
    }
  }

  Widget _buildMaxPurchaseButton(BigInt effectiveCost, BigInt clickIncrease, BigInt genIncrease, String upgradeType, Upgrade upgrade) {
    // Находим максимально возможное количество покупок в зависимости от типа улучшения
    BigInt maxQuantity = BigInt.from(_calculateMaxPurchases(
      widget.resourceCount,
      effectiveCost,
      upgradeType,
    ));

    return ElevatedButton(
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all<Size?>(Size(90, 40)), // Используем WidgetStateProperty
      ),
      onPressed: maxQuantity > BigInt.zero
          ? () {
        _purchaseUpgrade(effectiveCost, clickIncrease, genIncrease, maxQuantity.toInt(), upgrade); // Покупаем максимально возможное количество
      }
          : null, // Если недостаточно ресурсов, кнопка неактивна
      child: Text(formate_data(maxQuantity)),
    );
  }

  // Метод для создания улучшений (клик, пассивные и генераторы)
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

  List<Upgrade> _initializeUpgrades(String type, BigInt baseCost, int count, int efficiencyDecay) {
    return List.generate(count, (index) {
      int efficiency = ((25 + (100 - 25) * (log(30 + efficiencyDecay) - log(widget.currentPhase)) / log(36 + efficiencyDecay))).round();
      efficiency = efficiency >= 25 ? efficiency : 25; // минимум 0.25

      BigInt increment = BigInt.from(baseCost * BigInt.from(efficiency) * bigIntPow(BigInt.from(10), index) / BigInt.from(100));

      BigInt cost = baseCost * bigIntPow(BigInt.from(10), index);

      return Upgrade(
        name: '+$increment $type',
        cost: cost,
        clickIncrease: type == 'click' ? increment : BigInt.zero,
        genIncrease: type == '/ sec' ? increment : BigInt.zero,
        type: type,
        efficiency: efficiency,
      );
    });
  }

  // Метод для генераторов, которые используют редкие ресурсы
  List<Upgrade> _initializeSpecials(BigInt baseCost, double growthRate, int count) {
    return List.generate(count, (index) {
      double logBase10(double x) => log(x) / log(10);
      // В зависимости от типа улучшения добавляем разные эффекты:
      if (index % 4 == 0) { // Улучшение для bonusResourceCount
        BigInt cost = BigInt.from(1111 * pow(logBase10(10 * (index / 4 + 1.1)), 10));
        BigInt increment = BigInt.from(500 * pow(logBase10(10 * (index / 4 + 1.1)), 10));
        return Upgrade(
          name: 'Start + ${formate_data(increment)}',
          cost: cost,
          bonusResourceIncrease: increment,
          type: 'special',
          maxPurchases: 1, // Лимит покупок для генераторов
        );
      } else if (index % 4 == 1) { // Улучшение для bonusClickIncrease
        BigInt cost = BigInt.from(1111 * pow(logBase10(10 * (index / 4 + 1.1)), 10));
        BigInt increment = BigInt.from(e * (index / 4 + 1.1));
        return Upgrade(
          name: 'Clicks: x$increment',
          cost: cost,
          bonusClickIncrease: increment,
          type: 'special',
          maxPurchases: 1,
        );
      } else if (index % 4 == 2) { // Улучшение для bonusPassiveIncrease
        BigInt cost = BigInt.from(1111 * pow(logBase10(10 * (index / 4 + 1.1)), 10));
        BigInt increment = BigInt.from((e * (index / 4 + 1.1)) / 1.4);
        return Upgrade(
          name: 'Passive: x$increment',
          cost: cost,
          bonusPassiveIncrease: increment,
          type: 'special',
          maxPurchases: 1,
        );
      }
      else { // Улучшение для resourceCount
        BigInt cost = BigInt.from(1111 * pow(logBase10(10 * (index / 4 + 1.1)), 10));
        BigInt increment = cost * ((cost % BigInt.from(1000)) * BigInt.from(100)).pow((index / 4).round());
        return Upgrade(
          name: 'Right now + ${formatResourceCount(increment)}',
          cost: cost,
          bonusResourceIncrease: increment,
          type: 'special',
          maxPurchases: 1,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPurchaseData();  // Загрузка данных при старте

    upgrades = [
      // String type, BigInt baseCost, double growthRate, int count, double efficiencyDecay
      ..._initializeUpgrades('click', BigInt.from(100), 31, 30),
      ..._initializeUpgrades('/ sec', BigInt.from(150), 31, 5),
      //          BigInt baseCost, double growthRate, int count
      ..._initializeSpecials(BigInt.one, 3, 20),
    ];
    _startAutoGeneration();
  }

  Future<void> _loadPurchaseData() async {
    setState(() {
      _isLoading = true;  // Начало загрузки
    });

    final prefs = await SharedPreferences.getInstance();
    for (var upgrade in upgrades) {
      int savedCount = prefs.getInt(upgrade.name) ?? 0;
      upgrade.purchaseCount = savedCount;
    }

    // После загрузки данных
    setState(() {
      _isLoading = false;  // Завершение загрузки
    });
  }


  @override
  void dispose() {
    _passiveTimer?.cancel();
    super.dispose();
  }

  void _startAutoGeneration() {
    _passiveTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        widget.resourceCount += BigInt.from(widget.resourcesPerSecond / BigInt.from(10));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 90,
          title: Column(
            children: [
              Text('Resources: ${formatResourceCount(widget.resourceCount)}', style: TextStyle(fontSize: 22)),
              Text('Infinity points: ${formate_data(widget.rareResourceCount)}', style: TextStyle(fontSize: 20))
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Column(
                children: [
                  Text('Click', style: TextStyle(fontSize: 18),),
                  Text('Upgrades', style: TextStyle(fontSize: 18),),
                ],
              ),
              Column(
                children: [
                  Text('Passive', style: TextStyle(fontSize: 18),),
                  Text('Upgrades', style: TextStyle(fontSize: 18),),
                ],
              ),
              Column(
                children: [
                  Text('Infinities', style: TextStyle(fontSize: 18),),
                  Text("(persist after reset)", textAlign: TextAlign.center,)
                ],
              ),
            ],
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())  // Индикатор загрузки
            : TabBarView(
          children: [
            _buildUpgradeList('click'),
            _buildUpgradeList('/ sec'),
            _buildUpgradeList('special'),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeList(String type) {
    final filteredUpgrades = upgrades.where((u) => u.type == type).toList();

    return ListView.builder(
      itemCount: filteredUpgrades.length,
      itemBuilder: (context, index) {
        final upgrade = filteredUpgrades[index];
        BigInt effectiveCost = upgrade.cost;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          color:
            upgrade.type == 'special' && upgrade.purchaseCount < upgrade.maxPurchases && widget.rareResourceCount > upgrade.cost?
            Color.fromARGB(160, 100, 54, 170) :
            upgrade.type != 'special' && widget.resourceCount > upgrade.cost ?
            Color.fromARGB(160, 100, 54, 170) : Colors.transparent,
          child: ListTile(
            title: Text(
              upgrade.type == 'special' ?
                '${upgrade.name}'
                : '+ ${formatResourceCount(_formatUpgradeName(upgrade.name))} ${upgrade.type}',
            ),

            subtitle: Text(
              upgrade.type == 'special' ?
                'Cost: ${formate_data(effectiveCost)}\n(${upgrade.purchaseCount}/${upgrade.maxPurchases})'
                : 'Cost: ${formatResourceCount(effectiveCost)}\nEfficiency: ${upgrade.efficiency}%',
              style: TextStyle(fontSize: 14),
            ),


            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: upgrade.type != 'special' ?
                    widget.resourceCount >= effectiveCost ?
                        () {
                    _purchaseUpgrade(
                      effectiveCost,
                      upgrade.clickIncrease,
                      upgrade.genIncrease,
                      1,
                      upgrade,
                    );
                  }
                        : null : widget.rareResourceCount >= effectiveCost && upgrade.purchaseCount < upgrade.maxPurchases
                      ? () {
                    _purchaseUpgrade(
                      effectiveCost,
                      upgrade.clickIncrease,
                      upgrade.genIncrease,
                      1,
                      upgrade,
                    );
                    } : null,
                  child: Text(
                    upgrade.type == 'special' && upgrade.purchaseCount >= upgrade.maxPurchases
                        ? 'Maxed Out'
                        : 'Buy',
                  ),
                ),

                if (upgrade.type != 'special') ...[
                  SizedBox(width: 4,),
                  ElevatedButton(
                    onPressed: widget.resourceCount >= effectiveCost * BigInt.from(10)
                        ? () {
                      _purchaseUpgrade(
                        effectiveCost,
                        upgrade.clickIncrease,
                        upgrade.genIncrease,
                        10,
                        upgrade,
                      );
                    }
                        : null,
                    child: const Text('10x'),
                  ),
                  SizedBox(width: 4,),
                  _buildMaxPurchaseButton(
                    effectiveCost,
                    upgrade.clickIncrease,
                    upgrade.genIncrease,
                    upgrade.type,
                    upgrade,
                  ),
                ],
              ],
            ),
          ),
        );

      },
    );
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
    ];

    // Проверяем, что текущая фаза в допустимых пределах
    if (widget.currentPhase >= 1 && widget.currentPhase <= phaseFormatters.length) {
      return phaseFormatters[widget.currentPhase - 1](
          value); // Вызов соответствующей функции
    }
    widget.currentPhase = 1;
    return value.toString(); // Для фаз за пределами диапазона
  }

  BigInt _formatUpgradeName(String name) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(name);
    if (match != null) {
      final value = BigInt.parse(match.group(1)!);
      return value;
    }
    return BigInt.zero;
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
      index = 0; // Возвращаемся к первому элементу, если индекс выходит за пределы
    }

    return "$value${units[index]}${symbols[symbol_num]}";

  }


  String formate_data(BigInt value) {
    if (value < BigInt.from(1000)) return value.toString();

    int index = -1;
    while (value >= BigInt.from(1000) && index < units.length - 1) {
      value ~/= BigInt.from(1000);
      index++;
    }
    return "$value ${units[index + 1]}";
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
}
