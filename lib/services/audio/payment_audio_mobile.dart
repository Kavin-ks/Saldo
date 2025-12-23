import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'payment_audio_service.dart';

class PaymentAudioServiceMobile implements PaymentAudioService {
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> playSuccessSound() async {
    try {
      await _player.stop();
      // AudioPlayers adds 'assets/' prefix automatically for AssetSource
      await _player.play(AssetSource('sounds/payment_success.wav'));
      HapticFeedback.heavyImpact();
    } catch (e) {
      // Ignore errors on mobile, or log if needed
    }
  }

  @override
  void dispose() {
    _player.dispose();
  }
}

PaymentAudioService createPaymentAudioService() => PaymentAudioServiceMobile();
