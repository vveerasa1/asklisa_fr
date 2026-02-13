import 'package:flutter_test/flutter_test.dart';
import 'package:ask_lisa/main.dart';

void main() {
  testWidgets('AskLisa app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AskLisaApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('AskLisa'), findsOneWidget);
  });
}
