import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  Function(String)? _onError; // Callback for error handling

  String? _frLocaleId;

  // Set error callback
  void setErrorCallback(Function(String) callback) {
    _onError = callback;
  }

  Future<bool> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onError: (error) {
          debugPrint('Speech recognition error: $error');
          _handleSpeechError(error);
        },
        onStatus: (status) => debugPrint('Speech recognition status: $status'),
      );

      if (_frLocaleId == null && _isInitialized) {
        // Discover all locales the engine supports:
        List<stt.LocaleName> locales = await _speech.locales();
        // Look for French variants:
        final fr = locales.firstWhere(
              (loc) =>
          loc.localeId.toLowerCase().startsWith('fr') ||
              loc.name.toLowerCase().contains('français'),
          orElse: () => locales.first,
        );
        _frLocaleId = fr.localeId;
        debugPrint('→ Using localeId: $_frLocaleId (${fr.name})');
      }



      return _isInitialized;
    }
    return _isInitialized;
  }

  void listen(Function(String) onResult) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isInitialized) {
      await _speech.listen(
        localeId: _frLocaleId,
        listenFor: const Duration(seconds: 30), // Maximum listen duration
        pauseFor: const Duration(seconds: 5), // Stop after 2 seconds of silence
        onResult: (result) {
          debugPrint('Speech result - Final: ${result.finalResult}, Words: ${result.recognizedWords}');

          // Process both partial and final results, but prefer final
          if (result.finalResult || result.recognizedWords.isNotEmpty) {
            // Filter to keep only numbers
            final filtered = _filterNumber(result.recognizedWords);

            if (filtered.isNotEmpty) {
              // Stop listening immediately when we get a valid number
              stop();

              // Call the callback with the result
              onResult(filtered);
            }
          }
        },
      );
    }
  }

  void _handleSpeechError(dynamic error) {
    stop(); // Stop listening immediately

    String errorMessage;
    if (error.toString().contains('error_no_match')) {
      errorMessage = 'Aucun mot reconnu. Basculement vers le mode clavier.';
    } else if (error.toString().contains('error_speech_timeout')) {
      errorMessage = 'Délai d\'attente dépassé. Basculement vers le mode clavier.';
    } else if (error.toString().contains('error_network')) {
      errorMessage = 'Erreur réseau. Basculement vers le mode clavier.';
    } else if (error.toString().contains('error_audio')) {
      errorMessage = 'Erreur audio. Vérifiez votre microphone. Basculement vers le mode clavier.';
    } else {
      errorMessage = 'Erreur de reconnaissance vocale. Basculement vers le mode clavier.';
    }

    // Call error callback if set
    _onError?.call(errorMessage);
  }

  String _filterNumber(String input) {
    // Convert written numbers to digits in French
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

    // Convert to lowercase for easier matching
    String lowerInput = input.toLowerCase();

    // Process numeric words
    for (var entry in wordToDigit.entries) {
      lowerInput = lowerInput.replaceAll(entry.key, entry.value);
    }

    // Extract only digits
    RegExp digitsOnly = RegExp(r'\d+');
    Iterable<Match> matches = digitsOnly.allMatches(lowerInput);

    if (matches.isEmpty) {
      return '';
    }

    // Take the first number found
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