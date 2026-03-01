import 'package:audioplayers/audioplayers.dart';

class VoicePlayer {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play(String? url) async {
    if (url == null || url.isEmpty) return;

    try {
      await _player.stop(); 

      if (url.startsWith('http')) {
        await _player.play(UrlSource(url));
      } else {
        await _player.play(AssetSource(url));
      }
    } catch (e) {
      print("VoicePlayer error: $e");
    }
  }

  static Future<void> stop() async {
  await _player.stop();
}
}