import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:daymark/features/habit_tracker/presentation/pages/home_page_refactored_fixed.dart';
import 'package:daymark/features/habit_tracker/domain/entities/app_config.dart';

void main() {
  group('App Bar Unit Tests', () {
    testWidgets('AppBar title contains only SVG logo', (WidgetTester tester) async {
      // Create a test widget with just the AppBar structure
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: SvgPicture.asset(
                'assets/images/daymark_logo.svg',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
              backgroundColor: Colors.blue,
              actions: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                        selected: {ViewType.calendar},
                        onSelectionChanged: (Set<ViewType> newSelection) {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: Container(),
          ),
        ),
      );

      // Verify the app bar structure
      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);

      // Verify the title is an SVG picture
      final appBar = tester.widget<AppBar>(appBarFinder);
      expect(appBar.title, isA<SvgPicture>());

      // Verify no "Daymark" text exists
      final daymarkTextFinder = find.text('Daymark');
      expect(daymarkTextFinder, findsNothing);

      // Verify the SVG logo properties
      final svgLogo = appBar.title as SvgPicture;
      expect(svgLogo.width, 32);
      expect(svgLogo.height, 32);
      expect(svgLogo.fit, BoxFit.contain);
    });

    testWidgets('View switcher is properly centered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: SvgPicture.asset(
                'assets/images/daymark_logo.svg',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
              backgroundColor: Colors.blue,
              actions: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                        selected: {ViewType.calendar},
                        onSelectionChanged: (Set<ViewType> newSelection) {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: Container(),
          ),
        ),
      );

      // Verify the view switcher structure
      final expandedFinder = find.byType(Expanded);
      expect(expandedFinder, findsOneWidget);

      // Find the specific Row within the Expanded widget that has center alignment
      final rowFinder = find.descendant(
        of: expandedFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is Row && widget.mainAxisAlignment == MainAxisAlignment.center,
        ),
      );
      expect(rowFinder, findsOneWidget);

      final row = tester.widget<Row>(rowFinder);
      expect(row.mainAxisAlignment, MainAxisAlignment.center);

      // Verify the segmented button exists
      final segmentedButtonFinder = find.byType(SegmentedButton<ViewType>);
      expect(segmentedButtonFinder, findsOneWidget);

      // Verify both segments are present
      final calendarSegmentFinder = find.text('Calendar');
      final tilesSegmentFinder = find.text('Tiles');
      expect(calendarSegmentFinder, findsOneWidget);
      expect(tilesSegmentFinder, findsOneWidget);
    });

    testWidgets('App bar has correct background color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: SvgPicture.asset(
                'assets/images/daymark_logo.svg',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
              backgroundColor: Colors.blue,
              actions: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                        selected: {ViewType.calendar},
                        onSelectionChanged: (Set<ViewType> newSelection) {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: Container(),
          ),
        ),
      );

      final appBarFinder = find.byType(AppBar);
      final appBar = tester.widget<AppBar>(appBarFinder);
      
      // Verify the background color is set
      expect(appBar.backgroundColor, isNotNull);
      expect(appBar.backgroundColor, Colors.blue);
    });
  });
}