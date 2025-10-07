// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:async_redux/async_redux.dart';

import 'package:template/main.dart';
import 'package:template/core/store/app_state.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Create a test store
    final store = Store<AppState>(initialState: AppState.initialState());

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(store: store));

    // Verify that the app loads (should show login screen initially)
    expect(find.text('Login'), findsOneWidget);
  });
}
