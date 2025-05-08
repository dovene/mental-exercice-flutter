import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

// Custom widget for the number keyboard
class NumberKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final Function() onSubmit;
  final Function() onDelete;
  final String currentInput;
  final bool decimalMode; // Parameter for decimal mode
  final bool useFrenchLocale; // Added parameter for French locale

  const NumberKeyboard({
    super.key,
    required this.onKeyPressed,
    required this.onSubmit,
    required this.onDelete,
    required this.currentInput,
    required this.decimalMode,
    this.useFrenchLocale = true, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    // Determine the decimal separator based on locale
    final String decimalSeparator = useFrenchLocale ? ',' : '.';

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Input display row with decimal button when in decimal mode
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Input display container
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.only(left: 20, right: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        currentInput,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.backspace, size: 20),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ),
            ),
            // Decimal point/comma button in the first row
            if (decimalMode)
              Container(
                margin: const EdgeInsets.only(right: 18),
                width: 60,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => onKeyPressed(decimalSeparator),
                  child: Text(
                    decimalSeparator,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
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