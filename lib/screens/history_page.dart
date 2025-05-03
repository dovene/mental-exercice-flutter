import 'package:flutter/material.dart';

import '../models/exercise_history.dart';
import '../services/database_helper.dart';
import '../models/subject.dart';

class HistoryPage extends StatefulWidget {
  final SubjectType subjectType;

  const HistoryPage({Key? key, required this.subjectType}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<ExerciseHistory> _history = [];
  bool _isLoading = true;
  Map<String, dynamic> _stats = {
    'total': 0,
    'correct': 0,
    'percentage': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final history = await DatabaseHelper.instance
          .getHistory(subjectType: widget.subjectType);
      final stats = await DatabaseHelper.instance
          .getStats(subjectType: widget.subjectType);

      setState(() {
        _history = history;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer l\'historique'),
        content: Text(
            'Êtes-vous sûr de vouloir effacer tout l\'historique pour ${Subject.getSubjectByType(widget.subjectType).name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper.instance
                  .clearHistory(subjectType: widget.subjectType);
              _loadHistory();
            },
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subject = Subject.getSubjectByType(widget.subjectType);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: subject.color,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _history.isEmpty ? null : _clearHistory,
            tooltip: 'Effacer l\'historique',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsCard(),
                Expanded(
                  child: _history.isEmpty
                      ? const Center(
                          child: Text('Aucun exercice dans l\'historique'))
                      : _buildHistoryList(),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsCard() {
    final correctCount = _stats['correct'] as int;
    final totalCount = _stats['total'] as int;
    final percentage = _stats['percentage'] as int;
    final subject = Subject.getSubjectByType(widget.subjectType);

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Score',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: subject.color,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', totalCount.toString()),
                _buildStatItem('Corrects', correctCount.toString()),
                _buildStatItem(
                  'Taux de réussite',
                  '$percentage%',
                  TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getColorForPercentage(percentage),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, [TextStyle? valueStyle]) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: valueStyle ??
              const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Color _getColorForPercentage(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        return _buildHistoryItem(item);
      },
    );
  }

  Widget _buildHistoryItem(ExerciseHistory item) {
    // final dateFormat = DateFormat('dd/MM HH:mm');
    final subject = Subject.getSubjectByType(widget.subjectType);
    final givenAnswerString =
        'Réponse: ${item.givenAnswer.isEmpty ? 'Aucune réponse' : item.givenAnswer}';
    final correctAnswerString = 'Bonne réponse: ${item.getCorrectAnswer()}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.isCorrect ? Colors.green : Colors.red,
          child: Icon(
            item.isCorrect ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text(
          item.getOperationText(),
          style: TextStyle(
            fontSize: subject.type != SubjectType.problemes ? 16 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: givenAnswerString,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 105, 103, 103),
                ),
              ),
              TextSpan(
                text: '\n$correctAnswerString',
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        trailing: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: subject.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(subject.icon, color: subject.color),
        ),
      ),
    );
  }
}
