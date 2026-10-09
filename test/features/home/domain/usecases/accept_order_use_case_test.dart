import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/home/domain/usecases/accept_order_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../home_test_fixtures.dart';

void main() {
  late MockHomeRepo repo;
  late AcceptOrderUseCase useCase;

  setUp(() {
    repo = MockHomeRepo();
    useCase = AcceptOrderUseCase(repo);
  });

  test('forwards the order id to the repository', () async {
    when(
      () => repo.acceptOrder('order-1'),
    ).thenAnswer((_) async => const Success<void>(null));

    final result = await useCase.call('order-1');

    expect(result, isA<Success<void>>());
    verify(() => repo.acceptOrder('order-1')).called(1);
  });

  test('propagates repository failures', () async {
    when(
      () => repo.acceptOrder('order-1'),
    ).thenAnswer((_) async => const Error<void>(ConflictFailure()));

    final result = await useCase.call('order-1');

    expect((result as Error<void>).failure, isA<ConflictFailure>());
  });
}
