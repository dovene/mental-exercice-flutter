import 'package:flutter/material.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;
  final Animation<double> animation;

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '$score',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}