import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/core/shared/widgets/base_ui_event_listener.dart';

class CustomTestEvent extends BaseUiEvent {
  final String text;
  const CustomTestEvent(this.text);
}

class TestCubit extends BaseCubit<int, BaseUiEvent> {
  TestCubit() : super(0);
}

class MockTestCubit extends Mock implements TestCubit {}

void main() {
  late MockTestCubit mockCubit;
  late StreamController<BaseUiEvent> eventController;

  setUp(() {
    mockCubit = MockTestCubit();
    eventController = StreamController<BaseUiEvent>.broadcast();

    when(() => mockCubit.state).thenReturn(0);
    when(() => mockCubit.stream).thenAnswer((_) => const Stream<int>.empty());
    when(
      () => mockCubit.uiEventStream,
    ).thenAnswer((_) => eventController.stream);
    when(() => mockCubit.close()).thenAnswer((_) => Future<void>.value());
  });

  tearDown(() {
    eventController.close();
  });

  Widget buildWidget({
    void Function(BuildContext, BaseUiEvent)? onCustomEvent,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BaseUiEventListener<TestCubit, int, BaseUiEvent>(
          cubit: mockCubit,
          onCustomEvent: onCustomEvent,
          child: const Text('Child Widget'),
        ),
      ),
    );
  }

  testWidgets(
    'BaseUiEventListener shows SnackBar on ShowSuccessMessage and does not call onCustomEvent',
    (tester) async {
      BaseUiEvent? receivedCustomEvent;

      await tester.pumpWidget(
        buildWidget(
          onCustomEvent: (context, event) => receivedCustomEvent = event,
        ),
      );
      await tester.pumpAndSettle();

      eventController.add(const ShowSuccessMessage('Success!'));
      await tester.pumpAndSettle();

      expect(find.text('Success!'), findsOneWidget);
      expect(receivedCustomEvent, isNull);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'BaseUiEventListener shows SnackBar on ShowErrorMessage and does not call onCustomEvent',
    (tester) async {
      BaseUiEvent? receivedCustomEvent;

      await tester.pumpWidget(
        buildWidget(
          onCustomEvent: (context, event) => receivedCustomEvent = event,
        ),
      );
      await tester.pumpAndSettle();

      eventController.add(const ShowErrorMessage('Error!'));
      await tester.pumpAndSettle();

      expect(find.text('Error!'), findsOneWidget);
      expect(receivedCustomEvent, isNull);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'BaseUiEventListener calls onCustomEvent strictly in default branch',
    (tester) async {
      BaseUiEvent? receivedCustomEvent;

      await tester.pumpWidget(
        buildWidget(
          onCustomEvent: (context, event) => receivedCustomEvent = event,
        ),
      );
      await tester.pumpAndSettle();

      const customEvent = CustomTestEvent('custom');
      eventController.add(customEvent);
      await tester.pumpAndSettle();

      expect(receivedCustomEvent, customEvent);

      await tester.pumpWidget(const SizedBox());
    },
  );
}
