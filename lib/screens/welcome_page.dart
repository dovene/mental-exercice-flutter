import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../services/database_helper.dart';
import 'exercise_page.dart';
import '../widgets/animated_background.dart';
import '../widgets/subject_card.dart';
import '../widgets/class_filter_chip.dart';
import '../widgets/welcome_header.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  // Filter options
  String _selectedClassLevel = "Tous";
  List<String> _classLevels = ["Tous", "CP", "CE1", "CE2", "CM1", "CM2"];

  // Animation controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _iconAnimationController;

  // Stats for subjects
  Map<SubjectType, Map<String, dynamic>> _subjectStats = {};

  @override
  void initState() {
    super.initState();

    // Background animation controller with original slow speed
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Icon animation controller for interactive elements
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _loadAllSubjectStats();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadAllSubjectStats() async {
    setState(() {});
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
      setState(() {});
    }
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
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          SafeArea(
            child: Column(
              children: [
                WelcomeHeader(screenSize: screenSize),
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

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _classLevels
                  .map((level) => ClassFilterChip(
                        level: level,
                        isSelected: _selectedClassLevel == level,
                        onSelected: (selected) {
                          setState(() {
                            _selectedClassLevel = selected ? level : "Tous";
                          });
                        },
                      ))
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
        childAspectRatio: 0.80,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final stats = _subjectStats[subject.type] ??
            {'total': 0, 'correct': 0, 'percentage': 0};

        return SubjectCard(
          subject: subject,
          animationController: _iconAnimationController,
          stats: stats,
          onTap: () => _navigateToExercise(subject),
        );
      },
    );
  }

  void _navigateToExercise(Subject subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExercisePage(subject: subject),
        settings: RouteSettings(name: 'exercise_${subject.type}'),
      ),
    ).then((_) => _loadAllSubjectStats());
  }
}
