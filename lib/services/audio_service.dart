import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playCorrect() async {
    await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
  }

  Future<void> playIncorrect() async {
    await _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
  }

  Future<void> playStart() async {
    await _audioPlayer.play(AssetSource('sounds/start.mp3'));
  }
}