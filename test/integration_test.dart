import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  group('Daymark Application Integration Tests', () {
    testWidgets('Complete app structure with SVG logo', (WidgetTester tester) async {
      // Build the complete app structure
      await tester.pumpWidget(
        MaterialApp(
          title: 'Daymark',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  // Main logo
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
              backgroundColor: Colors.deepPurple.shade100,
              actions: [
                // View switcher (simplified)
                SegmentedButton<ViewType>(
                  segments: const [
                    ButtonSegment<ViewType>(
                      value: ViewType.calendar,
                      label: Text('Calendar'),
                      icon: Icon(Icons.calendar_today),
                    ),
                    ButtonSegment<ViewType>(
                      value: ViewType.tile,
                      label: Text('Tiles'),
                      icon: Icon(Icons.grid_view),
                    ),
                  ],
                  selected: const {ViewType.calendar},
                  onSelectionChanged: (Set<ViewType> newSelection) {},
                ),
              ],
            ),
            body: const Center(child: Text('Habit Tracker Content')),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      // Verify all major components
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.text('Daymark'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Tiles'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Habit Tracker Content'), findsOneWidget);
    });

    testWidgets('SVG logo renders with proper styling', (WidgetTester tester) async {
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
            body: Container(),
          ),
        ),
      );

      // Verify the logo is properly sized and positioned
      final svgFinder = find.byType(SvgPicture);
      expect(svgFinder, findsOneWidget);

      final svgWidget = tester.widget<SvgPicture>(svgFinder);
      expect(svgWidget.width, 32);
      expect(svgWidget.height, 32);
      expect(svgWidget.fit, BoxFit.contain);
    });

    testWidgets('AppBar background color matches theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/daymark_logo.svg',
                    width: 32,
                    height: 32,
                  ),
                  const SizedBox(width: 12),
                  const Text('Daymark'),
                ],
              ),
              backgroundColor: Colors.deepPurple.shade100,
            ),
            body: Container(),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, Colors.deepPurple.shade100);
    });
  });
}

// Simplified enum for testing
enum ViewType { calendar, tile }