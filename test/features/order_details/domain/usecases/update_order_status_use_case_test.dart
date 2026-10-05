import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:driver_app/features/order_details/domain/params/update_order_status_params.dart';
import 'package:driver_app/features/order_details/domain/repo/order_details_repo.dart';
import 'package:driver_app/features/order_details/domain/usecases/update_order_status_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockOrderDetailsRepo extends Mock implements OrderDetailsRepo {}

void main() {
  late MockOrderDetailsRepo repository;
  late UpdateOrderStatusUseCase useCase;
  late UpdateOrderStatusParams params;

  setUpAll(() {
    registerFallbackValue(
      const UpdateOrderStatusParams(orderId: '', newStatus: ''),
    );
  });

  setUp(() {
    repository = MockOrderDetailsRepo();
    useCase = UpdateOrderStatusUseCase(repository);
    params = const UpdateOrderStatusParams(
      orderId: kOrderId,
      newStatus: 'PickedUp',
    );
  });

  group('success path', () {
    test('returns the entity produced by the repository', () async {
      final entity = buildUpdateOrderStatusEntity();
      when(() => repository.updateOrderStatus(any()))
          .thenAnswer((_) async => Success(entity));

      final result = await useCase.execute(params);

      expect(result, isA<Success<UpdateOrderStatusEntity>>());
      expect((result as Success<UpdateOrderStatusEntity>).data, same(entity));
    });

    test('forwards the exact params instance to the repository', () async {
      when(() => repository.updateOrderStatus(any())).thenAnswer(
        (_) async => Success(buildUpdateOrderStatusEntity()),
      );

      await useCase.execute(params);

      verify(() => repository.updateOrderStatus(params)).called(1);
    });

    test('passes each documented backend status through untouched', () async {
      for (final status in [
        'PickedUp',
        'OutForDelivery',
        'AwaitingDeliveryConfirmation',
      ]) {
        when(() => repository.updateOrderStatus(any())).thenAnswer(
          (_) async => Success(buildUpdateOrderStatusEntity()),
        );

        await useCase.execute(
          UpdateOrderStatusParams(orderId: kOrderId, newStatus: status),
        );

        final captured =
            verify(() => repository.updateOrderStatus(captureAny()))
                .captured
                .single as UpdateOrderStatusParams;

        expect(captured.orderId, kOrderId);
        expect(captured.newStatus, status);
      }
    });
  });

  group('failure path', () {
    test('returns the error emitted by the repository', () async {
      when(() => repository.updateOrderStatus(any())).thenAnswer(
        (_) async => Error<UpdateOrderStatusEntity>(
          const ConflictFailure(
            serverMessage: 'You already have an active delivery in progress.',
          ),
        ),
      );

      final result = await useCase.execute(params);

      expect(result, isA<Error<UpdateOrderStatusEntity>>());
      expect(
        (result as Error<UpdateOrderStatusEntity>).failure,
        isA<ConflictFailure>().having(
          (f) => f.serverMessage,
          'serverMessage',
          'You already have an active delivery in progress.',
        ),
      );
    });

    test('propagates thrown exceptions', () async {
      when(() => repository.updateOrderStatus(any())).thenThrow(
        StateError('boom'),
      );

      await expectLater(
        () => useCase.execute(params),
        throwsA(isA<StateError>()),
      );
    });
  });
}