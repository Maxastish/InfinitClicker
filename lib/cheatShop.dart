import 'dart:async';

import 'package:flutter/material.dart';

class Upgrade {
  final String name;
  final BigInt clickIncrease;
  final BigInt genIncrease;
  final String type;
  final double efficiency;
  final BigInt cost;

  Upgrade({
    required this.name,
    BigInt? clickIncrease,
    BigInt? genIncrease,
    required this.type,
    this.efficiency = 10.0, required
    BigInt this.cost,
  })  : clickIncrease = clickIncrease ?? BigInt.zero,
        genIncrease = genIncrease ?? BigInt.zero;
}

class CheatShop extends StatefulWidget {
  BigInt resourceCount;
  final BigInt rareResourceCount;
  final Function(BigInt newResourceCount) onUpdateResourceCount;
  final Function(BigInt newRareResourceCount) onUpdateRareResourceCount;
  final Function(BigInt newResourceCount) onUpdateResourcePerClick;
  final Function(BigInt newResourceCount) onUpdateResourcesPerSecond;
  final int currentPhase;
  final BigInt resourcePerClick;
  final BigInt resourcesPerSecond;

  CheatShop({
    Key? key,
    required this.resourceCount,
    required this.rareResourceCount,
    required this.onUpdateResourceCount,
    required this.onUpdateRareResourceCount,
    required this.currentPhase,
    required this.resourcePerClick,
    required this.onUpdateResourcePerClick,
    required this.onUpdateResourcesPerSecond,
    required this.resourcesPerSecond,
  }) : super(key: key);

  @override
  State<CheatShop> createState() => _ShopState();
}

class _ShopState extends State<CheatShop> {
  late List<Upgrade> upgrades;
  Timer? _passiveTimer;
  BigInt totalCost = BigInt.zero;

  // Функция для покупки с обновлением баланса
  void _purchaseUpgrade(BigInt cost, BigInt clickIncrease, BigInt genIncrease, bool isRare, int quantity) {

    // Проверяем, хватает ли ресурсов на покупку
    if (widget.resourceCount >= totalCost) {
      setState(() {

        // Увеличиваем ресурсы за клик и за секунду
        widget.onUpdateResourcePerClick(widget.resourcePerClick + clickIncrease * BigInt.from(quantity));
        widget.onUpdateResourcesPerSecond(widget.resourcesPerSecond + genIncrease * BigInt.from(quantity));
      });
    }
  }

  // Функция для вычисления максимального количества покупок
  int _calculateMaxPurchases(BigInt availableResources, BigInt cost) {
    return 1000;
  }

  Widget _buildMaxPurchaseButton(BigInt effectiveCost, BigInt clickIncrease, BigInt genIncrease, bool isRare) {
    // Находим максимально возможное количество покупок
    BigInt maxQuantity = BigInt.from(_calculateMaxPurchases(widget.resourceCount, effectiveCost));

    return ElevatedButton(
      onPressed: maxQuantity > BigInt.zero
          ? () {
        _purchaseUpgrade(effectiveCost, clickIncrease, genIncrease, isRare, maxQuantity.toInt()); // Покупаем максимально возможное количество
      }
          : null, // Если недостаточно ресурсов, кнопка неактивна
      child: Text('Max'), // (${_formatBigInt(maxQuantity)})
    );
  }


  // Метод для создания улучшений (клик, пассивные и генераторы)
  List<Upgrade> _initializeUpgrades(String type, BigInt baseCost, double growthRate, int count, double efficiencyDecay, bool isRare) {
    return List.generate(count, (index) {
      // Модификация коэффициента роста в зависимости от текущей фазы
      double adjustedGrowthRate = growthRate - (widget.currentPhase * 0.05); // Снижаем рост на начальных фазах
      adjustedGrowthRate = adjustedGrowthRate < 1 ? 1 : adjustedGrowthRate; // Убедимся, что коэффициент роста не упал ниже 1

      // Вычисление стоимости улучшения с учетом модификации коэффициента роста
      BigInt cost = baseCost * BigInt.from(adjustedGrowthRate).pow(index + widget.currentPhase);

      // Уменьшение стоимости на первых фазах
      if (widget.currentPhase < 5) {
        cost = cost ~/ BigInt.from(2); // На первых 5 фазах стоимость уменьшается в 2 раза
      }

      double efficiency = 10.0 - (widget.currentPhase * efficiencyDecay); // Умножаем на 10 для начальной эффективности
      efficiency = efficiency > 0 ? efficiency : 0.1; // Минимум 0.1 для эффективности
      BigInt increment = BigInt.from(growthRate).pow(index) * BigInt.from(efficiency).pow(2);

      return Upgrade(
        name: '$type +$increment',
        cost: cost,
        clickIncrease: type == 'click' ? increment : BigInt.zero,
        genIncrease: type == 'passive' ? increment : BigInt.zero,
        type: type,
        efficiency: efficiency,
      );
    });
  }


  @override
  void initState() {
    super.initState();
    upgrades = [
      // String type, BigInt baseCost, double growthRate, int count, double efficiencyDecay, bool isRare
      ..._initializeUpgrades('click', BigInt.from(100), 10, 30, 0.05, false),
      ..._initializeUpgrades('passive', BigInt.from(200), 11, 30, 0.03, false),
    ];
    _startAutoGeneration();
  }

  @override
  void dispose() {
    _passiveTimer?.cancel();
    super.dispose();
  }

  void _startAutoGeneration() {
    _passiveTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      setState(() {
        widget.resourceCount += (widget.resourcesPerSecond  ~/ BigInt.from(1)) - totalCost;
        totalCost = BigInt.zero;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Resources: ${_formatBigInt(widget.resourceCount)}'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Click Upgrades'),
              Tab(text: 'Passive Upgrades'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUpgradeList('click'),
            _buildUpgradeList('passive'),
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
        BigInt effectiveCost = BigInt.zero;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(_formatUpgradeName(upgrade.name)),
            subtitle: Text('Cost: ${_formatBigInt(effectiveCost)}\nEfficiency: ${upgrade.efficiency.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: widget.resourceCount >= effectiveCost
                      ? () {
                    _purchaseUpgrade(effectiveCost, upgrade.clickIncrease, upgrade.genIncrease, upgrade.type == 'generator', 1);
                  }
                      : null,
                  child: const Text('1x'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: widget.resourceCount >= effectiveCost * BigInt.from(10)
                      ? () {
                    _purchaseUpgrade(effectiveCost, upgrade.clickIncrease, upgrade.genIncrease, upgrade.type == 'generator', 10);
                  }
                      : null,
                  child: const Text('10x'),
                ),
                SizedBox(width: 8),
                _buildMaxPurchaseButton(effectiveCost, upgrade.clickIncrease, upgrade.genIncrease, upgrade.type == 'generator'),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatBigInt(BigInt value) {
    const units = ['K', 'M', 'B', 'T', 'Qa', 'Qi', 'Sx', 'Sp', 'Oc', 'No', 'lim→∞'];
    BigInt divider = BigInt.from(1000);
    int unitIndex = -1;

    while (value >= divider && unitIndex < units.length - 1) {
      value = value ~/ divider;
      unitIndex++;
    }

    return unitIndex >= 0 ? '${value} ${units[unitIndex]}' : value.toString();
  }

  String _formatUpgradeName(String name) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(name);
    if (match != null) {
      final value = BigInt.parse(match.group(1)!);
      final formattedValue = _formatBigInt(value);
      return name.replaceFirst(match.group(1)!, formattedValue);
    }
    return name;
  }
}
