import 'dart:async';

import 'package:Tables/screens/history_page.dart';
import 'package:Tables/screens/home_page.dart';
import 'package:Tables/screens/settings_page.dart';
import 'package:Tables/services/speech_service.dart';
import 'package:Tables/widgets/countdown_timer.dart';
import 'package:Tables/widgets/number_keyboard.dart';
import 'package:Tables/widgets/score_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/exercise_history.dart';
import 'services/database_helper.dart';
import 'services/audio_service.dart';

void main() {
  runApp(const MultiplicationApp());
}

class MultiplicationApp extends StatelessWidget {
  const MultiplicationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tables de Multiplication',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false, // Add this line
      home: const HomePage(),
    );
  }
}
