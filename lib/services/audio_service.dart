import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Chemin vers les fichiers audio (à placer dans le dossier assets)
  static const String correctSoundPath = 'sounds/correct.mp3';
  static const String errorSoundPath = 'sounds/incorrect.mp3';

  Future<void> playCorrectSound() async {
    try {
      await _audioPlayer.play(AssetSource(correctSoundPath));
    } catch (e) {
      print('Error playing correct sound: $e');
    }
  }

  Future<void> playErrorSound() async {
    try {
      await _audioPlayer.play(AssetSource(errorSoundPath));
    } catch (e) {
      print('Error playing error sound: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
