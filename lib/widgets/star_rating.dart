import 'package:flutter/material.dart';

// Updated star rating widget
class StarRating extends StatelessWidget {
  final int score;
  final int maxStars;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const StarRating({
    Key? key,
    required this.score,
    this.maxStars = 5,
    this.size = 24.0,
    this.activeColor = Colors.amber, // Default to standard yellow/amber
    this.inactiveColor = Colors.grey, // Grey for unfilled stars
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int filledStars = (score * maxStars / 100).round();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        // Simple approach: filled stars are amber/yellow, unfilled are grey
        final bool isFilled = index < filledStars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Icon(
            Icons.star,
            size: size,
            color: isFilled ? activeColor : inactiveColor,
          ),
        );
      }),
    );
  }
}
