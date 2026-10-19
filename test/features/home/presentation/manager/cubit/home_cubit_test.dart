import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/localization/handle_success_text.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/features/home/domain/entities/available_orders.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_cubit.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_event.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../home_test_fixtures.dart';

void main() {
  late MockGetAvailableOrdersUseCase getOrders;
  late MockAcceptOrderUseCase acceptOrder;

  HomeCubit buildCubit() => HomeCubit(
    getAvailableOrdersUseCase: getOrders,
    acceptOrderUseCase: acceptOrder,
  );

  setUp(() {
    getOrders = MockGetAvailableOrdersUseCase();
    acceptOrder = MockAcceptOrderUseCase();
    // A driver without a delivery resolves to "no active order"; tests that
    // care about the highlight stub their own answer.
    when(
      () => acceptOrder.getActiveOrderId(),
    ).thenAnswer((_) async => const Success<String>(''));
  });

  test('initial state defaults to an empty, non-loading state', () {
    final cubit = buildCubit();

    expect(cubit.state, const HomeState());
    expect(cubit.state.getAvailableOrdersState.isLoading, isFalse);
    expect(cubit.state.getAvailableOrdersState.data, isNull);
    expect(cubit.state.acceptOrderId, isEmpty);
    // Unknown until the backend answers: no button may be enabled yet.
    expect(cubit.state.activeOrderId, isNull);
    expect(cubit.state.isLoadingMore, isFalse);

    addTearDown(cubit.close);
  });

  group('GetAvailableOrdersEvent', () {
    blocTest<HomeCubit, HomeState>(
      'emits loading then the loaded orders on success',
      build: () {
        final orders = buildAvailableOrders();
        when(
          () => getOrders.call(page: 1),
        ).thenAnswer((_) async => Success<AvailableOrders>(orders));
        return buildCubit();
      },
      act: (cubit) => cubit.doEvent(GetAvailableOrdersEvent()),
      expect: () => [
        isA<HomeState>().having(
          (state) => state.getAvailableOrdersState.isLoading,
          'isLoading',
          isTrue,
        ),
        isA<HomeState>()
            .having(
              (state) => state.getAvailableOrdersState.isLoading,
              'isLoading',
              isFalse,
            )
            .having(
              (state) => state.getAvailableOrdersState.data,
              'data',
              isNotNull,
            )
            .having(
              (state) => state.getAvailableOrdersState.errorMessage,
              'errorMessage',
              isNull,
            ),
        // The active-order lookup resolved to "no active delivery".
        isA<HomeState>().having(
          (state) => state.activeOrderId,
          'activeOrderId',
          '',
        ),
      ],
      verify: (_) {
        verify(() => getOrders.call(page: 1)).called(1);
        verify(() => acceptOrder.getActiveOrderId()).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'emits loading then the failure on error',
      build: () {
        when(() => getOrders.call(page: 1)).thenAnswer(
          (_) async => const Error<AvailableOrders>(TimeoutFailure()),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.doEvent(GetAvailableOrdersEvent()),
      expect: () => [
        isA<HomeState>().having(
          (state) => state.getAvailableOrdersState.isLoading,
          'isLoading',
          isTrue,
        ),
        isA<HomeState>()
            .having(
              (state) => state.getAvailableOrdersState.isLoading,
              'isLoading',
              isFalse,
            )
            .having(
              (state) => state.getAvailableOrdersState.errorMessage,
              'errorMessage',
              isA<TimeoutFailure>(),
            ),
      ],
      verify: (_) => verifyNever(() => acceptOrder.getActiveOrderId()),
    );

    test('emits a failure UI event on error', () async {
      when(
        () => getOrders.call(page: 1),
      ).thenAnswer((_) async => const Error<AvailableOrders>(ServerFailure()));
      final cubit = buildCubit();
      final events = <BaseUiEvent>[];
      final subscription = cubit.uiEventStream.listen(events.add);

      await cubit.doEvent(GetAvailableOrdersEvent());
      await Future<void>.delayed(Duration.zero);

      final failure = events.whereType<ShowFailureMessage>().single;
      expect(failure.failure, isA<ServerFailure>());
      expect(events.whereType<ShowSuccessMessage>(), isEmpty);

      await subscription.cancel();
      await cubit.close();
    });

    test('stores the driver own order id when one is returned', () async {
      when(() => getOrders.call(page: 1)).thenAnswer(
        (_) async => Success<AvailableOrders>(buildAvailableOrders()),
      );
      when(
        () => acceptOrder.getActiveOrderId(),
      ).thenAnswer((_) async => const Success<String>('active-order-9'));
      final cubit = buildCubit();

      await cubit.doEvent(GetAvailableOrdersEvent());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.activeOrderId, 'active-order-9');

      await cubit.close();
    });

    test('keeps the active order unknown when the lookup fails', () async {
      when(() => getOrders.call(page: 1)).thenAnswer(
        (_) async => Success<AvailableOrders>(buildAvailableOrders()),
      );
      when(
        () => acceptOrder.getActiveOrderId(),
      ).thenAnswer((_) async => const Error<String>(TimeoutFailure()));
      final cubit = buildCubit();

      await cubit.doEvent(GetAvailableOrdersEvent());
      await Future<void>.delayed(Duration.zero);

      // A failed lookup is not proof of absence: the state stays unresolved and
      // the accept request is still sent, with the backend deciding.
      expect(cubit.state.activeOrderId, isNull);
      expect(cubit.state.getAvailableOrdersState.data, isNotNull);
      expect(cubit.state.getAvailableOrdersState.errorMessage, isNull);

      await cubit.close();
    });

    test(
      'keeps the previous active-order value when a later refresh fails',
      () async {
        when(() => acceptOrder.call('order-1')).thenAnswer(
          (_) async => const Error<void>(
            ConflictFailure(serverMessage: 'delivery in progress'),
          ),
        );
        when(
          () => acceptOrder.getActiveOrderId(),
        ).thenAnswer((_) async => const Error<String>(ServerFailure()));
        final cubit = buildCubit();
        cubit.emit(const HomeState(activeOrderId: ''));

        await cubit.doEvent(AcceptOrderEvent('order-1'));
        await Future<void>.delayed(Duration.zero);

        // The failed refresh never invents an active order.
        expect(cubit.state.activeOrderId, isEmpty);
        verify(() => acceptOrder.getActiveOrderId()).called(1);

        await cubit.close();
      },
    );
  });

  group('RefreshActiveOrderEvent', () {
    test('re-reads the driver own order without reloading the list', () async {
      when(
        () => acceptOrder.getActiveOrderId(),
      ).thenAnswer((_) async => const Success<String>('active-order-9'));
      final cubit = buildCubit();

      await cubit.doEvent(RefreshActiveOrderEvent());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.activeOrderId, 'active-order-9');
      verify(() => acceptOrder.getActiveOrderId()).called(1);
      verifyNever(() => getOrders.call());

      await cubit.close();
    });

    test('clears a stale id once the order is no longer active', () async {
      when(
        () => acceptOrder.getActiveOrderId(),
      ).thenAnswer((_) async => const Success<String>(''));
      final cubit = buildCubit()
        ..emit(const HomeState(activeOrderId: 'active-order-9'));

      await cubit.doEvent(RefreshActiveOrderEvent());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.activeOrderId, isEmpty);

      await cubit.close();
    });

    test('keeps the previous value when the re-read fails', () async {
      when(
        () => acceptOrder.getActiveOrderId(),
      ).thenAnswer((_) async => const Error<String>(ServerFailure()));
      final cubit = buildCubit()
        ..emit(const HomeState(activeOrderId: 'active-order-9'));

      await cubit.doEvent(RefreshActiveOrderEvent());
      await Future<void>.delayed(Duration.zero);

      // A failed lookup proves nothing: the button keeps its last known id.
      expect(cubit.state.activeOrderId, 'active-order-9');

      await cubit.close();
    });
  });

  group('AcceptOrderEvent', () {
    blocTest<HomeCubit, HomeState>(
      'locks the request, then clears it and stores the new active order',
      build: () {
        when(
          () => acceptOrder.call('order-1'),
        ).thenAnswer((_) async => const Success<void>(null));
        return buildCubit();
      },
      act: (cubit) => cubit.doEvent(AcceptOrderEvent('order-1')),
      expect: () => [
        isA<HomeState>().having(
          (state) => state.acceptOrderId,
          'acceptOrderId',
          'order-1',
        ),
        isA<HomeState>()
            .having((state) => state.acceptOrderId, 'acceptOrderId', '')
            .having((state) => state.activeOrderId, 'activeOrderId', 'order-1'),
      ],
      verify: (cubit) {
        verify(() => acceptOrder.call('order-1')).called(1);
        expect(cubit.state.activeOrderId, 'order-1');
      },
    );

    test(
      'emits success and navigates to the accepted order on success',
      () async {
        when(
          () => acceptOrder.call('order-1'),
        ).thenAnswer((_) async => const Success<void>(null));
        final cubit = buildCubit();
        final events = <BaseUiEvent>[];
        final subscription = cubit.uiEventStream.listen(events.add);

        await cubit.doEvent(AcceptOrderEvent('order-1'));
        await Future<void>.delayed(Duration.zero);

        expect(
          events.whereType<ShowSuccessMessage>().single.message,
          AppSuccessEnum.orderAccepted,
        );
        final navigation = events.whereType<NavigateRepalceTo>().single;
        expect(navigation.routeName, Routes.orderDetails);
        // The card's own order id, never a shared/fallback one.
        expect(navigation.arguments, 'order-1');
        expect(events.whereType<ShowFailureMessage>(), isEmpty);
        expect(cubit.state.acceptOrderId, isEmpty);
        expect(cubit.state.activeOrderId, 'order-1');

        await subscription.cancel();
        await cubit.close();
      },
    );

    test(
      'reports an active-delivery conflict without navigating elsewhere',
      () async {
        when(() => acceptOrder.call('order-1')).thenAnswer(
          (_) async => const Error<void>(
            ConflictFailure(
              serverMessage: 'You already have an active delivery in progress.',
            ),
          ),
        );
        when(
          () => acceptOrder.getActiveOrderId(),
        ).thenAnswer((_) async => const Success<String>('active-order-9'));
        final cubit = buildCubit();
        final events = <BaseUiEvent>[];
        final subscription = cubit.uiEventStream.listen(events.add);

        await cubit.doEvent(AcceptOrderEvent('order-1'));
        await Future<void>.delayed(Duration.zero);

        expect(events.whereType<NavigateRepalceTo>(), isEmpty);
        final failure = events.whereType<ShowFailureMessage>().single;
        expect(failure.failure, isA<ConflictFailure>());
        expect(cubit.state.acceptOrderId, isEmpty);
        // The running order is remembered so its own card opens the details.
        expect(cubit.state.activeOrderId, 'active-order-9');
        verify(() => acceptOrder.getActiveOrderId()).called(1);

        await subscription.cancel();
        await cubit.close();
      },
    );

    test(
      'opens the driver\'s own running order instead of accepting it again',
      () async {
        final cubit = buildCubit();
        cubit.emit(const HomeState(activeOrderId: 'order-1'));
        final events = <BaseUiEvent>[];
        final subscription = cubit.uiEventStream.listen(events.add);

        await cubit.doEvent(AcceptOrderEvent('order-1'));
        await Future<void>.delayed(Duration.zero);

        final navigation = events.whereType<NavigateTo>().single;
        expect(navigation.routeName, Routes.orderDetails);
        expect(navigation.arguments, 'order-1');
        expect(events.whereType<NavigateRepalceTo>(), isEmpty);
        expect(events.whereType<ShowFailureMessage>(), isEmpty);
        expect(cubit.state.acceptOrderId, isEmpty);
        verifyNever(() => acceptOrder.call(any()));

        await subscription.cancel();
        await cubit.close();
      },
    );

    test(
      'refuses another order while one of the driver\'s is running',
      () async {
        final cubit = buildCubit();
        cubit.emit(const HomeState(activeOrderId: 'active-order-9'));
        final events = <BaseUiEvent>[];
        final subscription = cubit.uiEventStream.listen(events.add);

        await cubit.doEvent(AcceptOrderEvent('order-1'));
        await Future<void>.delayed(Duration.zero);

        final failure = events.whereType<ShowFailureMessage>().single;
        expect(failure.failure, isA<AlreadyActiveOrderFailure>());
        expect(events.whereType<NavigateTo>(), isEmpty);
        expect(events.whereType<NavigateRepalceTo>(), isEmpty);
        expect(cubit.state.acceptOrderId, isEmpty);
        expect(cubit.state.activeOrderId, 'active-order-9');
        verifyNever(() => acceptOrder.call(any()));
        verifyNever(() => acceptOrder.getActiveOrderId());

        await subscription.cancel();
        await cubit.close();
      },
    );

    test('reports other failures without navigating', () async {
      when(() => acceptOrder.call('order-1')).thenAnswer(
        (_) async => const Error<void>(
          BadRequestFailure(serverMessage: 'Order is no longer available.'),
        ),
      );
      final cubit = buildCubit();
      final events = <BaseUiEvent>[];
      final subscription = cubit.uiEventStream.listen(events.add);

      await cubit.doEvent(AcceptOrderEvent('order-1'));
      await Future<void>.delayed(Duration.zero);

      expect(events.whereType<NavigateRepalceTo>(), isEmpty);
      expect(
        events.whereType<ShowFailureMessage>().single.failure,
        isA<BadRequestFailure>(),
      );
      expect(cubit.state.acceptOrderId, isEmpty);

      await subscription.cancel();
      await cubit.close();
    });

    test(
      'keeps the order in the loading set until the response arrives',
      () async {
        final completer = Completer<BaseResponse<void>>();
        when(
          () => acceptOrder.call('order-1'),
        ).thenAnswer((_) => completer.future);
        final cubit = buildCubit();

        final future = cubit.doEvent(AcceptOrderEvent('order-1'));
        expect(cubit.state.acceptOrderId, 'order-1');

        completer.complete(const Success<void>(null));
        await future;
        expect(cubit.state.acceptOrderId, isEmpty);

        await cubit.close();
      },
    );

    test(
      'does not submit another order while acceptance is in progress',
      () async {
        final completer = Completer<BaseResponse<void>>();
        when(
          () => acceptOrder.call('order-1'),
        ).thenAnswer((_) => completer.future);
        final cubit = buildCubit();

        final firstRequest = cubit.doEvent(AcceptOrderEvent('order-1'));
        await cubit.doEvent(AcceptOrderEvent('order-2'));

        verify(() => acceptOrder.call('order-1')).called(1);
        verifyNever(() => acceptOrder.call('order-2'));

        completer.complete(const Success<void>(null));
        await firstRequest;
        await cubit.close();
      },
    );

    test('rejects an empty order ID without calling the use case', () async {
      final cubit = buildCubit();
      final events = <BaseUiEvent>[];
      final subscription = cubit.uiEventStream.listen(events.add);

      await cubit.doEvent(AcceptOrderEvent('  '));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.acceptOrderId, isEmpty);
      expect(
        events.whereType<ShowFailureMessage>().single.failure,
        isA<BadRequestFailure>(),
      );
      verifyNever(() => acceptOrder.call(any()));

      await subscription.cancel();
      await cubit.close();
    });
  });

  group('OpenOrderDetailsEvent', () {
    test('opens the requested order, using its own id', () async {
      final cubit = buildCubit();
      final events = <BaseUiEvent>[];
      final subscription = cubit.uiEventStream.listen(events.add);

      await cubit.doEvent(OpenOrderDetailsEvent('order-42'));
      await Future<void>.delayed(Duration.zero);

      final navigation = events.whereType<NavigateTo>().single;
      expect(navigation.routeName, Routes.orderDetails);
      expect(navigation.arguments, 'order-42');
      expect(events.whereType<NavigateRepalceTo>(), isEmpty);
      verifyNever(() => acceptOrder.call(any()));

      await subscription.cancel();
      await cubit.close();
    });

    test('rejects an empty order ID', () async {
      final cubit = buildCubit();
      final events = <BaseUiEvent>[];
      final subscription = cubit.uiEventStream.listen(events.add);

      await cubit.doEvent(OpenOrderDetailsEvent('  '));
      await Future<void>.delayed(Duration.zero);

      expect(events.whereType<NavigateTo>(), isEmpty);
      expect(
        events.whereType<ShowFailureMessage>().single.failure,
        isA<BadRequestFailure>(),
      );

      await subscription.cancel();
      await cubit.close();
    });
  });

  group('LoadMoreOrdersEvent', () {
    blocTest<HomeCubit, HomeState>(
      'does nothing when there is no loaded data yet',
      build: buildCubit,
      act: (cubit) => cubit.doEvent(LoadMoreOrdersEvent()),
      expect: () => <HomeState>[],
      verify: (_) =>
          verifyNever(() => getOrders.call(page: any(named: 'page'))),
    );

    blocTest<HomeCubit, HomeState>(
      'does nothing when the last page has no next page',
      build: buildCubit,
      seed: () => HomeState(
        getAvailableOrdersState: BaseState(
          data: buildAvailableOrders(
            pagination: buildPagination(hasNextPage: false),
          ),
        ),
      ),
      act: (cubit) => cubit.doEvent(LoadMoreOrdersEvent()),
      expect: () => <HomeState>[],
      verify: (_) =>
          verifyNever(() => getOrders.call(page: any(named: 'page'))),
    );

    blocTest<HomeCubit, HomeState>(
      'does nothing when a load more request is already in flight',
      build: buildCubit,
      seed: () => HomeState(
        isLoadingMore: true,
        getAvailableOrdersState: BaseState(
          data: buildAvailableOrders(
            pagination: buildPagination(hasNextPage: true),
          ),
        ),
      ),
      act: (cubit) => cubit.doEvent(LoadMoreOrdersEvent()),
      expect: () => <HomeState>[],
      verify: (_) =>
          verifyNever(() => getOrders.call(page: any(named: 'page'))),
    );

    blocTest<HomeCubit, HomeState>(
      'appends the next page to the existing items',
      build: () {
        when(() => getOrders.call(page: 2)).thenAnswer(
          (_) async => Success<AvailableOrders>(
            buildAvailableOrders(
              items: [buildOrder(orderId: 'order-2')],
              pagination: buildPagination(page: 2, hasNextPage: false),
            ),
          ),
        );
        return buildCubit();
      },
      seed: () => HomeState(
        getAvailableOrdersState: BaseState(
          data: buildAvailableOrders(
            items: [buildOrder(orderId: 'order-1')],
            pagination: buildPagination(page: 1, hasNextPage: true),
          ),
        ),
      ),
      act: (cubit) => cubit.doEvent(LoadMoreOrdersEvent()),
      expect: () => [
        isA<HomeState>().having(
          (state) => state.isLoadingMore,
          'isLoadingMore',
          isTrue,
        ),
        isA<HomeState>()
            .having((state) => state.isLoadingMore, 'isLoadingMore', isFalse)
            .having(
              (state) => state.getAvailableOrdersState.data?.items,
              'items',
              hasLength(2),
            )
            .having(
              (state) => state.getAvailableOrdersState.data?.items.last.orderId,
              'last item',
              'order-2',
            )
            .having(
              (state) => state.getAvailableOrdersState.data?.pagination.page,
              'page',
              2,
            ),
      ],
      verify: (_) => verify(() => getOrders.call(page: 2)).called(1),
    );

    blocTest<HomeCubit, HomeState>(
      'stops loading and emits a failure event when loading more fails',
      build: () {
        when(() => getOrders.call(page: 2)).thenAnswer(
          (_) async => const Error<AvailableOrders>(ServerFailure()),
        );
        return buildCubit();
      },
      seed: () => HomeState(
        getAvailableOrdersState: BaseState(
          data: buildAvailableOrders(
            items: [buildOrder(orderId: 'order-1')],
            pagination: buildPagination(page: 1, hasNextPage: true),
          ),
        ),
      ),
      act: (cubit) => cubit.doEvent(LoadMoreOrdersEvent()),
      expect: () => [
        isA<HomeState>().having(
          (state) => state.isLoadingMore,
          'isLoadingMore',
          isTrue,
        ),
        isA<HomeState>()
            .having((state) => state.isLoadingMore, 'isLoadingMore', isFalse)
            .having(
              (state) => state.getAvailableOrdersState.data?.items,
              'items',
              hasLength(1),
            ),
      ],
      verify: (_) => verify(() => getOrders.call(page: 2)).called(1),
    );

    test('emits a failure UI event when loading more fails', () async {
      when(
        () => getOrders.call(page: 2),
      ).thenAnswer((_) async => const Error<AvailableOrders>(ServerFailure()));
      final cubit = buildCubit();
      cubit.emit(
        HomeState(
          getAvailableOrdersState: BaseState(
            data: buildAvailableOrders(
              pagination: buildPagination(page: 1, hasNextPage: true),
            ),
          ),
        ),
      );
      final events = <BaseUiEvent>[];
      final subscription = cubit.uiEventStream.listen(events.add);

      await cubit.doEvent(LoadMoreOrdersEvent());
      await Future<void>.delayed(Duration.zero);

      expect(
        events.whereType<ShowFailureMessage>().single.failure,
        isA<ServerFailure>(),
      );
      expect(cubit.state.isLoadingMore, isFalse);

      await subscription.cancel();
      await cubit.close();
    });
  });
}
