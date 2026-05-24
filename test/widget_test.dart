import 'package:bhakti_sadhana/app.dart';
import 'package:bhakti_sadhana/features/home/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Splash then home', (WidgetTester tester) async {
    await tester.pumpWidget(const BhaktiApp());
    await tester.pump();
    expect(find.text('ॐ'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pump();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('पूजा विधि'), findsOneWidget);
  });
}
