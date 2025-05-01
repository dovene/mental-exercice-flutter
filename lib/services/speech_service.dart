import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

/*class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  Future<void> init() async {
    await _requestPermissions();
    await _initializeSpeechToText();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.microphone.isDenied) {
      await Permission.microphone.request();
    }
  }

  Future<void> _initializeSpeechToText() async {
    await _speechToText.initialize(
      debugLogging: true,
      onError: (error) => print("Speech recognition error: ${error.errorMsg}"),
      onStatus: (status) => print("Speech recognition status: $status"),
    );
  }

  bool get isListening => _isListening;

  Future<void> startListening({
    required Function(String) onResult,
    required Function onFinalResult,
    required int listenDuration,
    String localeId = 'fr_FR',
  }) async {
    if (!_speechToText.isAvailable || _isListening) return;

    _isListening = true;

    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          stopListening();
          onFinalResult();
        }
      },
      listenFor: Duration(seconds: listenDuration),
      localeId: localeId,
    );
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  bool get isAvailable => _speechToText.isAvailable;

  void dispose() {
    _speechToText.stop();
  }
}*/
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onError: (error) => debugPrint('Speech recognition error: $error'),
        onStatus: (status) => debugPrint('Speech recognition status: $status'),
      );
    }
  }
  
  void listen(Function(String) onResult) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_isInitialized) {
      await _speech.listen(
        localeId: 'fr_FR', // Langue française
        listenMode: stt.ListenMode.confirmation,
        onResult: (result) {
          if (result.finalResult) {
            // Filtrer pour ne garder que les chiffres
            final filtered = _filterNumber(result.recognizedWords);
            onResult(filtered);
          }
        },
      );
    }
  }
  
  String _filterNumber(String input) {
    // Convertir les nombres écrits en chiffres en français
    Map<String, String> wordToDigit = {
      'zéro': '0', 'un': '1', 'deux': '2', 'trois': '3', 'quatre': '4',
      'cinq': '5', 'six': '6', 'sept': '7', 'huit': '8', 'neuf': '9',
      'dix': '10', 'onze': '11', 'douze': '12', 'treize': '13', 'quatorze': '14',
      'quinze': '15', 'seize': '16', 'dix-sept': '17', 'dix-huit': '18', 'dix-neuf': '19',
      'vingt': '20', 'trente': '30', 'quarante': '40', 'cinquante': '50',
      'soixante': '60', 'soixante-dix': '70', 'quatre-vingt': '80', 'quatre-vingt-dix': '90',
      'cent': '100',
    };
    
    // Convertir en minuscules pour faciliter la correspondance
    String lowerInput = input.toLowerCase();
    
    // Traiter les mots numériques
    for (var entry in wordToDigit.entries) {
      lowerInput = lowerInput.replaceAll(entry.key, entry.value);
    }
    
    // Extraire uniquement les chiffres
    RegExp digitsOnly = RegExp(r'\d+');
    Iterable<Match> matches = digitsOnly.allMatches(lowerInput);
    
    if (matches.isEmpty) {
      return '';
    }
    
    // Prendre le premier nombre trouvé
    return matches.first.group(0) ?? '';
  }
  
  void stop() {
    if (_speech.isListening) {
      _speech.stop();
    }
  }
  
  void dispose() {
    stop();
  }
}