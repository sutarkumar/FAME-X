import 'package:flutter_test/flutter_test.dart';
import 'package:fame_x/main.dart';

void main() {
  testWidgets('App smoke test - renders login screen when logged out', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Verify that the login screen renders containing the login action button
    expect(find.text('LOG IN'), findsOneWidget);
  });
}
