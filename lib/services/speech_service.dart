import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  // This method only initializes the speech engine without requesting permissions
  Future<void> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onError: (error) => debugPrint('Speech recognition error: $error'),
        onStatus: (status) => debugPrint('Speech recognition status: $status'),
      );
    }
  }

  // Request microphone permissions with custom message
  Future<bool> requestPermissions(BuildContext context) async {
    // 1️⃣ Ask the user if they want to continue
    final bool? proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Accès au microphone'),
        content: const Text(
          'Pour utiliser le mode voix, HelloMath a besoin d\'accéder à votre microphone. '
          'Veuillez autoriser l\'accès dans la fenêtre suivante.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false), // “Annuler”
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true), // “Continuer”
            child: const Text('Continuer'),
          ),
        ],
      ),
    );

    // User backed out
    if (proceed != true) return false;

    // Now show the system permission sheet
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  //method to check if the user has granted permission to use the microphone
  Future<bool> checkPermission(BuildContext context) async {
    // Check if permission is already granted
    bool hasPermission = await Permission.microphone.status.isGranted;

    // If not granted, request permission with custom dialog
    if (!hasPermission) {
      hasPermission = await requestPermissions(context);
      if (!hasPermission) {
        return false; // User denied permission
      }
    }
    return true;
  }

  Future<bool> listen(Function(String) onResult,
      {required BuildContext context}) async {
    // Check if permission is already granted
    bool hasPermission = await Permission.microphone.status.isGranted;

    // If not granted, request permission with custom dialog
    if (!hasPermission) {
      hasPermission = await requestPermissions(context);
      if (!hasPermission) {
        return false; // User denied permission
      }
    }

    // Initialize speech recognition if not already done
    if (!_isInitialized) {
      await initialize();
    }

    if (_isInitialized) {
      await _speech.listen(
        localeId: 'fr_FR', // Langue française
        onResult: (result) {
          if (result.finalResult) {
            // Filtrer pour ne garder que les chiffres
            //debuglog the result
            debugPrint('Recognized: ${result.recognizedWords}');
            final filtered = _filterNumber(result.recognizedWords);
            onResult(filtered);
          }
        },
      );
      return true;
    }

    return false;
  }

  String _filterNumber(String input) {
    // Convertir les nombres écrits en chiffres en français
    Map<String, String> wordToDigit = {
      'zéro': '0',
      'un': '1',
      'deux': '2',
      'trois': '3',
      'quatre': '4',
      'cinq': '5',
      'six': '6',
      'sept': '7',
      'huit': '8',
      'neuf': '9',
      'dix': '10',
      'onze': '11',
      'douze': '12',
      'treize': '13',
      'quatorze': '14',
      'quinze': '15',
      'seize': '16',
      'dix-sept': '17',
      'dix-huit': '18',
      'dix-neuf': '19',
      'vingt': '20',
      'trente': '30',
      'quarante': '40',
      'cinquante': '50',
      'soixante': '60',
      'soixante-dix': '70',
      'quatre-vingt': '80',
      'quatre-vingt-dix': '90',
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
