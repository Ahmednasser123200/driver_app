import 'package:driver_app/features/delivery_map/domain/use_case/check_location_permission_use_case.dart';
import 'package:driver_app/features/order_details/domain/repo/order_details_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderDetailsRepo extends Mock implements OrderDetailsRepo {}

void main() {
  late MockOrderDetailsRepo mockRepo;
  late CheckLocationPermissionUseCase useCase;

  setUp(() {
    mockRepo = MockOrderDetailsRepo();
    useCase = CheckLocationPermissionUseCase(mockRepo);
  });

  group('CheckLocationPermissionUseCase', () {
    test('delegates permission check to OrderDetailsRepo', () async {
      when(() => mockRepo.checkAndRequestLocationPermission())
          .thenAnswer((_) async => true);

      final result = await useCase();

      expect(result, isTrue);
      verify(() => mockRepo.checkAndRequestLocationPermission()).called(1);
    });
  });
}
