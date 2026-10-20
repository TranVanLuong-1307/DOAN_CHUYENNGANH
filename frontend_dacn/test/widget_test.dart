import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_dacn/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HealthExerciseApp());

    // Verify that primary title 'Sức khỏe' is rendered.
    expect(find.text('Sức khỏe'), findsAtLeastNWidgets(1));
  });
}
