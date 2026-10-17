import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pwe/core/widgets/adaptive_two_pane.dart';

void main() {
  group('AdaptiveTwoPane Tests', () {
    testWidgets('deve renderizar em Column quando em modo Portrait', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveTwoPane(
              paneStart: Text('Pane 1'),
              paneEnd: Text('Pane 2'),
            ),
          ),
        ),
      );

      expect(find.text('Pane 1'), findsOneWidget);
      expect(find.text('Pane 2'), findsOneWidget);

      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);
      expect(find.byType(Row), findsNothing);
    });

    testWidgets('deve renderizar em Row quando em modo Landscape', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveTwoPane(
              paneStart: Text('Pane 1'),
              paneEnd: Text('Pane 2'),
              showDivider: true,
            ),
          ),
        ),
      );

      expect(find.text('Pane 1'), findsOneWidget);
      expect(find.text('Pane 2'), findsOneWidget);

      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);
      expect(find.byType(VerticalDivider), findsOneWidget);
    });
  });
}
