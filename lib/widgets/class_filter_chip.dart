import 'package:flutter/material.dart';

class ClassFilterChip extends StatelessWidget {
  final String level;
  final bool isSelected;
  final Function(bool) onSelected;

  const ClassFilterChip({
    Key? key,
    required this.level,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(level),
        selected: isSelected,
        selectedColor: Colors.amber.shade200,
        backgroundColor: Colors.grey.shade100,
        checkmarkColor: Colors.indigo,
        labelStyle: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.indigo : Colors.black87,
        ),
        onSelected: onSelected,
      ),
    );
  }
}
