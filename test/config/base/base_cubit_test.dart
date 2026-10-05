import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestState {
  const _TestState(this.value);

  final int value;
}

class _TestCubit extends BaseCubit<_TestState, BaseUiEvent> {
  _TestCubit() : super(const _TestState(0));
}

void main() {
  group('BaseCubit state', () {
    test('exposes the initial state', () {
      final cubit = _TestCubit();

      expect(cubit.state.value, 0);

      cubit.close();
    });

    test('inherits emit from Cubit', () async {
      final cubit = _TestCubit();

      cubit.emit(const _TestState(1));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.value, 1);

      await cubit.close();
    });
  });

  group('BaseCubit.uiEventStream', () {
    test('delivers emitted events to a listener', () async {
      final cubit = _TestCubit();
      final received = <BaseUiEvent>[];

      final subscription = cubit.uiEventStream.listen(received.add);
      cubit.emitEvent(const ShowSuccessMessage('saved'));
      await Future<void>.delayed(Duration.zero);

      expect(received, [const ShowSuccessMessage('saved')]);

      await subscription.cancel();
      await cubit.close();
    });

    test('is a broadcast stream so several listeners receive the event', () async {
      final cubit = _TestCubit();
      final first = <BaseUiEvent>[];
      final second = <BaseUiEvent>[];

      final firstSub = cubit.uiEventStream.listen(first.add);
      final secondSub = cubit.uiEventStream.listen(second.add);

      cubit.emitEvent(const ShowErrorMessage('failed'));
      await Future<void>.delayed(Duration.zero);

      expect(first, hasLength(1));
      expect(second, hasLength(1));

      await firstSub.cancel();
      await secondSub.cancel();
      await cubit.close();
    });

    test('carries the payload of each event type', () async {
      final cubit = _TestCubit();
      final received = <BaseUiEvent>[];

      final subscription = cubit.uiEventStream.listen(received.add);

      cubit.emitEvent(const ShowSuccessMessage('ok'));
      cubit.emitEvent(const ShowErrorMessage('bad'));
      cubit.emitEvent(const NavigateTo('/home', arguments: 42));
      cubit.emitEvent(const PopRoute('result'));
      await Future<void>.delayed(Duration.zero);

      expect(received, hasLength(4));

      final navigate = received[2] as NavigateTo;
      expect(navigate.routeName, '/home');
      expect(navigate.arguments, 42);

      final pop = received[3] as PopRoute;
      expect(pop.result, 'result');

      await subscription.cancel();
      await cubit.close();
    });

    test('does not replay previously emitted events to new listeners', () async {
      final cubit = _TestCubit();

      cubit.emitEvent(const ShowSuccessMessage('before'));
      await Future<void>.delayed(Duration.zero);

      final received = <BaseUiEvent>[];
      final subscription = cubit.uiEventStream.listen(received.add);
      await Future<void>.delayed(Duration.zero);

      expect(received, isEmpty);

      await subscription.cancel();
      await cubit.close();
    });
  });

  group('BaseCubit.close', () {
    test('closing the stream does not throw when emitting afterwards', () async {
      final cubit = _TestCubit();

      await cubit.close();

      expect(
        () => cubit.emitEvent(const ShowSuccessMessage('after close')),
        returnsNormally,
      );
    });

    test('is idempotent enough that a second close does not throw', () async {
      final cubit = _TestCubit();

      await cubit.close();
      await cubit.close();
    });
  });
}