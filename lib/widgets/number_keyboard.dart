import 'package:flutter/material.dart';

// Custom widget for the number keyboard
class NumberKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final Function() onSubmit;
  final Function() onDelete;
  final String currentInput;
  final bool decimalMode; // Added parameter for decimal mode

  const NumberKeyboard({
    super.key,
    required this.onKeyPressed,
    required this.onSubmit,
    required this.onDelete,
    required this.currentInput,
    required this.decimalMode, // Required parameter
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Input display
        Container(
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentInput,
                style: const TextStyle(fontSize: 20),
              ),
              IconButton(
                icon: const Icon(Icons.backspace, size: 20), // Smaller size
                onPressed: onDelete,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Number pad
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            for (int i = 1; i <= 9; i++)
              SizedBox(
                width: 60,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => onKeyPressed(i.toString()),
                  child: Text(
                    i.toString(),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            SizedBox(
              width: 60,
              height: 60,
              child: ElevatedButton(
                onPressed: () => onKeyPressed('0'),
                child: const Text(
                  '0',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            // Decimal point button only visible in decimal mode
            if (decimalMode)
              SizedBox(
                width: 60,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => onKeyPressed('.'),
                  child: const Text(
                    '.',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Submit button
        SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text(
              'Répondre',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
