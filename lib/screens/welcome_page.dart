// lib/screens/welcome_page.dart
import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../services/database_helper.dart';
import 'exercise_page.dart';

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

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
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
        final stats = await DatabaseHelper.instance.getStats(subjectType: subjectType);
        setState(() {
          _subjectStats[subjectType] = stats;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
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

  @override
  Widget build(BuildContext context) {
    final subjects = Subject.getAllSubjects();
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(screenSize),
                _buildFilterSection(),
                Expanded(
                  child: _buildSubjectGrid(
                    _selectedClassLevel == "Tous" 
                      ? subjects 
                      : subjects.where((s) => s.classLevel == _selectedClassLevel).toList()
                  ),
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
            'Apprends les maths en t\'amusant !',
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
              children: _classLevels.map((level) => _buildClassFilterChip(level)).toList(),
            ),
          ),
        ],
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
    // Get stats for this subject
    final stats = _subjectStats[subject.type] ?? {'total': 0, 'correct': 0, 'percentage': 0};
    final hasStats = (stats['total'] as int) > 0;
    
    return GestureDetector(
      onTap: () => _navigateToExercise(subject),
      child: Card(
        elevation: 5,
        shadowColor: subject.color.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        subject.color.withOpacity(0.7),
                        subject.color,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Animated background shapes
                        ...List.generate(3, (i) => 
                          Positioned(
                            left: 20.0 * i,
                            top: 15.0 * i,
                            child: Opacity(
                              opacity: 0.2,
                              child: Transform.rotate(
                                angle: 0.2 * i,
                                child: Icon(
                                  subject.icon,
                                  size: (40 - (5 * i)).toDouble(),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ),
                        
                        // Main icon
                        Icon(
                          subject.icon,
                          size: 48,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        subject.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              subject.classLevel,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          if (hasStats) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getColorForPercentage(stats['percentage'] as int).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${stats['percentage']}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getColorForPercentage(stats['percentage'] as int),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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

  Color _getColorForPercentage(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  void _navigateToExercise(Subject subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExercisePage(subject: subject),
      ),
    ).then((_) {
      // Refresh stats when returning from exercise page
      _loadAllSubjectStats();
    });
  }
}

// Background painter for animated shapes
class BackgroundPainter extends CustomPainter {
  final double animationValue;
  
  BackgroundPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Draw animated shapes in the background
    for (int i = 0; i < 10; i++) {
      final offset = i * 0.1;
      final position = (animationValue + offset) % 1.0;
      
      final x = size.width * (0.1 + position * 0.8);
      final y = size.height * (0.1 + math.sin(position * math.pi) * 0.8);
      
      final radius = size.width * 0.03 + size.width * 0.02 * math.sin(position * math.pi * 2);
      
      // Alternate between math-related shapes
      switch (i % 4) {
        case 0: // Plus sign
          paint.color = Colors.blue.withOpacity(0.1);
          canvas.drawCircle(Offset(x, y), radius, paint);
          paint.color = Colors.blue.withOpacity(0.2);
          canvas.drawRect(
            Rect.fromCenter(center: Offset(x, y), width: radius * 0.6, height: radius * 2),
            paint
          );
          canvas.drawRect(
            Rect.fromCenter(center: Offset(x, y), width: radius * 2, height: radius * 0.6),
            paint
          );
          break;
        case 1: // Circle (zero)
          paint.color = Colors.red.withOpacity(0.1);
          canvas.drawCircle(Offset(x, y), radius, paint);
          paint.color = Colors.red.withOpacity(0.2);
          canvas.drawCircle(Offset(x, y), radius * 0.7, paint);
          break;
        case 2: // Minus sign
          paint.color = Colors.green.withOpacity(0.1);
          canvas.drawCircle(Offset(x, y), radius, paint);
          paint.color = Colors.green.withOpacity(0.2);
          canvas.drawRect(
            Rect.fromCenter(center: Offset(x, y), width: radius * 2, height: radius * 0.6),
            paint
          );
          break;
        case 3: // Multiplication cross
          paint.color = Colors.purple.withOpacity(0.1);
          canvas.drawCircle(Offset(x, y), radius, paint);
          paint.color = Colors.purple.withOpacity(0.2);
          canvas.save();
          canvas.translate(x, y);
          canvas.rotate(math.pi / 4);
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: radius * 0.6, height: radius * 2),
            paint
          );
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: radius * 2, height: radius * 0.6),
            paint
          );
          canvas.restore();
          break;
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/*class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // Filter options
  String _selectedClassLevel = "Tous";
  List<String> _classLevels = ["Tous", "CP", "CE1", "CE2", "CM1", "CM2"];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = Subject.getAllSubjects();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Pour Enfants'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeaderSection(),
          _buildFilterSection(),
          Expanded(
            child: _buildSubjectGrid(
              _selectedClassLevel == "Tous" 
                ? subjects 
                : subjects.where((s) => s.classLevel == _selectedClassLevel).toList()
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          const Text(
            'Bienvenue!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Choisis un sujet pour commencer à t\'exercer',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Text('Classe: ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _classLevels.map((level) => _buildClassFilterChip(level)).toList(),
              ),
            ),
          ),
        ],
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
        selectedColor: Colors.blue.shade100,
        backgroundColor: Colors.grey.shade200,
        onSelected: (bool selected) {
          setState(() {
            _selectedClassLevel = selected ? level : "Tous";
          });
        },
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
        childAspectRatio: 0.95,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        return _buildSubjectCard(subjects[index]);
      },
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    return GestureDetector(
      onTap: () => _navigateToExercise(subject),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: subject.color.withOpacity(0.8),
                  child: Center(
                    child: Icon(
                      subject.icon,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Classe ${subject.classLevel}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToExercise(Subject subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExercisePage(subject: subject),
      ),
    );
  }
}*/