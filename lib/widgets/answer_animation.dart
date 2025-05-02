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
      duration:
          const Duration(milliseconds: 1500), // Shorter duration (1.5 seconds)
    )..forward();

    // Generate more varied firework particles
    _particles = List.generate(150, (_) => _createParticle());
  }

  Particle _createParticle() {
    final double angle = _random.nextDouble() * pi * 2;
    final double distance = _random.nextDouble() * 150 + 50;
    final double speed = _random.nextDouble() * 0.7 + 0.5;
    final double size = _random.nextDouble() * 8 + 2;

    // Create a more interesting particle with twinkle effect
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
    // Brighter colors for fireworks/stars
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Background particles (fireworks/stars)
            ..._particles.map((particle) {
              final progress = _controller.value;

              // Make the particles appear and disappear with a nice fade
              double fadeInOut;
              if (progress < 0.1) {
                fadeInOut = progress * 10;
              } else if (progress > 0.7) {
                fadeInOut = 1.0 - (progress - 0.7) / 0.3;
              } else {
                fadeInOut = 1.0;
              }

              // Ensure fadeInOut is between 0 and 1
              fadeInOut = fadeInOut.clamp(0.0, 1.0);

              // Movement with easing
              final movement = Curves.easeOutQuart.transform(progress);

              // Calculate position with curved motion
              final x = cos(particle.angle) * particle.distance * movement;
              final y = sin(particle.angle) * particle.distance * movement;

              // Twinkle effect (pulsing size/opacity)
              final twinkle =
                  0.5 + 0.5 * sin(progress / particle.twinkleSpeed * 10);

              // Calculate final opacity and ensure it's valid
              final finalOpacity =
                  (fadeInOut * (0.5 + 0.5 * twinkle)).clamp(0.0, 1.0);

              return Positioned(
                left: MediaQuery.of(context).size.width / 2 + x,
                top: MediaQuery.of(context).size.height / 2 + y,
                child: Opacity(
                  opacity: finalOpacity,
                  child: Container(
                    width: particle.size * (0.8 + 0.2 * twinkle),
                    height: particle.size * (0.8 + 0.2 * twinkle),
                    decoration: BoxDecoration(
                      color: particle.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: particle.color.withOpacity(0.5),
                          blurRadius: 3,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Main content with scale and rotation animation
            Center(
              child: Transform.scale(
                scale: 1.0 + sin(progress * pi) * 0.1, // Gentle bounce
                child: widget.child,
              ),
            ),
          ],
        );
      },
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

    // Create more engaging shake animation
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

    // Add pulse animation for more visual feedback
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

    // Start animation once
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
            // Red overlay with pulsing opacity for better effect
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
  final double twinkleSpeed; // Controls how fast the star twinkles

  Particle({
    required this.angle,
    required this.distance,
    required this.speed,
    required this.size,
    required this.color,
    required this.twinkleSpeed,
  });
}
