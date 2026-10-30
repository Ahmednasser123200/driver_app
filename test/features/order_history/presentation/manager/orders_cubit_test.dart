import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:driver_app/config/base/base_response.dart' as base;
import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/domain/entities/pagination_entities.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_constants.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockGetOrdersUseCase mockGetOrdersUseCase;
  late OrdersCubit cubit;

  setUpAll(() {
    setupFallbackValues();
  });

  setUp(() {
    mockGetOrdersUseCase = MockGetOrdersUseCase();
    cubit = OrdersCubit(mockGetOrdersUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  List<OrderHistoryEntity> orders(int count, {OrderStatus status = OrderStatus.completed}) {
    return List.generate(
      count,
      (i) => createOrderHistoryEntity(orderId: '$i', status: status),
    );
  }

  test('initial state is correct', () {
    expect(cubit.state, const OrdersState());
  });

  blocTest<OrdersCubit, OrdersState>(
    'load success emits loading then loaded with counts and null failure when no next page',
    build: () {
      final paginated = createPaginatedEntity(
        items: [
          createOrderHistoryEntity(orderId: '1', status: OrderStatus.completed),
          createOrderHistoryEntity(orderId: '2', status: OrderStatus.cancelled),
        ],
        pagination: createPaginationEntity(page: 1, hasNextPage: false),
      );
      when(
        () => mockGetOrdersUseCase.execute(
          page: 1,
          pageSize: OrderHistoryConstants.pageSize,
        ),
      ).thenAnswer((_) async => base.Success(paginated));
      return cubit;
    },
    act: (cubit) => cubit.doIntent(LoadOrdersEvent()),
    expect: () => [
      const OrdersState(
        ordersListState: BaseState(isLoading: true, data: null),
      ),
      OrdersState(
        ordersListState: BaseState(
          isLoading: false,
          data: OrdersDataState(
            orders: [
              createOrderHistoryEntity(
                orderId: '1',
                status: OrderStatus.completed,
              ),
              createOrderHistoryEntity(
                orderId: '2',
                status: OrderStatus.cancelled,
              ),
            ],
            pagination: createPaginationEntity(page: 1, hasNextPage: false),
            completedCount: 1,
            cancelledCount: 1,
          ),
        ),
      ),
    ],
  );

  test('load failure sets failure, keeps previous data and emits ShowFailure', () async {
    const failure = TimeoutFailure();
    when(
      () => mockGetOrdersUseCase.execute(
        page: 1,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    ).thenAnswer((_) async => const base.Error(failure));

    final eventFuture = expectLater(
      cubit.uiEventStream,
      emits(predicate<BaseUiEvent>((event) {
        return event is ShowFailure && event.failure == failure;
      })),
    );

    await cubit.doIntent(LoadOrdersEvent());
    await eventFuture;

    expect(cubit.state.failure, failure);
    expect(cubit.state.ordersListState.data, isNull);
    expect(cubit.state.ordersListState.isLoading, isFalse);
  });

  test('progressive counting loop updates counts page by page without increasing visible orders', () async {
    final page1 = createPaginatedEntity(
      items: orders(10, status: OrderStatus.completed),
      pagination: createPaginationEntity(page: 1, hasNextPage: true),
    );
    final page2 = createPaginatedEntity(
      items: [
        createOrderHistoryEntity(orderId: 'p2_1', status: OrderStatus.completed),
        createOrderHistoryEntity(orderId: 'p2_2', status: OrderStatus.completed),
        createOrderHistoryEntity(orderId: 'p2_3', status: OrderStatus.cancelled),
      ],
      pagination: createPaginationEntity(page: 2, hasNextPage: true),
    );
    final page3 = createPaginatedEntity(
      items: [
        createOrderHistoryEntity(orderId: 'p3_1', status: OrderStatus.completed),
      ],
      pagination: createPaginationEntity(page: 3, hasNextPage: false),
    );

    when(
      () => mockGetOrdersUseCase.execute(
        page: 1,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    ).thenAnswer((_) async => base.Success(page1));
    when(
      () => mockGetOrdersUseCase.execute(
        page: 2,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    ).thenAnswer((_) async => base.Success(page2));
    when(
      () => mockGetOrdersUseCase.execute(
        page: 3,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    ).thenAnswer((_) async => base.Success(page3));

    await cubit.doIntent(LoadOrdersEvent());
    await Future.delayed(Duration.zero);

    // Orders list length stays 10 (page 1 length)
    expect(cubit.state.ordersListState.data?.orders.length, 10);
    // Counts accumulate: page 1 (10 comp, 0 canc) + page 2 (2 comp, 1 canc) + page 3 (1 comp, 0 canc) = 13 comp, 1 canc
    expect(cubit.state.ordersListState.data?.completedCount, 13);
    expect(cubit.state.ordersListState.data?.cancelledCount, 1);
  });

  test('refresh cancels running background count', () async {
    final page1 = createPaginatedEntity(
      items: orders(10, status: OrderStatus.completed),
      pagination: createPaginationEntity(page: 1, hasNextPage: true),
    );
    final page2Completer = Completer<base.BaseResponse<PaginatedEntity<OrderHistoryEntity>>>();

    when(
      () => mockGetOrdersUseCase.execute(
        page: 1,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    ).thenAnswer((_) async => base.Success(page1));
    when(
      () => mockGetOrdersUseCase.execute(
        page: 2,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    ).thenAnswer((_) => page2Completer.future);

    final load1 = cubit.doIntent(LoadOrdersEvent());
    await Future.delayed(Duration.zero);

    // Now user refreshes while page 2 counting is in flight
    final page1Refresh = createPaginatedEntity(
      items: [createOrderHistoryEntity(orderId: 'fresh', status: OrderStatus.cancelled)],
      pagination: createPaginationEntity(page: 1, hasNextPage: false),
    );
    when(
      () => mockGetOrdersUseCase.execute(
        page: 1,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    ).thenAnswer((_) async => base.Success(page1Refresh));

    final load2 = cubit.doIntent(LoadOrdersEvent());

    // Resolve old page 2
    page2Completer.complete(
      base.Success(
        createPaginatedEntity(
          items: [createOrderHistoryEntity(orderId: 'stale', status: OrderStatus.completed)],
          pagination: createPaginationEntity(page: 2, hasNextPage: false),
        ),
      ),
    );

    await load1;
    await load2;

    // The state should reflect only the fresh refresh (cancelledCount: 1, completedCount: 0)
    expect(cubit.state.ordersListState.data?.orders.first.orderId, 'fresh');
    expect(cubit.state.ordersListState.data?.completedCount, 0);
    expect(cubit.state.ordersListState.data?.cancelledCount, 1);
  });

  test('failed counting page stops counting loop and keeps partial counts without setting state.failure', () async {
    final page1 = createPaginatedEntity(
      items: orders(10, status: OrderStatus.completed),
      pagination: createPaginationEntity(page: 1, hasNextPage: true),
    );

    when(
      () => mockGetOrdersUseCase.execute(
        page: 1,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    ).thenAnswer((_) async => base.Success(page1));
    when(
      () => mockGetOrdersUseCase.execute(
        page: 2,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    ).thenAnswer((_) async => const base.Error(TimeoutFailure()));

    await cubit.doIntent(LoadOrdersEvent());
    await Future.delayed(Duration.zero);

    expect(cubit.state.ordersListState.data?.completedCount, 10);
    expect(cubit.state.ordersListState.data?.cancelledCount, 0);
    expect(cubit.state.failure, isNull);
  });

  test('loadMore appends orders and updates pagination without altering page 1 counts', () async {
    final page1 = createPaginatedEntity(
      items: orders(OrderHistoryConstants.pageSize, status: OrderStatus.completed),
      pagination: createPaginationEntity(page: 1, hasNextPage: true),
    );
    final page2 = createPaginatedEntity(
      items: [createOrderHistoryEntity(orderId: 'next', status: OrderStatus.cancelled)],
      pagination: createPaginationEntity(page: 2, hasNextPage: false),
    );

    // Page 1 load will trigger background counting for page 2
    when(
      () => mockGetOrdersUseCase.execute(
        page: 1,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    ).thenAnswer((_) async => base.Success(page1));
    when(
      () => mockGetOrdersUseCase.execute(
        page: 2,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    ).thenAnswer((_) async => base.Success(page2));

    await cubit.doIntent(LoadOrdersEvent());
    expect(cubit.state.ordersListState.data?.orders.length, 10);
    expect(cubit.state.ordersListState.data?.pagination?.page, 1);

    await cubit.doIntent(LoadMoreOrdersEvent());
    expect(cubit.state.ordersListState.data?.orders.length, 11);
    expect(cubit.state.ordersListState.data?.orders.last.orderId, 'next');
    expect(cubit.state.ordersListState.data?.pagination?.page, 2);
    expect(cubit.state.ordersListState.data?.pagination?.hasNextPage, isFalse);
    await Future.delayed(Duration.zero);
    expect(cubit.state.ordersListState.data?.completedCount, 10);
    expect(cubit.state.ordersListState.data?.cancelledCount, 1);
  });

  test('loadMore does nothing when there is no next page', () async {
    final page1 = createPaginatedEntity(
      items: orders(OrderHistoryConstants.pageSize),
      pagination: createPaginationEntity(page: 1, hasNextPage: false),
    );

    when(
      () => mockGetOrdersUseCase.execute(
        page: 1,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    ).thenAnswer((_) async => base.Success(page1));

    await cubit.doIntent(LoadOrdersEvent());
    await cubit.doIntent(LoadMoreOrdersEvent());

    verifyNever(
      () => mockGetOrdersUseCase.execute(
        page: 2,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    );
  });

  test('loadMore does nothing when already loading', () async {
    final completer =
        Completer<base.BaseResponse<PaginatedEntity<OrderHistoryEntity>>>();
    when(
      () => mockGetOrdersUseCase.execute(
        page: 1,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    ).thenAnswer((_) => completer.future);

    final loadFuture = cubit.doIntent(LoadOrdersEvent());
    expect(cubit.state.ordersListState.isLoading, isTrue);

    await cubit.doIntent(LoadMoreOrdersEvent());
    verifyNever(
      () => mockGetOrdersUseCase.execute(
        page: 2,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    );

    completer.complete(
      base.Success(
        createPaginatedEntity(
          items: orders(OrderHistoryConstants.pageSize),
          pagination: createPaginationEntity(page: 1, hasNextPage: false),
        ),
      ),
    );
    await loadFuture;
  });

  test('toggle filter on and off updates visibleOrders', () async {
    final page = createPaginatedEntity(
      items: [
        ...orders(5, status: OrderStatus.completed),
        ...orders(5, status: OrderStatus.cancelled),
      ],
      pagination: createPaginationEntity(page: 1, hasNextPage: false),
    );

    when(
      () => mockGetOrdersUseCase.execute(
        page: 1,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    ).thenAnswer((_) async => base.Success(page));

    await cubit.doIntent(LoadOrdersEvent());
    expect(cubit.state.visibleOrders.length, 10);

    await cubit.doIntent(ToggleStatusFilterEvent(OrderStatus.completed));
    expect(cubit.state.statusFilter, OrderStatus.completed);
    expect(cubit.state.visibleOrders.length, 5);
    expect(
      cubit.state.visibleOrders.every((o) => o.status == OrderStatus.completed),
      isTrue,
    );

    await cubit.doIntent(ToggleStatusFilterEvent(OrderStatus.completed));
    expect(cubit.state.statusFilter, isNull);
    expect(cubit.state.visibleOrders.length, 10);
  });

  test('stale response is dropped when refresh happens while loadMore is pending', () async {
    final page2Completer =
        Completer<base.BaseResponse<PaginatedEntity<OrderHistoryEntity>>>();
    final refreshCompleter =
        Completer<base.BaseResponse<PaginatedEntity<OrderHistoryEntity>>>();

    when(
      () => mockGetOrdersUseCase.execute(
        page: 1,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    ).thenAnswer(
      (_) async => base.Success(
        createPaginatedEntity(
          items: orders(OrderHistoryConstants.pageSize),
          pagination: createPaginationEntity(page: 1, hasNextPage: true),
        ),
      ),
    );

    when(
      () => mockGetOrdersUseCase.execute(
        page: 2,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    ).thenAnswer((_) => page2Completer.future);

    await cubit.doIntent(LoadOrdersEvent());
    expect(cubit.state.ordersListState.data?.orders.length, 10);

    final loadMoreFuture = cubit.doIntent(LoadMoreOrdersEvent());

    when(
      () => mockGetOrdersUseCase.execute(
        page: 1,
        pageSize: OrderHistoryConstants.pageSize,
      ),
    ).thenAnswer((_) => refreshCompleter.future);

    final refreshFuture = cubit.doIntent(LoadOrdersEvent());

    page2Completer.complete(
      base.Success(
        createPaginatedEntity(
          items: [createOrderHistoryEntity(orderId: 'stale')],
          pagination: createPaginationEntity(page: 2, hasNextPage: false),
        ),
      ),
    );
    await loadMoreFuture;

    refreshCompleter.complete(
      base.Success(
        createPaginatedEntity(
          items: [createOrderHistoryEntity(orderId: 'fresh')],
          pagination: createPaginationEntity(page: 1, hasNextPage: false),
        ),
      ),
    );
    await refreshFuture;

    expect(cubit.state.ordersListState.data?.orders.length, 1);
    expect(cubit.state.ordersListState.data?.orders.first.orderId, 'fresh');
  });
}
