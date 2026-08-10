import 'package:flutter_test/flutter_test.dart';
import 'package:ap_forest_lms/main.dart';

void main() {
  testWidgets('App initializes test', (WidgetTester tester) async {
    // Basic sanity test
    await tester.pumpWidget(const ForestAcademyApp());
  });
}
