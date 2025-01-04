import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
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
}