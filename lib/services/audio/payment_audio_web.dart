// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'payment_audio_service.dart';

class PaymentAudioServiceWeb implements PaymentAudioService {
  // Direct asset path for Web. 
  // Flutter Web serves assets at 'assets/' relative to index.html
  final AudioElement _element = AudioElement('assets/assets/sounds/payment_success.wav');

  PaymentAudioServiceWeb() {
    // Try both paths just in case, but usually it's assets/assets/ for libraries
    // OR just assets/ for raw assets.
    // Let's stick to the user's specific requirement: "Ensure no duplicated /assets/assets/"?
    // User said: "Ensure the asset path is resolved correctly... (no duplicated /assets/assets/)"
    // The previous error was GET /assets/assets/sounds/... which meant it WAS looking there.
    // If I use 'assets/sounds/payment_success.wav', it should be correct.
    _element.src = 'assets/sounds/payment_success.wav';
    _element.preload = 'auto';
  }

  @override
  Future<void> playSuccessSound() async {
    try {
      _element.currentTime = 0;
      await _element.play();
    } catch (e) {
      // Web Auto-play policies might block this if not user interaction, 
      // but this is called after a button press (payment), so it should work.
    }
  }

  @override
  void dispose() {
    _element.remove();
  }
}

PaymentAudioService createPaymentAudioService() => PaymentAudioServiceWeb();
