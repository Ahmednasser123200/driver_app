import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/params/report_driver_location_params.dart';
import 'package:driver_app/features/order_details/domain/params/update_order_status_params.dart';
import 'package:driver_app/features/order_details/domain/repo/order_details_repo.dart';
import 'package:driver_app/features/order_details/domain/usecases/get_driver_order_details_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockOrderDetailsRepo extends Mock implements OrderDetailsRepo {}

void main() {
  late MockOrderDetailsRepo repository;
  late GetDriverOrderDetailsUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      const UpdateOrderStatusParams(orderId: '', newStatus: ''),
    );
    registerFallbackValue(
      const ReportDriverLocationParams(lat: 0, lng: 0, recordedAt: ''),
    );
  });

  setUp(() {
    repository = MockOrderDetailsRepo();
    useCase = GetDriverOrderDetailsUseCase(repository);
  });

  group('success path', () {
    test('returns the entity produced by the repository', () async {
      final entity = buildDriverOrderDetailsEntity();
      when(() => repository.getOrderDetails(any()))
          .thenAnswer((_) async => Success(entity));

      final result = await useCase.execute(kOrderId);

      expect(result, isA<Success<DriverOrderDetailsEntity>>());
      expect(
        (result as Success<DriverOrderDetailsEntity>).data,
        same(entity),
      );
    });

    test('forwards the orderId to the repository unchanged', () async {
      when(() => repository.getOrderDetails(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity()),
      );

      await useCase.execute(kOrderId);

      verify(() => repository.getOrderDetails(kOrderId)).called(1);
    });

    test('calls getOrderDetails exactly once and no other repo method', () async {
      when(() => repository.getOrderDetails(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity()),
      );

      await useCase.execute(kOrderId);

      verify(() => repository.getOrderDetails(any())).called(1);
      verifyNever(() => repository.updateOrderStatus(any()));
      verifyNever(() => repository.reportDriverLocation(any()));
    });
  });

  group('failure path', () {
    test('returns the error emitted by the repository', () async {
      when(() => repository.getOrderDetails(any())).thenAnswer(
        (_) async => Error<DriverOrderDetailsEntity>(
          const ConflictFailure(serverMessage: 'busy'),
        ),
      );

      final result = await useCase.execute(kOrderId);

      expect(result, isA<Error<DriverOrderDetailsEntity>>());
      expect(
        (result as Error<DriverOrderDetailsEntity>).failure,
        isA<ConflictFailure>().having(
          (f) => f.serverMessage,
          'serverMessage',
          'busy',
        ),
      );
    });

    test('does not swallow a thrown exception', () async {
      when(() => repository.getOrderDetails(any())).thenThrow(
        StateError('repo exploded'),
      );

      await expectLater(
        () => useCase.execute(kOrderId),
        throwsA(isA<StateError>()),
      );
    });
  });
}