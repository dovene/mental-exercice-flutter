import 'package:flutter/material.dart';

import '../models/exercise_history.dart';
import '../services/database_helper.dart';

import 'package:flutter/material.dart';
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
      final history = await DatabaseHelper.instance.getHistory(subjectType: widget.subjectType);
      final stats = await DatabaseHelper.instance.getStats(subjectType: widget.subjectType);
      
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
        content: Text('Êtes-vous sûr de vouloir effacer tout l\'historique pour ${Subject.getSubjectByType(widget.subjectType).name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper.instance.clearHistory(subjectType: widget.subjectType);
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
        title: Text('Historique - ${subject.name}'),
        backgroundColor: subject.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
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
                  ? const Center(child: Text('Aucun exercice dans l\'historique'))
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
          style: valueStyle ?? const TextStyle(
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Réponse: ${item.givenAnswer} (${item.isCorrect ? 'Correct' : 'Incorrect: ${item.getCorrectAnswer()}'})'
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

/*
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Future<List<ExerciseHistory>>? _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = DatabaseHelper.instance.getHistory();
    });
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer l\'historique'),
        content: const Text('Voulez-vous vraiment effacer tout l\'historique ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.clearHistory();
      _refreshHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: FutureBuilder<List<ExerciseHistory>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Pas encore d\'historique'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final exercise = snapshot.data![index];
              return ListTile(
                leading: Icon(
                  exercise.isCorrect ? Icons.check_circle : Icons.cancel,
                  color: exercise.isCorrect ? Colors.green : Colors.red,
                ),
                title: Text(
                  '${exercise.number1} × ${exercise.number2} = ${exercise.givenAnswer}',
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  'Le ${exercise.date.day}/${exercise.date.month}/${exercise.date.year}',
                ),
                trailing: Text(
                  exercise.isCorrect ? '+10 points' : '0 point',
                  style: TextStyle(
                    color: exercise.isCorrect ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
*/