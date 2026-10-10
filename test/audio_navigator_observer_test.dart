import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curio_math/core/audio/audio_navigator_observer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AudioNavigatorObserver stops audio on route pop and push', (tester) async {
    final observer = AudioNavigatorObserver.instance;

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (subContext) => Scaffold(
                      body: ElevatedButton(
                        onPressed: () => Navigator.of(subContext).pop(),
                        child: const Text('Back'),
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Go to SubScreen'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Push new screen
    await tester.tap(find.text('Go to SubScreen'));
    await tester.pumpAndSettle();

    expect(find.text('Back'), findsOneWidget);

    // Pop back to home screen
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Go to SubScreen'), findsOneWidget);
  });
}
