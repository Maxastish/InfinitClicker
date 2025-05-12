// progress_formatter.dart - Форматирование чисел и ординалов
class ProgressFormatter {
  static String formatResourceCount(BigInt value) {
    if (value < BigInt.from(1000)) return value.toString();
    int index = 0;
    while (value >= BigInt.from(1000) && index < units.length - 1) {
      value ~/= BigInt.from(1000);
      index++;
    }
    return "\$value \${units[index]}";
  }

  static final units = ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "lim→∞"];
}
