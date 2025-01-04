import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();

  Future<void> init() async {
    await _requestPermissions();
    await _initSpeechToText();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
  }

  Future<void> _initSpeechToText() async {
    await _speechToText.initialize(
      debugLogging: true,
      onError: (error) {
        // Handle errors
      },
      onStatus: (status) {
        // Handle status changes
      },
    );
  }

// Add other speech-related methods
}