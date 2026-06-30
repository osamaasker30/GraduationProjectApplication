import 'package:flutter_test/flutter_test.dart';
import 'package:kariyer_koprusu_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KariyerKoprusuApp());
    expect(find.byType(KariyerKoprusuApp), findsOneWidget);
  });
}
