import 'package:flutter/material.dart';

class AchievementIndicator extends StatelessWidget {
  final int score;
  final Color color;

  const AchievementIndicator({
    Key? key,
    required this.score,
    required this.color,
  }) : super(key: key);

  String _getEmoji() {
    if (score == 0) return '🤞';
    if (score >= 90) return '🌟'; // Superstar
    if (score >= 80) return '🎉'; // Great
    if (score >= 70) return '😊'; // Good
    if (score >= 50) return '🙂'; // Keep going
    return '💪'; // Try harder
  }

  String _getMessage() {
    if (score == 0) return 'Allez commence !';
    if (score >= 90) return 'Super champion !';
    if (score >= 80) return 'Très bien !';
    if (score >= 70) return 'Bien !';
    if (score >= 50) return 'Continue !';
    return 'Courage !';
  }

  Color _getProgressColor() {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji indicator
          Text(
            _getEmoji(),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 8),

          // Progress bar and percentage
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getMessage(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 100,
                child: Stack(
                  children: [
                    // Background
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Progress
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: 8,
                      width: 100 * (score / 100),
                      decoration: BoxDecoration(
                        color: _getProgressColor(),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: _getProgressColor().withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
