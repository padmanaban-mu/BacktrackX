import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:backtrackx_new/app.dart';

void main() {
  testWidgets('BackTrackX app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const BackTrackXApp());

    // Verify that the app loads successfully.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}