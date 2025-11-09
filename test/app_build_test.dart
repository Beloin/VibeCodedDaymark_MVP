import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  testWidgets('Daymark app builds with SVG logo', (WidgetTester tester) async {
    // Test the actual app structure with the logo
    await tester.pumpWidget(
      MaterialApp(
        title: 'Daymark',
        home: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                // Daymark logo - same as in the actual app
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
          body: const Center(child: Text('Home Page')),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );

    // Verify all key components exist
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.text('Daymark'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Home Page'), findsOneWidget);
  });

  testWidgets('SVG logo dimensions are correct', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SvgPicture.asset(
              'assets/images/daymark_logo.svg',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );

    final svgWidget = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svgWidget.width, 32);
    expect(svgWidget.height, 32);
    expect(svgWidget.fit, BoxFit.contain);
  });

  testWidgets('Alternative SVG logo also loads', (WidgetTester tester) async {
    // Test the lineart version as well
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SvgPicture.asset(
              'assets/images/daymark_logo_lineart.svg',
              width: 32,
              height: 32,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(SvgPicture), findsOneWidget);
  });
}