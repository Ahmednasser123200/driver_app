import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/core/shared/widgets/base_ui_event_listener.dart';
import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_ui_event.dart';

class TestCubit extends BaseCubit<int, BaseUiEvent> {
  TestCubit() : super(0);
}

void main() {
  group('BaseUiEventListener', () {
    late TestCubit cubit;

    setUp(() {
      cubit = TestCubit();
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('handles ShowSuccessMessage and NavigateTo events', (
      tester,
    ) async {
      final GlobalKey<NavigatorState> navigatorKey =
          GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          routes: {
            '/test': (context) => const Scaffold(body: Text('Test Route')),
          },
          home: Scaffold(
            body: BaseUiEventListener<TestCubit, int, BaseUiEvent>(
              cubit: cubit,
              child: const Text('Home'),
            ),
          ),
        ),
      );

      // Verify SnackBar
      cubit.emitEvent(const ShowSuccessMessage('Success!!'));
      await tester.pumpAndSettle();
      expect(find.text('Success!!'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);

      // Wait for SnackBar to disappear or just proceed
      ScaffoldMessenger.of(navigatorKey.currentContext!).hideCurrentSnackBar();
      await tester.pumpAndSettle();

      // Verify NavigateTo
      cubit.emitEvent(const NavigateTo('/test'));
      await tester.pumpAndSettle();
      expect(find.text('Test Route'), findsOneWidget);
    });
  });
}
