import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cremation_app/main.dart';

void main() {
  testWidgets('Check if Book Now button is present', (WidgetTester tester) async {
    // Load the app
    await tester.pumpWidget(const CremationServiceApp());

    // Verify the "Book Now" button is in the UI
    expect(find.text('Book Now'), findsOneWidget); // Finds button text
    expect(find.byType(ElevatedButton), findsOneWidget); // Finds button type
  });
}
