import 'dart:math';
import 'package:flutter/material.dart';

// Enhanced particle class for magical animation
class MagicParticle {
  final double angle;
  final double distance;
  final double speed;
  final double size;
  final Color color;
  final double twinkleSpeed;
  final ParticleShape shape;
  final double delay;
  final bool useSpiral;

  MagicParticle({
    required this.angle,
    required this.distance,
    required this.speed,
    required this.size,
    required this.color,
    required this.twinkleSpeed,
    required this.shape,
    required this.delay,
    required this.useSpiral,
  });
}

// Magic wand class
class MagicWand {
  final double angle;
  final double distance;
  final double rotationSpeed;
  final Color color;
  final Color secondaryColor;
  final double wandLength;

  MagicWand({
    required this.angle,
    required this.distance,
    required this.rotationSpeed,
    required this.color,
    required this.secondaryColor,
    required this.wandLength,
  });
}

// Floating celebration text
class FloatingText {
  final String text;
  final double xOffset;
  final double yOffset;
  final double scale;
  final double rotationAngle;
  final Color color;

  FloatingText({
    required this.text,
    required this.xOffset,
    required this.yOffset,
    required this.scale,
    required this.rotationAngle,
    required this.color,
  });
}

// Particle shape enum
enum ParticleShape {
  circle,
  star,
  heart,
  sparkle,
  bird,
  butterfly,
  fish,
  rabbit,
}

// Star shape painter
class StarPainter extends CustomPainter {
  final Color color;
  final int points;

  StarPainter({
    required this.color,
    this.points = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;
    final double innerRadius = radius * 0.4;

    final Path path = Path();

    for (int i = 0; i < points * 2; i++) {
      final double angle = i * pi / points;
      final double currentRadius = i.isEven ? radius : innerRadius;
      final double x = centerX + cos(angle) * currentRadius;
      final double y = centerY + sin(angle) * currentRadius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();

    // Add glow effect
    canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Heart shape painter
class HeartPainter extends CustomPainter {
  final Color color;

  HeartPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;

    final Path path = Path();
    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.2 * width, height * 0.1, -0.25 * width, height * 0.6,
        0.5 * width, height);
    path.cubicTo(1.25 * width, height * 0.6, 0.8 * width, height * 0.1,
        0.5 * width, height * 0.35);
    path.close();

    // Add glow effect
    canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Sparkle shape painter
class SparklePainter extends CustomPainter {
  final Color color;
  final double rotation;

  SparklePainter({
    required this.color,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    canvas.translate(centerX, centerY);
    canvas.rotate(rotation);

    // Draw main sparkle lines
    for (int i = 0; i < 4; i++) {
      final path = Path();
      path.moveTo(0, 0);
      path.lineTo(0, -radius);

      canvas.drawPath(
          path,
          paint
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke);
      canvas.rotate(pi / 2);
    }

    // Draw smaller diagonal lines
    canvas.rotate(pi / 4);
    for (int i = 0; i < 4; i++) {
      final path = Path();
      path.moveTo(0, 0);
      path.lineTo(0, -radius * 0.7);

      canvas.drawPath(path, paint..strokeWidth = 1.0);
      canvas.rotate(pi / 2);
    }

    // Draw center dot
    canvas.drawCircle(
        const Offset(0, 0), radius * 0.15, paint..style = PaintingStyle.fill);

    // Add glow effect
    canvas.drawCircle(
        const Offset(0, 0),
        radius * 0.2,
        Paint()
          ..color = color.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Bird shape painter
class BirdPainter extends CustomPainter {
  final Color color;
  final double wingPosition; // 0.0 to 1.0 for wing animation

  BirdPainter({
    required this.color,
    required this.wingPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;

    // Bird body path
    final Path bodyPath = Path();
    bodyPath.moveTo(width * 0.2, height * 0.5);
    bodyPath.quadraticBezierTo(
        width * 0.5, height * 0.3, width * 0.8, height * 0.5);
    bodyPath.quadraticBezierTo(
        width * 0.5, height * 0.7, width * 0.2, height * 0.5);

    // Head
    bodyPath.addOval(Rect.fromCircle(
      center: Offset(width * 0.2, height * 0.5),
      radius: width * 0.15,
    ));

    // Beak
    bodyPath.moveTo(width * 0.05, height * 0.5);
    bodyPath.lineTo(width * 0.15, height * 0.45);
    bodyPath.lineTo(width * 0.15, height * 0.55);
    bodyPath.close();

    // Wings (animated based on wingPosition)
    final Path wingsPath = Path();
    wingsPath.moveTo(width * 0.5, height * 0.5);
    // Top wing
    wingsPath.quadraticBezierTo(
        width * 0.5,
        height * (0.2 - wingPosition * 0.15),
        width * 0.7,
        height * (0.3 - wingPosition * 0.2));
    wingsPath.quadraticBezierTo(
        width * 0.6, height * 0.4, width * 0.5, height * 0.5);
    // Bottom wing
    wingsPath.quadraticBezierTo(
        width * 0.5,
        height * (0.8 + wingPosition * 0.15),
        width * 0.7,
        height * (0.7 + wingPosition * 0.2));
    wingsPath.quadraticBezierTo(
        width * 0.6, height * 0.6, width * 0.5, height * 0.5);

    // Tail
    final Path tailPath = Path();
    tailPath.moveTo(width * 0.8, height * 0.5);
    tailPath.lineTo(width, height * 0.3);
    tailPath.lineTo(width, height * 0.7);
    tailPath.close();

    // Add glow effect
    canvas.drawPath(
        bodyPath,
        Paint()
          ..color = color.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0));

    canvas.drawPath(wingsPath, paint);
    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(tailPath, paint);
  }

  @override
  bool shouldRepaint(covariant BirdPainter oldDelegate) =>
      oldDelegate.wingPosition != wingPosition || oldDelegate.color != color;
}

// Butterfly shape painter
class ButterflyPainter extends CustomPainter {
  final Color color;
  final double wingPosition; // 0.0 to 1.0 for wing animation

  ButterflyPainter({
    required this.color,
    required this.wingPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;

    // Calculate wing angle based on wingPosition
    final double wingAngle = pi / 4 + wingPosition * pi / 4;

    // Body
    final Path bodyPath = Path();
    bodyPath.moveTo(width * 0.5, height * 0.3);
    bodyPath.lineTo(width * 0.5, height * 0.7);
    bodyPath.close();

    // Wings
    final Path wingsPath = Path();

    // Save canvas state
    canvas.save();
    canvas.translate(width * 0.5, height * 0.5);

    // Left wings
    canvas.save();
    canvas.rotate(-wingAngle);

    // Top left wing
    wingsPath.moveTo(0, 0);
    wingsPath.quadraticBezierTo(
        -width * 0.4, -height * 0.2, -width * 0.4, -height * 0.3);
    wingsPath.quadraticBezierTo(-width * 0.2, -height * 0.4, 0, -height * 0.1);
    wingsPath.close();

    // Bottom left wing
    wingsPath.moveTo(0, 0);
    wingsPath.quadraticBezierTo(
        -width * 0.4, height * 0.2, -width * 0.4, height * 0.3);
    wingsPath.quadraticBezierTo(-width * 0.2, height * 0.4, 0, height * 0.1);
    wingsPath.close();

    canvas.restore();

    // Right wings
    canvas.save();
    canvas.rotate(wingAngle);

    // Top right wing
    wingsPath.moveTo(0, 0);
    wingsPath.quadraticBezierTo(
        width * 0.4, -height * 0.2, width * 0.4, -height * 0.3);
    wingsPath.quadraticBezierTo(width * 0.2, -height * 0.4, 0, -height * 0.1);
    wingsPath.close();

    // Bottom right wing
    wingsPath.moveTo(0, 0);
    wingsPath.quadraticBezierTo(
        width * 0.4, height * 0.2, width * 0.4, height * 0.3);
    wingsPath.quadraticBezierTo(width * 0.2, height * 0.4, 0, height * 0.1);
    wingsPath.close();

    canvas.restore();

    // Add patterns to wings (circles)
    final Path patternPath = Path();
    for (int i = 0; i < 3; i++) {
      patternPath.addOval(Rect.fromCircle(
        center: Offset(-width * 0.2, -height * 0.2 + i * height * 0.2),
        radius: width * 0.05,
      ));
      patternPath.addOval(Rect.fromCircle(
        center: Offset(width * 0.2, -height * 0.2 + i * height * 0.2),
        radius: width * 0.05,
      ));
    }

    // Add glow effect
    canvas.drawPath(
        wingsPath,
        Paint()
          ..color = color.withOpacity(0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0));

    // Draw wings and body
    canvas.drawPath(wingsPath, paint);
    canvas.drawPath(patternPath, paint..color = color.withAlpha(150));

    // Restore original canvas state
    canvas.restore();

    // Draw body
    paint.color = color.darker();
    final bodyRect = Rect.fromCenter(
      center: Offset(width * 0.5, height * 0.5),
      width: width * 0.1,
      height: height * 0.4,
    );
    canvas.drawOval(bodyRect, paint);

    // Draw head
    final headRect = Rect.fromCircle(
      center: Offset(width * 0.5, height * 0.3),
      radius: width * 0.08,
    );
    canvas.drawOval(headRect, paint);

    // Draw antennae
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = width * 0.02;
    canvas.drawLine(Offset(width * 0.45, height * 0.25),
        Offset(width * 0.4, height * 0.15), paint);
    canvas.drawLine(Offset(width * 0.55, height * 0.25),
        Offset(width * 0.6, height * 0.15), paint);
  }

  @override
  bool shouldRepaint(covariant ButterflyPainter oldDelegate) =>
      oldDelegate.wingPosition != wingPosition || oldDelegate.color != color;
}

// Fish shape painter
class FishPainter extends CustomPainter {
  final Color color;
  final double tailPosition; // 0.0 to 1.0 for tail animation

  FishPainter({
    required this.color,
    required this.tailPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;

    // Calculate tail movement
    final double tailOffset = (tailPosition - 0.5) * width * 0.2;

    // Fish body
    final Path bodyPath = Path();
    bodyPath.moveTo(width * 0.3, height * 0.5);
    bodyPath.quadraticBezierTo(
        width * 0.7, height * 0.3, width * 0.8, height * 0.5);
    bodyPath.quadraticBezierTo(
        width * 0.7, height * 0.7, width * 0.3, height * 0.5);

    // Fish head
    bodyPath.addOval(Rect.fromCircle(
      center: Offset(width * 0.3, height * 0.5),
      radius: width * 0.2,
    ));

    // Fish tail (with animation)
    final Path tailPath = Path();
    tailPath.moveTo(width * 0.8, height * 0.5);
    tailPath.lineTo(width * 0.9 + tailOffset, height * 0.3);
    tailPath.lineTo(width + tailOffset, height * 0.5);
    tailPath.lineTo(width * 0.9 + tailOffset, height * 0.7);
    tailPath.close();

    // Fish fin
    final Path finPath = Path();
    finPath.moveTo(width * 0.5, height * 0.3);
    finPath.quadraticBezierTo(
        width * 0.6, height * 0.1, width * 0.7, height * 0.3);
    finPath.close();

    // Bottom fin
    finPath.moveTo(width * 0.5, height * 0.7);
    finPath.quadraticBezierTo(
        width * 0.6, height * 0.9, width * 0.7, height * 0.7);
    finPath.close();

    // Eye
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Add glow effect
    canvas.drawPath(
        bodyPath,
        Paint()
          ..color = color.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0));

    // Draw fish parts
    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(tailPath, paint);
    canvas.drawPath(finPath, paint);

    // Draw eye
    canvas.drawCircle(
        Offset(width * 0.25, height * 0.45), width * 0.05, eyePaint);
    canvas.drawCircle(Offset(width * 0.25, height * 0.45), width * 0.025,
        Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant FishPainter oldDelegate) =>
      oldDelegate.tailPosition != tailPosition || oldDelegate.color != color;
}

// Rabbit shape painter
class RabbitPainter extends CustomPainter {
  final Color color;

  RabbitPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;

    // Rabbit body
    final Path bodyPath = Path();
    bodyPath.addOval(Rect.fromCenter(
      center: Offset(width * 0.5, height * 0.6),
      width: width * 0.7,
      height: height * 0.5,
    ));

    // Rabbit head
    final Path headPath = Path();
    headPath.addOval(Rect.fromCenter(
      center: Offset(width * 0.5, height * 0.4),
      width: width * 0.5,
      height: height * 0.45,
    ));

    // Rabbit ears
    final Path earsPath = Path();

    // Left ear
    earsPath.moveTo(width * 0.35, height * 0.25);
    earsPath.quadraticBezierTo(
        width * 0.3, height * 0.05, width * 0.25, height * 0.1);
    earsPath.quadraticBezierTo(
        width * 0.2, height * 0.2, width * 0.3, height * 0.3);
    earsPath.close();

    // Right ear
    earsPath.moveTo(width * 0.65, height * 0.25);
    earsPath.quadraticBezierTo(
        width * 0.7, height * 0.05, width * 0.75, height * 0.1);
    earsPath.quadraticBezierTo(
        width * 0.8, height * 0.2, width * 0.7, height * 0.3);
    earsPath.close();

    // Inner ears (pink)
    final Path innerEarsPath = Path();

    // Left inner ear
    innerEarsPath.moveTo(width * 0.33, height * 0.25);
    innerEarsPath.quadraticBezierTo(
        width * 0.29, height * 0.1, width * 0.26, height * 0.12);
    innerEarsPath.quadraticBezierTo(
        width * 0.23, height * 0.2, width * 0.3, height * 0.28);
    innerEarsPath.close();

    // Right inner ear
    innerEarsPath.moveTo(width * 0.67, height * 0.25);
    innerEarsPath.quadraticBezierTo(
        width * 0.71, height * 0.1, width * 0.74, height * 0.12);
    innerEarsPath.quadraticBezierTo(
        width * 0.77, height * 0.2, width * 0.7, height * 0.28);
    innerEarsPath.close();

    // Face details
    final Path facePath = Path();

    // Eyes
    facePath.addOval(Rect.fromCircle(
      center: Offset(width * 0.4, height * 0.35),
      radius: width * 0.05,
    ));
    facePath.addOval(Rect.fromCircle(
      center: Offset(width * 0.6, height * 0.35),
      radius: width * 0.05,
    ));

    // Nose
    facePath.addOval(Rect.fromCircle(
      center: Offset(width * 0.5, height * 0.45),
      radius: width * 0.03,
    ));

    // Whiskers
    final Path whiskersPath = Path();

    // Left whiskers
    whiskersPath.moveTo(width * 0.4, height * 0.45);
    whiskersPath.lineTo(width * 0.2, height * 0.4);
    whiskersPath.moveTo(width * 0.4, height * 0.47);
    whiskersPath.lineTo(width * 0.2, height * 0.47);
    whiskersPath.moveTo(width * 0.4, height * 0.49);
    whiskersPath.lineTo(width * 0.2, height * 0.54);

    // Right whiskers
    whiskersPath.moveTo(width * 0.6, height * 0.45);
    whiskersPath.lineTo(width * 0.8, height * 0.4);
    whiskersPath.moveTo(width * 0.6, height * 0.47);
    whiskersPath.lineTo(width * 0.8, height * 0.47);
    whiskersPath.moveTo(width * 0.6, height * 0.49);
    whiskersPath.lineTo(width * 0.8, height * 0.54);

    // Add glow effect
    canvas.drawPath(
        bodyPath,
        Paint()
          ..color = color.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0));

    // Draw rabbit parts
    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(headPath, paint);
    canvas.drawPath(earsPath, paint);

    // Inner ears in pink/lighter color
    final innerEarColor = Color.lerp(color, Colors.pink[100]!, 0.7)!;
    canvas.drawPath(innerEarsPath, Paint()..color = innerEarColor);

    // Draw face details
    canvas.drawPath(facePath, Paint()..color = Colors.black);

    // Draw whiskers
    canvas.drawPath(
        whiskersPath,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
  }

  @override
  bool shouldRepaint(covariant RabbitPainter oldDelegate) => false;
}

// Utility extension to darken colors
extension ColorExtension on Color {
  Color darker([double factor = 0.2]) {
    assert(factor >= 0 && factor <= 1);

    return Color.fromARGB(
      alpha,
      (red * (1 - factor)).round(),
      (green * (1 - factor)).round(),
      (blue * (1 - factor)).round(),
    );
  }
}
