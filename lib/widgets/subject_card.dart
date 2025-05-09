import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/subject.dart';
import '../providers/subscription_provider.dart';
import '../screens/subscription_page.dart';
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

  // Add to SubjectCard class
  Widget build(BuildContext context) {
    final emoji = _getAchievementEmoji(stats['percentage'] as int);
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final isLocked = !subscriptionProvider
        .isSubjectUnlocked(subject.type.toString().toLowerCase());

    return Hero(
      tag: 'subject-${subject.type}',
      child: GestureDetector(
        onTap: isLocked ? () => _showSubscriptionDialog(context) : onTap,
        child: Card(
          elevation: 5,
          shadowColor: subject.color.withOpacity(0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Column(
                  children: [
                    // Existing content
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              subject.color.withOpacity(0.7),
                              subject.color
                            ],
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

                // Lock overlay for premium content
                if (isLocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 36,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Premium',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Content'),
        content: const Text(
            'This subject is only available with a premium subscription. Would you like to view subscription options?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionPage(),
                ),
              );
            },
            child: const Text('View Plans'),
          ),
        ],
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
