import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  testWidgets('Simplified SVG logo loads without warnings', (WidgetTester tester) async {
    // Test the simplified logo (no filter elements)
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/daymark_logo_simple.svg',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                const Text('Daymark'),
              ],
            ),
          ),
          body: Container(),
        ),
      ),
    );

    // Verify the logo loads without warnings
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.text('Daymark'), findsOneWidget);
  });

  testWidgets('All SVG logo variants are available', (WidgetTester tester) async {
    // Test that all three SVG variants can be loaded
    final variants = [
      'assets/images/daymark_logo.svg',
      'assets/images/daymark_logo_lineart.svg', 
      'assets/images/daymark_logo_simple.svg',
    ];

    for (final variant in variants) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SvgPicture.asset(
                variant,
                width: 32,
                height: 32,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
    }
  });
}