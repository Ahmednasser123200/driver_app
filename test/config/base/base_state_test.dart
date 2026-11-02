import 'package:driver_app/config/base/base_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BaseState defaults', () {
    test('a default state is not loading, has no message and no data', () {
      const state = BaseState<String>();

      expect(state.isLoading, isFalse);
      expect(state.errorMessage, '');
      expect(state.data, isNull);
    });
  });

  group('BaseState.copyWith', () {
    test('returns an equal state when no argument is provided', () {
      const state = BaseState<String>(
        isLoading: true,
        errorMessage: 'boom',
        data: 'payload',
      );

      final result = state.copyWith();

      expect(result, state);
    });

    test('updates only isLoading', () {
      const state = BaseState<String>(errorMessage: 'boom', data: 'payload');

      final result = state.copyWith(isLoading: true);

      expect(result.isLoading, isTrue);
      expect(result.errorMessage, 'boom');
      expect(result.data, 'payload');
    });

    test('updates only errorMessage', () {
      const state = BaseState<String>(isLoading: true, data: 'payload');

      final result = state.copyWith(errorMessage: 'new error');

      expect(result.errorMessage, 'new error');
      expect(result.isLoading, isTrue);
      expect(result.data, 'payload');
    });

    test('replaces data with a new value', () {
      const state = BaseState<String>(data: 'old');

      final result = state.copyWith(data: 'new');

      expect(result.data, 'new');
    });

    test('explicitly passing null data clears it (sentinel behaviour)', () {
      const state = BaseState<String>(data: 'payload');

      final result = state.copyWith(data: null);

      expect(result.data, isNull);
    });

    test('omitting data keeps the previous value', () {
      const state = BaseState<String>(data: 'payload');

      final result = state.copyWith(isLoading: true);

      expect(result.data, 'payload');
    });

    test('supports nullable payload types', () {
      const state = BaseState<int?>(data: 7);

      expect(state.copyWith().data, 7);
      expect(state.copyWith(data: null).data, isNull);
      expect(state.copyWith(data: 9).data, 9);
    });
  });

  group('BaseState equality', () {
    test('states with identical values are equal', () {
      const a = BaseState<String>(isLoading: true, errorMessage: 'e', data: 'd');
      const b = BaseState<String>(isLoading: true, errorMessage: 'e', data: 'd');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('states differing in any prop are not equal', () {
      const base = BaseState<String>(isLoading: true, errorMessage: 'e', data: 'd');

      expect(base, isNot(base.copyWith(isLoading: false)));
      expect(base, isNot(base.copyWith(errorMessage: 'other')));
      expect(base, isNot(base.copyWith(data: 'other')));
    });
  });
}