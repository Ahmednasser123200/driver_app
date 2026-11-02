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
    test('exposes and updates state', () async {
      final cubit = _TestCubit();
      expect(cubit.state.value, 0);

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

    test('broadcasts events to multiple listeners', () async {
      final cubit = _TestCubit();
      final first = <BaseUiEvent>[];
      final second = <BaseUiEvent>[];
      final firstSub = cubit.uiEventStream.listen(first.add);
      final secondSub = cubit.uiEventStream.listen(second.add);

      cubit.emitEvent(const ShowErrorMessage(message: 'failed'));
      await Future<void>.delayed(Duration.zero);

      expect(first, hasLength(1));
      expect(second, hasLength(1));
      await firstSub.cancel();
      await secondSub.cancel();
      await cubit.close();
    });

    test('preserves navigation and pop payloads', () async {
      final cubit = _TestCubit();
      final received = <BaseUiEvent>[];
      final subscription = cubit.uiEventStream.listen(received.add);

      cubit.emitEvent(
        const NavigateTo('/home', arguments: 42, isReplacement: true),
      );
      cubit.emitEvent(const PopRoute('result'));
      await Future<void>.delayed(Duration.zero);

      expect(received[0], isA<NavigateTo>());
      final navigate = received[0] as NavigateTo;
      expect(navigate.routeName, '/home');
      expect(navigate.arguments, 42);
      expect(navigate.isReplacement, isTrue);
      expect((received[1] as PopRoute).result, 'result');

      await subscription.cancel();
      await cubit.close();
    });

    test('does not replay events to later listeners', () async {
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

    test('does not emit events after the cubit is closed', () async {
      final cubit = _TestCubit();
      final received = <BaseUiEvent>[];
      final subscription = cubit.uiEventStream.listen(received.add);
      await cubit.close();

      cubit.emitEvent(const ShowSuccessMessage('after close'));
      await Future<void>.delayed(Duration.zero);

      expect(received, isEmpty);
      await subscription.cancel();
    });
  });
}
