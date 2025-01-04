import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final int initialTable;
  final int initialTime;
  // Update the callback to also include the bool isHardMode
  final Function(int table, int time, bool isHardMode) onSettingsChanged;

  const SettingsPage({
    Key? key,
    required this.initialTable,
    required this.initialTime,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late int _table;
  late int _time;

  // Add a bool for Hard mode
  bool _isHardMode = false;

  @override
  void initState() {
    super.initState();
    _table = widget.initialTable;
    _time = widget.initialTime;
    _loadHardMode(); // load the boolean from SharedPreferences
  }

  Future<void> _loadHardMode() async {
    final prefs = await SharedPreferences.getInstance();
    // If it's never been stored, default = false (Easy mode)
    setState(() {
      _isHardMode = prefs.getBool('isHardMode') ?? false;
    });
  }

  // Save all settings (table, time, and isHardMode)
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedTable', _table);
    await prefs.setInt('waitingTime', _time);
    await prefs.setBool('isHardMode', _isHardMode);

    widget.onSettingsChanged(_table, _time, _isHardMode);
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
                const DropdownMenuItem(
                  value: 0,
                  child: Text('Toutes les tables'),
                ),
                ...List.generate(8, (index) {
                  final tableNumber = index + 2; // 2..9
                  return DropdownMenuItem(
                    value: tableNumber,
                    child: Text('Table de $tableNumber'),
                  );
                }),
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
            const SizedBox(height: 20),
            const Text(
              'Niveau de difficulté :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Mode difficile'),
              subtitle: const Text('Ignorer les facteurs < 4'),
              value: _isHardMode,
              onChanged: (value) {
                setState(() => _isHardMode = value);
                _saveSettings();
              },
            ),
          ],
        ),
      ),
    );
  }
}
