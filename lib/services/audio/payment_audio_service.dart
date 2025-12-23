import 'payment_audio_mobile.dart' if (dart.library.html) 'payment_audio_web.dart';

abstract class PaymentAudioService {
  Future<void> playSuccessSound();
  void dispose();

  factory PaymentAudioService() => createPaymentAudioService();
}
