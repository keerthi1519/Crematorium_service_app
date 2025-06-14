import 'package:cremation_app/main.dart'; // Use correct package name
import 'package:cremation_app/use_cases/use_cases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('Accessibility guideline tests', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomePage()));

    final ScrollController controller =
        tester.state<HomePageState>(find.byType(HomePage)).scrollController;

    for (final UseCase useCase in useCases) {
      while (find.byKey(Key(useCase.name)).evaluate().isEmpty) {
        controller.jumpTo(controller.offset + 600);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(Key(useCase.name)));
      await tester.pumpAndSettle();
    }
  });
}
