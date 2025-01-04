
import 'package:shared_preferences/shared_preferences.dart';
import '../models/input_mode.dart';

class SharedPreferencesService {
  static const String _inputModeKey = 'input_mode';

  static Future<InputMode> getInputMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isVoiceMode = prefs.getBool(_inputModeKey) ?? false;
    return isVoiceMode ? InputMode.voice : InputMode.keyboard;
  }

  static Future<void> setInputMode(InputMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_inputModeKey, mode == InputMode.voice);
  }
}