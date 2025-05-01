import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal() {
    _initPlayers();
  }

  late AudioPlayer correctPlayer;
  late AudioPlayer incorrectPlayer;
  late AudioPlayer startPlayer;
  bool _isInitialized = false;

  Future<void> _initPlayers() async {
    try {
      correctPlayer = AudioPlayer();
      incorrectPlayer = AudioPlayer();
      startPlayer = AudioPlayer();

      // Pre-load sounds
      await Future.wait([
        correctPlayer.setSource(AssetSource('sounds/correct.mp3')),
        incorrectPlayer.setSource(AssetSource('sounds/incorrect.mp3')),
        startPlayer.setSource(AssetSource('sounds/start.mp3')),
      ]);

      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize AudioPlayers: $e');
      _isInitialized = false;
    }
  }

  void playCorrect() {
    if (!_isInitialized) return;
    try {
      correctPlayer.resume();
    } catch (e) {
      debugPrint('Failed to play correct sound: $e');
    }
  }

  void playIncorrect() {
    if (!_isInitialized) return;
    try {
      incorrectPlayer.resume();
    } catch (e) {
      debugPrint('Failed to play incorrect sound: $e');
    }
  }

  void playStart() {
    if (!_isInitialized) return;
    try {
      startPlayer.resume();
    } catch (e) {
      debugPrint('Failed to play start sound: $e');
    }
  }

  void dispose() {
    if (_isInitialized) {
      correctPlayer.dispose();
      incorrectPlayer.dispose();
      startPlayer.dispose();
    }
  }
}