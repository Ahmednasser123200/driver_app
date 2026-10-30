import 'package:driver_app/config/base/base_response.dart' as base;
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/domain/use_case/get_order_history_details_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockOrderHistoryRepo mockRepo;
  late GetOrderHistoryDetailsUseCase useCase;

  setUp(() {
    mockRepo = MockOrderHistoryRepo();
    useCase = GetOrderHistoryDetailsUseCase(mockRepo);
  });

  test('returns Error(NotFoundFailure) and never calls repo for empty or whitespace orderId', () async {
    final resultEmpty = await useCase.execute(orderId: '');
    final resultWhitespace = await useCase.execute(orderId: '   ');

    expect(resultEmpty, isA<base.Error<OrderHistoryDetailsEntity>>());
    expect(
      (resultEmpty as base.Error<OrderHistoryDetailsEntity>).failure,
      isA<NotFoundFailure>(),
    );

    expect(resultWhitespace, isA<base.Error<OrderHistoryDetailsEntity>>());
    expect(
      (resultWhitespace as base.Error<OrderHistoryDetailsEntity>).failure,
      isA<NotFoundFailure>(),
    );

    verifyZeroInteractions(mockRepo);
  });

  test('delegates to repo for valid orderId', () async {
    final expectedData = createOrderHistoryDetailsEntity();
    when(() => mockRepo.getOrderDetails(orderId: 'order123')).thenAnswer(
      (_) async => base.Success(expectedData),
    );

    final result = await useCase.execute(orderId: 'order123');

    verify(() => mockRepo.getOrderDetails(orderId: 'order123')).called(1);
    expect(result, isA<base.Success<OrderHistoryDetailsEntity>>());
  });
}
