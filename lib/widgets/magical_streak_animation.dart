import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../helper/app_constants.dart';
import 'magic_animation_particles.dart';

class MagicalStreakAnimation extends StatefulWidget {
  final Widget child;

  const MagicalStreakAnimation({Key? key, required this.child})
      : super(key: key);

  @override
  MagicalStreakAnimationState createState() => MagicalStreakAnimationState();
}

class MagicalStreakAnimationState extends State<MagicalStreakAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<MagicParticle> _particles;
  late List<MagicWand> _magicWands;
  late List<FloatingText> _floatingTexts;
  final Random _random = Random();

  // Store the 5 randomly selected particle shapes for this animation
  late List<ParticleShape> _selectedShapes;

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
      duration:
          const Duration(milliseconds: AppConstants.magicAnimationDuration),
    )..forward();

    // Randomize theme elements
    _randomizeTheme();

    // Select 5 random shapes from the ParticleShape enum for this animation instance
    _selectedShapes = _selectRandomShapes();

    // Generate magical particles immediately with no delay
    _particles =
        List.generate(_random.nextInt(200) + 50, (_) => _createMagicParticle());

    // Generate magic wands
    _magicWands =
        List.generate(_random.nextInt(3) + 1, (_) => _createMagicWand());

    // Create floating celebration texts
    _floatingTexts = [
      _createFloatingText("Champion!", -100),
      _createFloatingText("Génial!", 0),
      _createFloatingText("Brilliant!", 100),
    ];
  }

  // Method to randomly select 5 unique particle shapes
  List<ParticleShape> _selectRandomShapes() {
    // Get all available shape options
    final List<ParticleShape> allShapes = ParticleShape.values.toList();
    // Shuffle to randomize
    allShapes.shuffle(_random);
    // Return the first 5 items
    return allShapes.take(5).toList();
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
      // Nature-themed color schemes for animals and birds
      [Colors.green[400]!, Colors.brown[300]!, Colors.lightBlue[300]!],
      [Colors.teal[300]!, Colors.lime[200]!, Colors.orange[300]!],
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

    // No delay for instant appearance
    final double delay = 0.0;

    // Randomly select one of the 5 pre-selected shapes for this animation
    final ParticleShape shape =
        _selectedShapes[_random.nextInt(_selectedShapes.length)];

    // Calculate the appropriate size for animals and birds (larger than regular particles)
    double adjustedSize = size;
    if (shape == ParticleShape.bird ||
        shape == ParticleShape.butterfly ||
        shape == ParticleShape.fish ||
        shape == ParticleShape.rabbit) {
      adjustedSize = size * 2.5; // Make animals and birds larger
    }

    return MagicParticle(
      angle: angle,
      distance: distance,
      speed: speed,
      size: adjustedSize,
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
      // More natural colors for animals and birds
      Colors.brown[300]!,
      Colors.orange[300]!,
      Colors.lightBlue[300]!,
      Colors.green[400]!,
      Colors.redAccent[200]!,
      //Colors.grey[700]!,
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

                // Magic particles - IMMEDIATE VISIBILITY
                ..._particles.map((particle) {
                  double particleProgress = progress;

                  // Fade effect
                  double opacity;
                  if (particleProgress < 0.1) {
                    opacity = particleProgress * 10; // Very quick fade in
                  } else if (particleProgress > 0.8) {
                    opacity = (1 - particleProgress) * 5; // Fade out
                  } else {
                    opacity = 1.0;
                  }

                  // Movement calculation with different patterns
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

                  // Add flutter movement for birds and butterflies
                  double xOffset = 0;
                  double yOffset = 0;
                  double rotation = 0;

                  final x = cos(angle) * distance + xOffset;
                  final y = sin(angle) * distance + yOffset;

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
                      child: Transform.rotate(
                        angle: rotation,
                        child: _buildParticleShape(particle, scale),
                      ),
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
                  // Text appears in sequence - IMMEDIATE VISIBILITY
                  final textProgress = progress;

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

                // Center sparkle effect
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
                ),

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

      case ParticleShape.bird:
        return CustomPaint(
          size: Size(size, size),
          painter: BirdPainter(
            color: particle.color,
            wingPosition: particle.angle,
          ),
        );

      case ParticleShape.butterfly:
        return CustomPaint(
          size: Size(size, size),
          painter: ButterflyPainter(
            color: particle.color,
            wingPosition: particle.angle,
          ),
        );

      case ParticleShape.fish:
        return CustomPaint(
          size: Size(size, size),
          painter: FishPainter(
            color: particle.color,
            tailPosition: 1,
          ),
        );

      case ParticleShape.rabbit:
        return CustomPaint(
          size: Size(size, size),
          painter: RabbitPainter(
            color: particle.color,
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
