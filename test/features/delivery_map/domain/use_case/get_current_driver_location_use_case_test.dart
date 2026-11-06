import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_current_driver_location_use_case.dart';
import 'package:driver_app/features/order_details/domain/entities/user_location_entity.dart';
import 'package:driver_app/features/order_details/domain/repo/order_details_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderDetailsRepo extends Mock implements OrderDetailsRepo {}

void main() {
  late MockOrderDetailsRepo mockRepo;
  late GetCurrentDriverLocationUseCase useCase;

  setUp(() {
    mockRepo = MockOrderDetailsRepo();
    useCase = GetCurrentDriverLocationUseCase(mockRepo);
  });

  group('GetCurrentDriverLocationUseCase', () {
    test('delegates getCurrentDriverLocation to OrderDetailsRepo', () async {
      final entity = UserLocationEntity(
        latitude: 30.0444,
        longitude: 31.2357,
        timestamp: DateTime.utc(2026, 11, 3),
      );
      when(() => mockRepo.getCurrentDriverLocation())
          .thenAnswer((_) async => Success(entity));

      final result = await useCase();

      expect(result, isA<Success<UserLocationEntity?>>());
      expect((result as Success<UserLocationEntity?>).data, equals(entity));
      verify(() => mockRepo.getCurrentDriverLocation()).called(1);
    });
  });
}
