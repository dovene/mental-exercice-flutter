import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learning/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercise_history.dart';
class SettingsPage extends StatefulWidget {
  final int initialTable;
  final int initialTime;
  final Function(int, int) onSettingsChanged;

  const SettingsPage({
    super.key,
    required this.initialTable,
    required this.initialTime,
    required this.onSettingsChanged,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late int _table;
  late int _time;

  @override
  void initState() {
    super.initState();
    _table = widget.initialTable;
    _time = widget.initialTime;
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedTable', _table);
    await prefs.setInt('waitingTime', _time);
    widget.onSettingsChanged(_table, _time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Table à réviser :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<int>(
              value: _table,
              items: [
                const DropdownMenuItem(value: 0, child: Text('Toutes les tables')),
                ...List.generate(8, (index) =>
                    DropdownMenuItem(value: index + 2, child: Text('Table de ${index + 2}'))
                ),
              ],
              onChanged: (value) {
                setState(() => _table = value!);
                _saveSettings();
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Temps de réponse (secondes) :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _time.toDouble(),
              min: 3,
              max: 10,
              divisions: 7,
              label: _time.toString(),
              onChanged: (value) {
                setState(() => _time = value.round());
                _saveSettings();
              },
            ),
            Text(
              'Temps actuel : $_time secondes',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

