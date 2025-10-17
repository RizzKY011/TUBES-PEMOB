import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splatsplit/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MonasApp(initialRoute: '/home'));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
