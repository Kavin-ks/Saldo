// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_payment_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PaymentApp());
    await tester.pumpAndSettle(); // Wait for animations/loading

    // Verify that the splash screen or home screen appears
    // Since we can't easily predict the state without mocking SharedPreferences,
    // we just ensure it builds without crashing.
    expect(find.byType(PaymentApp), findsOneWidget);
  });
}
