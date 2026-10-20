import 'package:driver_app/config/base/base_response.dart' as base;
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockGetOrderDetailsUseCase mockGetOrderDetailsUseCase;
  late OrderDetailsCubit cubit;

  setUpAll(() {
    setupFallbackValues();
  });

  setUp(() {
    mockGetOrderDetailsUseCase = MockGetOrderDetailsUseCase();
    cubit = OrderDetailsCubit(mockGetOrderDetailsUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is correct', () {
    expect(cubit.state, const OrderDetailsState());
  });

  test('OrderDetailsState equality', () {
    const s1 = OrderDetailsState();
    const s2 = OrderDetailsState();
    const s3 = OrderDetailsState(failure: NotFoundFailure());

    expect(s1, equals(s2));
    expect(s1, isNot(equals(s3)));
  });

  test('get details success emits loading then loaded', () async {
    final details = createOrderHistoryDetailsEntity(orderId: 'order123');
    when(
      () => mockGetOrderDetailsUseCase.execute(orderId: 'order123'),
    ).thenAnswer((_) async => base.Success(details));

    final statesFuture = expectLater(
      cubit.stream,
      emitsInOrder([
        predicate<OrderDetailsState>(
          (state) => state.orderDetails.isLoading && state.orderDetails.data == null,
        ),
        predicate<OrderDetailsState>(
          (state) =>
              !state.orderDetails.isLoading &&
              state.orderDetails.data == details &&
              state.failure == null,
        ),
      ]),
    );

    await cubit.doIntent(GetOrderDetailsEvent(orderId: 'order123'));
    await statesFuture;

    expect(cubit.state.orderDetails.data, details);
    expect(cubit.state.failure, isNull);
  });

  test('failure keeps previous data, sets failure and emits ShowFailure', () async {
    final initialDetails = createOrderHistoryDetailsEntity(orderId: 'prev');
    when(
      () => mockGetOrderDetailsUseCase.execute(orderId: 'prev'),
    ).thenAnswer((_) async => base.Success(initialDetails));

    await cubit.doIntent(GetOrderDetailsEvent(orderId: 'prev'));

    const failure = NotFoundFailure();
    when(
      () => mockGetOrderDetailsUseCase.execute(orderId: 'order123'),
    ).thenAnswer((_) async => const base.Error(failure));

    final statesFuture = expectLater(
      cubit.stream,
      emitsInOrder([
        predicate<OrderDetailsState>(
          (state) =>
              state.orderDetails.isLoading &&
              state.orderDetails.data == initialDetails,
        ),
        predicate<OrderDetailsState>(
          (state) =>
              !state.orderDetails.isLoading &&
              state.orderDetails.data == initialDetails &&
              state.failure == failure,
        ),
      ]),
    );
    final eventFuture = expectLater(
      cubit.uiEventStream,
      emits(predicate<BaseUiEvent>((event) {
        return event is ShowFailure && event.failure == failure;
      })),
    );

    await cubit.doIntent(GetOrderDetailsEvent(orderId: 'order123'));
    await statesFuture;
    await eventFuture;

    expect(cubit.state.orderDetails.data, initialDetails);
    expect(cubit.state.failure, failure);
  });
}
