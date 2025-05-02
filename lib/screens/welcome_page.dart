import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/subject.dart';
import '../services/database_helper.dart';
import 'exercise_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  // Filter options
  String _selectedClassLevel = "Tous";
  List<String> _classLevels = ["Tous", "CP", "CE1", "CE2", "CM1", "CM2"];

  // Animation
  late AnimationController _animationController;

  // Stats for subjects
  Map<SubjectType, Map<String, dynamic>> _subjectStats = {};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _loadAllSubjectStats();
  }

  Future<void> _loadAllSubjectStats() async {
    setState(() {
      _isLoadingStats = true;
    });
    try {
      for (var subjectType in SubjectType.values) {
        final stats =
            await DatabaseHelper.instance.getStats(subjectType: subjectType);
        setState(() {
          _subjectStats[subjectType] = stats;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: \$e');
    } finally {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Return different emojis based on score, with a special hug emoji for zero
  String _getAchievementEmoji(int score) {
    if (score == 0) return '🤞';
    if (score >= 90) return '🌟';
    if (score >= 80) return '🎉';
    if (score >= 70) return '😊';
    if (score >= 50) return '🙂';
    return '💪';
  }

  @override
  Widget build(BuildContext context) {
    final subjects = Subject.getAllSubjects();
    final filteredSubjects = _selectedClassLevel == "Tous"
        ? subjects
        : subjects
            .where((s) => s.classLevels.contains(_selectedClassLevel))
            .toList();

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(screenSize),
                _buildFilterSection(),
                Expanded(
                  child: _buildSubjectGrid(filteredSubjects),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPainter(_animationController.value),
          child: Container(),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }

  Widget _buildHeader(Size screenSize) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.03),
      child: Column(
        children: [
          const Text(
            'Math Pour Enfants',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 100,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Les maths, c\'est fun et j\'adore ❤️',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choisis ta classe:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _classLevels
                  .map((level) => _buildClassFilterChip(level))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectGrid(List<Subject> subjects) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        return _buildSubjectCard(subjects[index]);
      },
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    final stats = _subjectStats[subject.type] ??
        {'total': 0, 'correct': 0, 'percentage': 0};
    final emoji = _getAchievementEmoji(stats['percentage'] as int);

    return GestureDetector(
      onTap: () => _navigateToExercise(subject),
      child: Card(
        elevation: 5,
        shadowColor: subject.color.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [subject.color.withOpacity(0.7), subject.color],
                    ),
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ...List.generate(
                          3,
                          (i) => Positioned(
                            left: 20.0 * i,
                            top: 15.0 * i,
                            child: Opacity(
                              opacity: 0.2,
                              child: Transform.rotate(
                                angle: 0.2 * i,
                                child: Icon(subject.icon,
                                    size: (40 - 5 * i).toDouble(),
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _animationController.value * 2 * math.pi,
                              child: Icon(subject.icon,
                                  size: 40, color: Colors.white),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          subject.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (emoji != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassFilterChip(String level) {
    final isSelected = _selectedClassLevel == level;
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
        onSelected: (bool selected) {
          setState(() {
            _selectedClassLevel = selected ? level : "Tous";
          });
        },
      ),
    );
  }

  void _navigateToExercise(Subject subject) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExercisePage(subject: subject)),
    ).then((_) => _loadAllSubjectStats());
  }
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;
  BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 10; i++) {
      final offset = i * 0.1;
      final position = (animationValue + offset) % 1.0;
      final x = size.width * (0.1 + position * 0.8);
      final y = size.height * (0.1 + math.sin(position * math.pi) * 0.8);
      final radius = size.width * 0.03 +
          size.width * 0.02 * math.sin(position * math.pi * 2);
      switch (i % 4) {
        case 0:
          paint.color = Colors.blue.withOpacity(0.1);
          canvas.drawCircle(Offset(x, y), radius, paint);
          paint.color = Colors.blue.withOpacity(0.2);
          canvas.drawRect(
              Rect.fromCenter(
                  center: Offset(x, y),
                  width: radius * 0.6,
                  height: radius * 2),
              paint);
          canvas.drawRect(
              Rect.fromCenter(
                  center: Offset(x, y),
                  width: radius * 2,
                  height: radius * 0.6),
              paint);
          break;
        case 1:
          paint.color = Colors.red.withOpacity(0.1);
          canvas.drawCircle(Offset(x, y), radius, paint);
          paint.color = Colors.red.withOpacity(0.2);
          canvas.drawCircle(Offset(x, y), radius * 0.7, paint);
          break;
        case 2:
          paint.color = Colors.green.withOpacity(0.1);
          canvas.drawCircle(Offset(x, y), radius, paint);
          paint.color = Colors.green.withOpacity(0.2);
          canvas.drawRect(
              Rect.fromCenter(
                  center: Offset(x, y),
                  width: radius * 2,
                  height: radius * 0.6),
              paint);
          break;
        case 3:
          paint.color = Colors.purple.withOpacity(0.1);
          canvas.drawCircle(Offset(x, y), radius, paint);
          paint.color = Colors.purple.withOpacity(0.2);
          canvas.save();
          canvas.translate(x, y);
          canvas.rotate(math.pi / 4);
          canvas.drawRect(
              Rect.fromCenter(
                  center: Offset.zero, width: radius * 0.6, height: radius * 2),
              paint);
          canvas.drawRect(
              Rect.fromCenter(
                  center: Offset.zero, width: radius * 2, height: radius * 0.6),
              paint);
          canvas.restore();
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
