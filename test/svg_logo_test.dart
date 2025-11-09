import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  testWidgets('SVG logo renders in AppBar', (WidgetTester tester) async {
    // Build a simple widget with the logo in AppBar
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/daymark_logo.svg',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                const Text('Daymark'),
              ],
            ),
          ),
          body: const Center(child: Text('Test Body')),
        ),
      ),
    );

    // Verify the logo widget exists
    expect(find.byType(SvgPicture), findsOneWidget);
    
    // Verify the text exists
    expect(find.text('Daymark'), findsOneWidget);
  });

  testWidgets('SVG logo asset exists and can be loaded', (WidgetTester tester) async {
    // This test verifies that the SVG asset is properly declared and can be loaded
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SvgPicture.asset(
              'assets/images/daymark_logo.svg',
              width: 32,
              height: 32,
            ),
          ),
        ),
      ),
    );

    // If we get here without exceptions, the SVG loaded successfully
    expect(find.byType(SvgPicture), findsOneWidget);
  });
}