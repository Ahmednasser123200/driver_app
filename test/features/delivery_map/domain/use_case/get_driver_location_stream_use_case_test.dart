import 'dart:async';

import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_driver_location_stream_use_case.dart';
import 'package:driver_app/features/order_details/domain/entities/user_location_entity.dart';
import 'package:driver_app/features/order_details/domain/repo/order_details_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderDetailsRepo extends Mock implements OrderDetailsRepo {}

void main() {
  late MockOrderDetailsRepo mockOrderDetailsRepo;
  late StreamController<BaseResponse<UserLocationEntity>>
      locationStreamController;
  late GetDriverLocationStreamUseCase useCase;

  setUp(() {
    mockOrderDetailsRepo = MockOrderDetailsRepo();
    locationStreamController =
        StreamController<BaseResponse<UserLocationEntity>>.broadcast();
    when(() => mockOrderDetailsRepo.driverLocationStream)
        .thenAnswer((_) => locationStreamController.stream);

    useCase = GetDriverLocationStreamUseCase(mockOrderDetailsRepo);
  });

  tearDown(() async {
    await locationStreamController.close();
  });

  UserLocationEntity createEntity({
    double latitude = 30.0444,
    double longitude = 31.2357,
  }) {
    return UserLocationEntity(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.utc(2026, 11, 3),
    );
  }

  group('GetDriverLocationStreamUseCase', () {
    test('call returns the driverLocationStream from OrderDetailsRepo', () {
      final expectedStream = locationStreamController.stream;
      final stream = useCase.call();

      expect(stream, equals(expectedStream));
      verify(() => mockOrderDetailsRepo.driverLocationStream).called(1);
    });

    test('emits BaseResponse<UserLocationEntity> values in order', () async {
      final stream = useCase();
      final item1 = Success(createEntity(latitude: 30.0444, longitude: 31.2357));
      final item2 = Success(createEntity(latitude: 30.0450, longitude: 31.2365));

      expectLater(stream, emitsInOrder([item1, item2]));

      locationStreamController.add(item1);
      locationStreamController.add(item2);
    });

    test('emits mapped Error responses without raw exceptions', () async {
      final stream = useCase();
      const failureResponse =
          Error<UserLocationEntity>(LocationServiceDisabledFailure());

      expectLater(stream, emits(failureResponse));

      locationStreamController.add(failureResponse);
    });
  });
}
