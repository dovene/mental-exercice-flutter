import 'package:flutter/material.dart';

class CountdownTimer extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;

  const CountdownTimer({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Temps restant: $remainingSeconds s',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: remainingSeconds / totalSeconds,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            remainingSeconds < 3 ? Colors.red : Colors.blue,
          ),
        ),
      ],
    );
  }
}