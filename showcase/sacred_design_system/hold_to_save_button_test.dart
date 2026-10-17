import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pwe/features/lectio_divina/presentation/widgets/hold_to_save_button.dart';

void main() {
  bool callbackFired = false;

  Widget buildWidget({VoidCallback? onCompleted}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: HoldToSaveButton(
            onCompleted: onCompleted ?? () => callbackFired = true,
          ),
        ),
      ),
    );
  }

  setUp(() {
    callbackFired = false;
  });

  group('HoldToSaveButton', () {
    testWidgets('should display default label and icon', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Guardar no Coração'), findsOneWidget);
      expect(find.text('Pressione e segure'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should display custom label and icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HoldToSaveButton(
              label: 'Salvar Oração',
              icon: Icons.bookmark,
              onCompleted: () {},
            ),
          ),
        ),
      );

      expect(find.text('Salvar Oração'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });

    testWidgets('tap should NOT trigger callback', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byType(HoldToSaveButton));
      await tester.pumpAndSettle();

      expect(callbackFired, false);
    });

    testWidgets('should render progress ring via CustomPaint', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(
        find.descendant(
          of: find.byType(HoldToSaveButton),
          matching: find.byType(CustomPaint),
        ),
        findsWidgets,
      );
    });

    testWidgets('should have GestureDetector with long press handlers', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());

      final gestureDetector = tester.widget<GestureDetector>(
        find.descendant(
          of: find.byType(HoldToSaveButton),
          matching: find.byType(GestureDetector),
        ),
      );

      expect(gestureDetector.onLongPressStart, isNotNull);
      expect(gestureDetector.onLongPressEnd, isNotNull);
    });

    testWidgets('should have AnimatedScale for press feedback', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(
        find.descendant(
          of: find.byType(HoldToSaveButton),
          matching: find.byType(AnimatedScale),
        ),
        findsOneWidget,
      );
    });

    testWidgets('completa segurando ponteiro por mais de 2s', (tester) async {
      int callCount = 0;
      await tester.pumpWidget(buildWidget(onCompleted: () => callCount++));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(HoldToSaveButton)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Segurando...'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(callCount, 1);
      expect(find.text('Salvo!'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('reverte ao soltar antes de completar', (tester) async {
      int callCount = 0;
      await tester.pumpWidget(buildWidget(onCompleted: () => callCount++));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(HoldToSaveButton)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Segurando...'), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();

      expect(callCount, 0);
      expect(find.text('Pressione e segure'), findsOneWidget);
    });
  });
}
