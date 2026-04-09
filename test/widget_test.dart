import 'package:flutter/material.dart';
import 'package:flutter_calendar/controllers/themeController/theme_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_calendar/main.dart'; 

void main() {

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Calendar app loads correctly and shows title', (WidgetTester tester) async {
    final themeController = ThemeController();
    
    await themeController.loadInitialSettings();

    await tester.pumpWidget(MyApp(themeController: themeController));

    await tester.pumpAndSettle();

    expect(find.text('Kalenderblatt'), findsOneWidget);

    expect(find.byIcon(Icons.palette_rounded), findsOneWidget);
  });

  testWidgets('Theme picker opens on palette icon tap', (WidgetTester tester) async {
    final themeController = ThemeController();
    await themeController.loadInitialSettings();
    await tester.pumpWidget(MyApp(themeController: themeController));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.palette_rounded));
    
    await tester.pumpAndSettle();

    expect(find.text('Design'), findsOneWidget);
    expect(find.text('Auto-Close'), findsOneWidget);
  });
}