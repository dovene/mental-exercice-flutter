import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class MagicalStreakAnimation extends StatefulWidget {
  final Widget child;

  const MagicalStreakAnimation({Key? key, required this.child})
      : super(key: key);

  @override
  _MagicalStreakAnimationState createState() => _MagicalStreakAnimationState();
}

class _MagicalStreakAnimationState extends State<MagicalStreakAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<MagicParticle> _particles;
  late List<MagicWand> _magicWands;
  late List<FloatingText> _floatingTexts;
  final Random _random = Random();

  // Randomized theme elements
  late Color _primaryColor;
  late Color _secondaryColor;
  late Color _accentColor;
  late double _rotationDirection;
  late bool _useCircularMotion;
  late bool _useSpiral;

  @override
  void initState() {
    super.initState();

    // Animation lasts exactly 2 seconds
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    // Randomize theme elements
    _randomizeTheme();

    // Generate magical particles
    _particles =
        List.generate(200, (_) => _createMagicParticle());

    // Generate magic wands
    _magicWands = List.generate(3, (_) => _createMagicWand());

    // Create floating celebration texts
    _floatingTexts = [
      _createFloatingText("Champion!", -100),
      _createFloatingText("Génial!", 0),
      _createFloatingText("Brilliant!", 100),
    ];
  }

  void _randomizeTheme() {
    // Generate random theme colors
    final colorSchemes = [
      // Fairy tale color schemes
      [Colors.purple[300]!, Colors.pink[200]!, Colors.amber[300]!],
      [Colors.blue[300]!, Colors.teal[200]!, Colors.yellow[300]!],
      [Colors.indigo[300]!, Colors.deepPurple[200]!, Colors.pink[300]!],
      [Colors.green[300]!, Colors.lightGreen[200]!, Colors.amber[300]!],
      [Colors.pink[300]!, Colors.purple[200]!, Colors.blue[300]!],
    ];

    final selectedScheme = colorSchemes[_random.nextInt(colorSchemes.length)];
    _primaryColor = selectedScheme[0];
    _secondaryColor = selectedScheme[1];
    _accentColor = selectedScheme[2];

    // Randomize motion patterns
    _rotationDirection = _random.nextBool() ? 1.0 : -1.0;
    _useCircularMotion = _random.nextBool();
    _useSpiral = _random.nextBool();
  }

  MagicParticle _createMagicParticle() {
    final double angle = _random.nextDouble() * pi * 2;
    final double distance = _random.nextDouble() * 300 + 50;
    final double speed = _random.nextDouble() * 0.8 + 0.3;
    final double size = _random.nextDouble() * 12 + 3;
    final double delay = _random.nextDouble() * 0.3; // Staggered appearance

    // Randomly select particle shape
    final ParticleShape shape =
        ParticleShape.values[_random.nextInt(ParticleShape.values.length)];

    return MagicParticle(
      angle: angle,
      distance: distance,
      speed: speed,
      size: size,
      color: _getMagicalColor(),
      twinkleSpeed: _random.nextDouble() * 0.15 + 0.05,
      shape: shape,
      delay: delay,
      useSpiral: _useSpiral && _random.nextBool(),
    );
  }

  MagicWand _createMagicWand() {
    final double angle = _random.nextDouble() * pi * 2;
    final double distance = _random.nextDouble() * 150 + 100;
    final double rotationSpeed = _random.nextDouble() * 5 + 2;

    return MagicWand(
      angle: angle,
      distance: distance,
      rotationSpeed: rotationSpeed,
      color: _getMagicalColor(),
      secondaryColor: _getMagicalColor(),
      wandLength: _random.nextDouble() * 40 + 60,
    );
  }

  FloatingText _createFloatingText(String text, double xOffset) {
    final double yOffset = _random.nextDouble() * 100 - 150;
    final double scale = _random.nextDouble() * 0.5 + 1.5;
    final double rotationAngle = (_random.nextDouble() * 0.2 - 0.1) * pi;

    return FloatingText(
      text: text,
      xOffset: xOffset,
      yOffset: yOffset,
      scale: scale,
      rotationAngle: rotationAngle,
      color: _getMagicalColor(),
    );
  }

  Color _getMagicalColor() {
    // Enhanced magical colors with primary, secondary and accent colors
    final baseColors = [
      _primaryColor,
      _secondaryColor,
      _accentColor,
      Colors.purple[300]!,
      Colors.pink[200]!,
      Colors.indigo[300]!,
      Colors.amber[300]!,
      Colors.teal[200]!,
      Colors.deepPurple[300]!,
      Colors.cyan[200]!,
      Colors.lightGreen[300]!,
      Colors.deepOrange[200]!,
      Colors.grey[700]!,
      Colors.red[900]!,
      Colors.blue[900]!,
      Colors.green[900]!,
      Colors.white,
    ];

    // Return a random color, occasionally with increased brightness
    final baseColor = baseColors[_random.nextInt(baseColors.length)];
    if (_random.nextDouble() > 0.7) {
      // Make some particles extra bright
      return Color.lerp(baseColor, Colors.white, 0.5)!;
    }
    return baseColor;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base content
        widget.child,

        // Overlay effect
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = _controller.value;
            final size = MediaQuery.of(context).size;
            final centerX = size.width / 2;
            final centerY = size.height / 2;

            return Stack(
              children: [
                // Background gradient overlay
                Positioned.fill(
                  child: Opacity(
                    opacity: sin(progress * pi) * 0.15,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            _primaryColor.withOpacity(0.5),
                            _secondaryColor.withOpacity(0.3),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          center: Alignment.center,
                          radius: 1.0 + sin(progress * pi * 2) * 0.2,
                        ),
                      ),
                    ),
                  ),
                ),

                // Magic particles
                ..._particles.map((particle) {
                  // Apply delay to particle appearance
                  double particleProgress = max(
                      0,
                      min(1,
                          (progress - particle.delay) / (1 - particle.delay)));

                  if (particleProgress <= 0) return const SizedBox.shrink();

                  // Fade effect
                  double opacity;
                  if (particleProgress < 0.2) {
                    opacity = particleProgress * 5; // Quick fade in
                  } else if (particleProgress > 0.8) {
                    opacity = (1 - particleProgress) * 5; // Fade out
                  } else {
                    opacity = 1.0;
                  }

                  // Movement calculation with different patterns based on randomization
                  double distance;
                  double angle = particle.angle;

                  if (particle.useSpiral) {
                    // Spiral motion
                    distance = particle.distance * particleProgress;
                    angle = particle.angle +
                        (particleProgress * pi * 2 * _rotationDirection);
                  } else if (_useCircularMotion) {
                    // Circular motion
                    distance = particle.distance;
                    angle = particle.angle +
                        (particleProgress * pi * _rotationDirection);
                  } else {
                    // Standard outward motion
                    distance = particle.distance * particleProgress;
                  }

                  final x = cos(angle) * distance;
                  final y = sin(angle) * distance;

                  // Twinkle effect with randomized speed
                  final twinkle =
                      sin(particleProgress * 15 * particle.twinkleSpeed) * 0.5 +
                          0.5;

                  // Scale effect
                  final scale =
                      particle.size * (1.0 + sin(particleProgress * pi) * 0.3);

                  return Positioned(
                    left: centerX + x - (scale / 2),
                    top: centerY + y - (scale / 2),
                    child: Opacity(
                      opacity: opacity * twinkle,
                      child: _buildParticleShape(particle, scale),
                    ),
                  );
                }).toList(),

                // Magic wands
                ..._magicWands.map((wand) {
                  // Movement calculation
                  final wandProgress = progress;
                  final wandDistance = wand.distance * sin(wandProgress * pi);
                  final wandX = cos(wand.angle) * wandDistance;
                  final wandY = sin(wand.angle) * wandDistance;

                  // Rotation based on progress
                  final rotation = wandProgress *
                      pi *
                      wand.rotationSpeed *
                      _rotationDirection;

                  return Positioned(
                    left: centerX + wandX,
                    top: centerY + wandY,
                    child: Opacity(
                      opacity: sin(wandProgress * pi),
                      child: Transform.rotate(
                        angle: rotation,
                        child: _buildMagicWand(wand),
                      ),
                    ),
                  );
                }).toList(),

                // Floating celebration texts
                ..._floatingTexts.map((text) {
                  // Text appears in sequence
                  final textProgress =
                      max(0, min(1, progress * 3 - text.xOffset.abs() / 100));

                  if (textProgress <= 0) return const SizedBox.shrink();

                  // Movement calculation
                  final textY = text.yOffset + (textProgress * 50);

                  return Positioned(
                    left: centerX + text.xOffset - 75,
                    top: centerY + textY,
                    child: Opacity(
                      opacity: sin(textProgress * pi),
                      child: Transform.rotate(
                        angle: text.rotationAngle,
                        child: Transform.scale(
                          scale: text.scale *
                              (1.0 + sin(textProgress * pi * 2) * 0.1),
                          child: SizedBox(
                            width: 150,
                            child: Text(
                              text.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: text.color,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: text.color.withOpacity(0.7),
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),

                /* Center sparkle effect
                Positioned(
                  left: centerX - 40,
                  top: centerY - 40,
                  child: Opacity(
                    opacity: (sin(progress * pi * 3) * 0.8).clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: progress * pi * 4 * _rotationDirection,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _accentColor,
                              Colors.white.withOpacity(0.8),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.2, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),*/

                // Scale animation for main content
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Transform.scale(
                        scale: 1.0 + sin(progress * pi) * 0.1,
                        child: Container(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildParticleShape(MagicParticle particle, double size) {
    switch (particle.shape) {
      case ParticleShape.circle:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: particle.color,
            boxShadow: [
              BoxShadow(
                color: particle.color.withOpacity(0.8),
                blurRadius: size * 2,
                spreadRadius: size / 2,
              ),
            ],
          ),
        );

      case ParticleShape.star:
        return CustomPaint(
          size: Size(size, size),
          painter: StarPainter(
            color: particle.color,
            points: 5,
          ),
        );

      case ParticleShape.heart:
        return CustomPaint(
          size: Size(size, size),
          painter: HeartPainter(
            color: particle.color,
          ),
        );

      case ParticleShape.sparkle:
        return CustomPaint(
          size: Size(size, size),
          painter: SparklePainter(
            color: particle.color,
            rotation: particle.angle,
          ),
        );
    }
  }

  Widget _buildMagicWand(MagicWand wand) {
    return SizedBox(
      width: wand.wandLength,
      height: 20,
      child: Stack(
        children: [
          // Wand stick
          Positioned(
            left: 20,
            top: 8,
            child: Container(
              width: wand.wandLength - 20,
              height: 4,
              decoration: BoxDecoration(
                color: wand.color,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: wand.color.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),

          // Wand star tip
          Positioned(
            left: 0,
            top: 0,
            child: CustomPaint(
              size: const Size(20, 20),
              painter: StarPainter(
                color: wand.secondaryColor,
                points: 5,
              ),
            ),
          ),

          // Magic sparkle at tip
          Positioned(
            left: 5,
            top: 5,
            width: 10,
            height: 10,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final sparkleOpacity = sin(_controller.value * 10) * 0.5 + 0.5;
                return Opacity(
                  opacity: sparkleOpacity,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.8),
                      boxShadow: [
                        BoxShadow(
                          color: wand.secondaryColor.withOpacity(0.8),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

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
