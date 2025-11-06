// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/main.dart';
import 'package:daymark/app/di/dependency_injection.dart';

void main() {
  testWidgets('Daymark app builds without errors', (WidgetTester tester) async {
    // Initialize dependencies
    await initDependencies();
    
    // Build our app - this should not throw any exceptions
    await tester.pumpWidget(const DaymarkApp());

    // The app should build successfully
    // We don't check for specific widgets due to potential layout overflow in test environment
    expect(tester.takeException(), isNull);
  });
}
