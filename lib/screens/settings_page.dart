import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import '../models/operations_settings.dart';
import '../models/subject.dart';

class SettingsPage extends StatefulWidget {
  final Subject subject;
  final OperationSettings initialSettings;
  final Function(OperationSettings) onSettingsChanged;

  const SettingsPage({
    Key? key,
    required this.subject,
    required this.initialSettings,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late OperationSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres - ${widget.subject.name}'),
        backgroundColor: widget.subject.color,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDifficultySettings(),
          const Divider(height: 32.0),
          _buildTimerSettings(),
          const Divider(height: 32.0),
          if (widget.subject.type == SubjectType.tables || 
              widget.subject.type == SubjectType.multiplication)
            _buildTablesNumberSelector(),
          if (widget.subject.type != SubjectType.tables)
            _buildOperationModeSettings(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.onSettingsChanged(_settings);
          Navigator.pop(context);
        },
        backgroundColor: widget.subject.color,
        child: const Icon(Icons.check),
      ),
    );
  }

  Widget _buildDifficultySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Difficulté',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          title: const Text('Mode difficile'),
          subtitle: const Text('Utilise des nombres plus grands'),
          value: _settings.isHardMode,
          activeColor: widget.subject.color,
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(isHardMode: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildTimerSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timer',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text('Temps d\'attente avant la réponse (en secondes):'),
        Slider(
          value: _settings.waitingTime.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: _settings.waitingTime.toString(),
          activeColor: widget.subject.color,
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(waitingTime: value.round());
            });
          },
        ),
        Center(
          child: Text(
            '${_settings.waitingTime} secondes',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTablesNumberSelector() {
    // Cette partie est spécifique aux tables de multiplication
    const List<int> availableNumbers = [0, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Table à travailler',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text('0 = Toutes les tables mélangées'),
        Wrap(
          spacing: 8.0,
          children: availableNumbers.map((number) {
            return ChoiceChip(
              label: Text(number.toString()),
              selected: _settings.selectedNumber == number,
              selectedColor: widget.subject.color.withOpacity(0.5),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _settings = _settings.copyWith(selectedNumber: number);
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOperationModeSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type d\'opérations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          title: const Text('Opérations simples'),
          subtitle: const Text('Calculs avec des petits nombres'),
          value: _settings.simpleMode,
          activeColor: widget.subject.color,
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(simpleMode: value ?? true);
              // S'assurer qu'au moins un mode est sélectionné
              if (!(_settings.simpleMode || _settings.multiDigitMode || _settings.decimalMode)) {
                _settings = _settings.copyWith(simpleMode: true);
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Opérations à plusieurs chiffres'),
          subtitle: const Text('Calculs avec des nombres plus grands'),
          value: _settings.multiDigitMode,
          activeColor: widget.subject.color,
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(multiDigitMode: value);
            });
          },
        ),
        if (widget.subject.type == SubjectType.addition || widget.subject.type == SubjectType.soustraction)
          CheckboxListTile(
            title: const Text('Opérations décimales'),
            subtitle: const Text('Calculs avec des nombres décimaux'),
            value: _settings.decimalMode,
            activeColor: widget.subject.color,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(decimalMode: value);
              });
            },
          ),
      ],
    );
  }
}
/*class SettingsPage extends StatefulWidget {
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
*/