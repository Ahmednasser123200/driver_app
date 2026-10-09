import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/home/domain/entities/available_orders.dart';
import 'package:driver_app/features/home/domain/usecases/get_available_orders_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../home_test_fixtures.dart';

void main() {
  late MockHomeRepo repo;
  late GetAvailableOrdersUseCase useCase;

  setUp(() {
    repo = MockHomeRepo();
    useCase = GetAvailableOrdersUseCase(repo);
  });

  test('forwards the default page (1) to the repository', () async {
    final orders = buildAvailableOrders();
    when(
      () => repo.getAvailableOrders(page: 1),
    ).thenAnswer((_) async => Success<AvailableOrders>(orders));

    final result = await useCase.call();

    expect(result, isA<Success<AvailableOrders>>());
    expect((result as Success<AvailableOrders>).data, same(orders));
    verify(() => repo.getAvailableOrders(page: 1)).called(1);
  });

  test('forwards a custom page to the repository', () async {
    final orders = buildAvailableOrders();
    when(
      () => repo.getAvailableOrders(page: 4),
    ).thenAnswer((_) async => Success<AvailableOrders>(orders));

    await useCase.call(page: 4);

    verify(() => repo.getAvailableOrders(page: 4)).called(1);
  });

  test('propagates repository failures', () async {
    when(
      () => repo.getAvailableOrders(page: 1),
    ).thenAnswer((_) async => const Error<AvailableOrders>(ServerFailure()));

    final result = await useCase.call();

    expect((result as Error<AvailableOrders>).failure, isA<ServerFailure>());
  });
}
