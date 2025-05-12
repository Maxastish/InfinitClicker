import 'package:flutter/cupertino.dart';

class ArcPainter extends CustomPainter {
  final double progress; // Значение прогресса (0.0 - 1.0)
  final Color color1;
  final Color color2;
  final double radius; // Новый параметр радиуса
  final double start_angle;

  ArcPainter({
    required this.progress,
    required this.color1,
    required this.color2,
    required this.radius,
    required this.start_angle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius, // Используем переданный радиус
    );

    // Рисуем серую линию
    canvas.drawArc(
      rect,
      3 * 3.14 / 5, // Начальный угол
      1 * 3.14 * 2, // Длина дуги (максимум 90°)
      false,
      Paint()
        ..color = color2
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round,
    );

    // Рисуем дугу
    canvas.drawArc(
      rect,
      // 3 * 3.14 / 5, // Начальный угол
      start_angle,
      progress * 3.14 * 2, // Длина дуги (максимум 90°)
      false,
      Paint()
        ..color = color1
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}