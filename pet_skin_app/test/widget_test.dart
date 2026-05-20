import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pet_skin_app/main.dart';
import 'package:pet_skin_app/providers/diagnosis_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DiagnosisProvider(),
        child: const PetSkinApp(),
      ),
    );
    // App should render without throwing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
