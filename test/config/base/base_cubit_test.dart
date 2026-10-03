import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:flutter_test/flutter_test.dart';

class TestCubit extends BaseCubit<int, BaseUiEvent> {
  TestCubit() : super(0);
}

void main() {
  group('BaseCubit', () {
    late TestCubit cubit;

    setUp(() {
      cubit = TestCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('emitEvent pushes event to uiEventStream', () async {
      final event = const ShowSuccessMessage('hello');

      expectLater(cubit.uiEventStream, emitsInOrder([event]));

      cubit.emitEvent(event);
    });

    test('does not emit events after closed', () async {
      await cubit.close();
      cubit.emitEvent(const ShowSuccessMessage('hello'));

      expect(cubit.uiEventStream, emitsDone);
    });
  });
}
