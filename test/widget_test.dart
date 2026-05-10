import 'package:cycle_fit/widgets/onboarding_choice_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('onboarding choice tile shows selected state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OnboardingChoiceTile(
            label: 'Eufórica',
            isSelected: true,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Eufórica'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });
}
