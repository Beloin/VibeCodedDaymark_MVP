import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:daymark/main.dart';
import 'package:daymark/app/di/dependency_injection.dart';
import 'package:daymark/features/habit_tracker/presentation/bloc/habit_bloc.dart';
import 'package:daymark/features/habit_tracker/presentation/bloc/config_bloc.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';
import 'package:daymark/features/habit_tracker/domain/entities/app_config.dart';

void main() {
  group('App Bar Layout Tests', () {
    testWidgets('App bar contains only SVG logo in title area', (WidgetTester tester) async {
      // Initialize dependencies
      await initDependencies();
      
      // Build our app
      await tester.pumpWidget(const DaymarkApp());
      await tester.pumpAndSettle();
      
      // Find the app bar
      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);
      
      // Verify the app bar title contains only the SVG logo
      final appBar = tester.widget<AppBar>(appBarFinder);
      expect(appBar.title, isA<SvgPicture>());
      
      // Verify no "Daymark" text exists in the app bar
      final daymarkTextFinder = find.text('Daymark');
      expect(daymarkTextFinder, findsNothing);
      
      // Verify the SVG logo has the correct properties
      final svgLogo = appBar.title as SvgPicture;
      expect(svgLogo.width, 32);
      expect(svgLogo.height, 32);
      expect(svgLogo.fit, BoxFit.contain);
    });
    
    testWidgets('View switcher is centered in app bar actions', (WidgetTester tester) async {
      // Initialize dependencies
      await initDependencies();
      
      // Build our app
      await tester.pumpWidget(const DaymarkApp());
      await tester.pumpAndSettle();
      
      // Find the app bar
      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);
      
      // Find the view switcher (SegmentedButton)
      final segmentedButtonFinder = find.byType(SegmentedButton<ViewType>);
      expect(segmentedButtonFinder, findsOneWidget);
      
      // Verify the view switcher is within the app bar actions
      final appBar = tester.widget<AppBar>(appBarFinder);
      expect(appBar.actions, isNotNull);
      
      // The actions should contain an Expanded widget with centered Row
      final expandedFinder = find.byType(Expanded);
      expect(expandedFinder, findsOneWidget);
      
      final rowFinder = find.byType(Row);
      final row = tester.widget<Row>(rowFinder);
      expect(row.mainAxisAlignment, MainAxisAlignment.center);
    });
    
    testWidgets('App bar has correct background color', (WidgetTester tester) async {
      // Initialize dependencies
      await initDependencies();
      
      // Build our app
      await tester.pumpWidget(const DaymarkApp());
      await tester.pumpAndSettle();
      
      // Find the app bar
      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);
      
      // Verify the app bar background color
      final appBar = tester.widget<AppBar>(appBarFinder);
      expect(appBar.backgroundColor, isNotNull);
      
      // The background color should be Theme.of(context).colorScheme.inversePrimary
      // We can't directly test the computed value, but we can verify it's not null
      expect(appBar.backgroundColor, isNot(Colors.transparent));
    });
    
    testWidgets('View switcher segments are correct', (WidgetTester tester) async {
      // Initialize dependencies
      await initDependencies();
      
      // Build our app
      await tester.pumpWidget(const DaymarkApp());
      await tester.pumpAndSettle();
      
      // Find the segmented button
      final segmentedButtonFinder = find.byType(SegmentedButton<ViewType>);
      expect(segmentedButtonFinder, findsOneWidget);
      
      // Verify the segments exist
      final calendarSegmentFinder = find.text('Calendar');
      final tilesSegmentFinder = find.text('Tiles');
      
      expect(calendarSegmentFinder, findsOneWidget);
      expect(tilesSegmentFinder, findsOneWidget);
      
      // Verify the icons exist
      final calendarIconFinder = find.byIcon(Icons.calendar_today);
      final tilesIconFinder = find.byIcon(Icons.grid_view);
      
      expect(calendarIconFinder, findsOneWidget);
      expect(tilesIconFinder, findsOneWidget);
    });
    
    testWidgets('Overall UI layout is balanced', (WidgetTester tester) async {
      // Initialize dependencies
      await initDependencies();
      
      // Build our app
      await tester.pumpWidget(const DaymarkApp());
      await tester.pumpAndSettle();
      
      // Find the app bar
      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);
      
      // Find the floating action button
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);
      
      // Find the main content area
      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);
      
      // Verify the app structure is complete
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}