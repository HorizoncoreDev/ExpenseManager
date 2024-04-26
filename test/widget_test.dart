import 'package:expense_manager/intro_screen/intro_screen.dart';
import 'package:expense_manager/utils/theme_notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockThemeNotifier extends Mock implements ThemeNotifier {
  @override
  ThemeData getTheme() {
    return ThemeData.dark();
  }
}

void main() {
  setUp(() async {
    // Mock Firebase.initializeApp
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  testWidgets('Intro start click', (tester) async {
    final mockThemeNotifier = MockThemeNotifier();

    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeNotifier>.value(
        value: mockThemeNotifier,
        child: const MaterialApp(
          home: IntroScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll to make the widget visible
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0.0, -300.0));
    await tester.pump();

    expect(find.text('Start'), findsOneWidget);

    await tester.tap(find.text("Start"));
    await tester.pumpAndSettle();

    if (kDebugMode) {
      print('Tapped on the widget with text "Start"');
    }
  });

}
