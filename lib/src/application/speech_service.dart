import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  Future<void> initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  bool get isListening => _speechToText.isListening;
  bool get speechEnabled => _speechEnabled;

  Future<void> startListening({required Function(String) onResult}) async { // Removed onListeningStatus
    if (_speechEnabled) {
      _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        listenFor: const Duration(seconds: 30), // Listen for up to 30 seconds
        pauseFor: const Duration(seconds: 5), // Pause if no speech for 5 seconds
        onSoundLevelChange: (level) {},
        // Removed onStatus parameter
      );
    }
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }
}

final speechServiceProvider = Provider<SpeechService>((ref) => SpeechService());