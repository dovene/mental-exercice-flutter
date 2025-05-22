import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatelessWidget {
  final AnimationController animationController;

  const AnimatedBackground({
    Key? key,
    required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPainter(animationController.value),
          child: Container(),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;
  BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 10; i++) {
      final offset = i * 0.1;
      final position = (animationValue + offset) % 1.0;
      final x = size.width * (0.1 + position * 0.8);
      final y = size.height * (0.1 + math.sin(position * math.pi) * 0.8);
      final radius = size.width * 0.03 +
          size.width * 0.02 * math.sin(position * math.pi * 2);
      switch (i % 4) {
        case 0:
          paint.color = Colors.blue.withOpacity(0.1);
          canvas.drawCircle(Offset(x, y), radius, paint);
          paint.color = Colors.blue.withOpacity(0.2);
          canvas.drawRect(
              Rect.fromCenter(
                  center: Offset(x, y),
                  width: radius * 0.6,
                  height: radius * 2),
              paint);
          canvas.drawRect(
              Rect.fromCenter(
                  center: Offset(x, y),
                  width: radius * 2,
                  height: radius * 0.6),
              paint);
          break;
        case 1:
          paint.color = Colors.red.withOpacity(0.1);
          canvas.drawCircle(Offset(x, y), radius, paint);
          paint.color = Colors.red.withOpacity(0.2);
          canvas.drawCircle(Offset(x, y), radius * 0.7, paint);
          break;
        case 2:
          paint.color = Colors.green.withOpacity(0.1);
          canvas.drawCircle(Offset(x, y), radius, paint);
          paint.color = Colors.green.withOpacity(0.2);
          canvas.drawRect(
              Rect.fromCenter(
                  center: Offset(x, y),
                  width: radius * 2,
                  height: radius * 0.6),
              paint);
          break;
        case 3:
          paint.color = Colors.purple.withOpacity(0.1);
          canvas.drawCircle(Offset(x, y), radius, paint);
          paint.color = Colors.purple.withOpacity(0.2);
          canvas.save();
          canvas.translate(x, y);
          canvas.rotate(math.pi / 4);
          canvas.drawRect(
              Rect.fromCenter(
                  center: Offset.zero, width: radius * 0.6, height: radius * 2),
              paint);
          canvas.drawRect(
              Rect.fromCenter(
                  center: Offset.zero, width: radius * 2, height: radius * 0.6),
              paint);
          canvas.restore();
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
