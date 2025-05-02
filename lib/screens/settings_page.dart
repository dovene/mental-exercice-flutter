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
          _buildSettingsCard(
            title: 'Difficulté',
            children: [
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
          ),
          const SizedBox(height: 16),
          _buildSettingsCard(
            title: 'Timer',
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Temps d\'attente avant la réponse (en secondes):'),
              ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '${_settings.waitingTime} secondes',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.subject.type == SubjectType.tables)
            _buildTablesNumberSelector(),
          if (widget.subject.type != SubjectType.tables)
            _buildOperationModeSettings(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.onSettingsChanged(_settings);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.subject.color,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: const Text(
              'Enregistrer les paramètres',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSettingsCard(
      {required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.subject.color,
              ),
            ),
          ),
          const Divider(),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
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
              if (!(_settings.simpleMode ||
                  _settings.multiDigitMode ||
                  _settings.decimalMode)) {
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
        if (widget.subject.type == SubjectType.addition ||
            widget.subject.type == SubjectType.soustraction)
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
