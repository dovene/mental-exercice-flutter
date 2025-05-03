import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/subject.dart';
import 'animated_subject_icon';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final AnimationController animationController;
  final Map<String, dynamic> stats;
  final VoidCallback onTap;

  const SubjectCard({
    Key? key,
    required this.subject,
    required this.animationController,
    required this.stats,
    required this.onTap,
  }) : super(key: key);

  // Return different emojis based on score, with a special hug emoji for zero
  String _getAchievementEmoji(int score) {
    if (score == 0) return '🤞';
    if (score >= 90) return '🌟';
    if (score >= 80) return '🎉';
    if (score >= 70) return '😊';
    if (score >= 50) return '🙂';
    return '💪';
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _getAchievementEmoji(stats['percentage'] as int);

    return Hero(
      tag: 'subject-${subject.type}',
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 5,
          shadowColor: subject.color.withOpacity(0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [subject.color.withOpacity(0.7), subject.color],
                      ),
                    ),
                    child: Center(
                      child: AnimatedSubjectIcon(
                        icon: subject.icon,
                        animationController: animationController,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            subject.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (emoji != null) ...[
                          const SizedBox(width: 4),
                          _buildAnimatedEmoji(emoji),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedEmoji(String emoji) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + 0.2 * math.sin(animationController.value * math.pi),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 18),
          ),
        );
      },
    );
  }
}
