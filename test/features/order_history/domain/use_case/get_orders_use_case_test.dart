import 'package:driver_app/config/base/base_response.dart' as base;
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/domain/entities/pagination_entities.dart';
import 'package:driver_app/features/order_history/domain/use_case/get_orders_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockOrderHistoryRepo mockRepo;
  late GetOrdersUseCase useCase;

  setUp(() {
    mockRepo = MockOrderHistoryRepo();
    useCase = GetOrdersUseCase(mockRepo);
  });

  test('delegates getOrders call to repo', () async {
    final expectedData = createPaginatedEntity<OrderHistoryEntity>();
    when(() => mockRepo.getOrders(page: 1, pageSize: 10)).thenAnswer(
      (_) async => base.Success(expectedData),
    );

    final result = await useCase.execute(page: 1, pageSize: 10);

    verify(() => mockRepo.getOrders(page: 1, pageSize: 10)).called(1);
    expect(result, isA<base.Success<PaginatedEntity<OrderHistoryEntity>>>());
  });
}
