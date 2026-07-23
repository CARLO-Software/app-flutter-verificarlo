import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_flutter_verificarlo/app.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: VerificarloApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('VerifiCARLO'), findsOneWidget);
  });
}
