import 'dart:math';

import 'package:flutter/material.dart';
// Updated animations and star rating
import 'dart:math';
import 'package:flutter/material.dart';

class CorrectAnswerAnimation extends StatefulWidget {
  final Widget child;

  const CorrectAnswerAnimation({Key? key, required this.child})
      : super(key: key);

  @override
  _CorrectAnswerAnimationState createState() => _CorrectAnswerAnimationState();
}

class _CorrectAnswerAnimationState extends State<CorrectAnswerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    // Generate firework/star particles
    _particles = List.generate(150, (_) => _createParticle());
  }

  Particle _createParticle() {
    final double angle = _random.nextDouble() * pi * 2;
    final double distance = _random.nextDouble() * 150 + 50;
    final double speed = _random.nextDouble() * 0.7 + 0.5;
    final double size = _random.nextDouble() * 8 + 2;

    // Create particle with twinkle effect
    return Particle(
      angle: angle,
      distance: distance,
      speed: speed,
      size: size,
      color: _getRandomColor(),
      twinkleSpeed: _random.nextDouble() * 0.1 + 0.05,
    );
  }

  Color _getRandomColor() {
    // Bright, celebratory colors for fireworks
    final colors = [
      Colors.yellow,
      Colors.amber,
      Colors.orangeAccent,
      Colors.pinkAccent,
      Colors.purpleAccent,
      Colors.lightBlueAccent,
      Colors.greenAccent,
      Colors.white,
    ];

    return colors[_random.nextInt(colors.length)];
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

        // Fireworks overlay
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Particles layer
                ..._particles.map((particle) {
                  final progress = _controller.value;

                  // Fade effect
                  double opacity;
                  if (progress < 0.2) {
                    opacity = progress * 5; // Quick fade in
                  } else if (progress > 0.8) {
                    opacity = (1 - progress) * 5; // Fade out
                  } else {
                    opacity = 1.0;
                  }

                  // Movement calculation
                  final distance = particle.distance * progress;
                  final x = cos(particle.angle) * distance;
                  final y = sin(particle.angle) * distance;

                  // Twinkle effect
                  final twinkle =
                      sin(progress * 10 * particle.twinkleSpeed) * 0.5 + 0.5;

                  return Positioned(
                    left: MediaQuery.of(context).size.width / 2 +
                        x -
                        (particle.size / 2),
                    top: MediaQuery.of(context).size.height / 2 +
                        y -
                        (particle.size / 2),
                    child: Opacity(
                      opacity: opacity * twinkle,
                      child: Container(
                        width: particle.size,
                        height: particle.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: particle.color,
                          boxShadow: [
                            BoxShadow(
                              color: particle.color.withOpacity(0.8),
                              blurRadius: particle.size * 2,
                              spreadRadius: particle.size / 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

                // Scale animation for main content
                Positioned.fill(
                  child: Center(
                    child: Transform.scale(
                      scale: 1.0 + sin(progress * pi) * 0.1,
                      child: Container(),
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

  double get progress => _controller.value;
}

class IncorrectAnswerAnimation extends StatefulWidget {
  final Widget child;

  const IncorrectAnswerAnimation({Key? key, required this.child})
      : super(key: key);

  @override
  _IncorrectAnswerAnimationState createState() =>
      _IncorrectAnswerAnimationState();
}

class _IncorrectAnswerAnimationState extends State<IncorrectAnswerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _shakeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Enhanced shake animation with smoother transitions
    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(-0.05, 0.0)),
        weight: 16.0,
      ),
      TweenSequenceItem(
        tween: Tween(
            begin: const Offset(-0.05, 0.0), end: const Offset(0.05, 0.0)),
        weight: 17.0,
      ),
      TweenSequenceItem(
        tween: Tween(
            begin: const Offset(0.05, 0.0), end: const Offset(-0.04, 0.0)),
        weight: 16.0,
      ),
      TweenSequenceItem(
        tween: Tween(
            begin: const Offset(-0.04, 0.0), end: const Offset(0.04, 0.0)),
        weight: 17.0,
      ),
      TweenSequenceItem(
        tween: Tween(
            begin: const Offset(0.04, 0.0), end: const Offset(-0.02, 0.0)),
        weight: 17.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-0.02, 0.0), end: Offset.zero),
        weight: 17.0,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Add subtle pulse animation for enhanced visual feedback
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.05),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0),
        weight: 50.0,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Subtle red overlay with pulsing opacity
            Positioned.fill(
              child: Opacity(
                opacity:
                    (0.1 + (_pulseAnimation.value - 1.0) * 0.2).clamp(0.0, 1.0),
                child: Container(color: Colors.red),
              ),
            ),

            // Combined shaking and pulsing animation
            SlideTransition(
              position: _shakeAnimation,
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: widget.child,
              ),
            ),
          ],
        );
      },
    );
  }
}

class Particle {
  final double angle;
  final double distance;
  final double speed;
  final double size;
  final Color color;
  final double twinkleSpeed;

  Particle({
    required this.angle,
    required this.distance,
    required this.speed,
    required this.size,
    required this.color,
    required this.twinkleSpeed,
  });
}
