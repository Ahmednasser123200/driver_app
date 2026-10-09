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
  });

  test('initial state defaults to an empty, non-loading state', () {
    final cubit = buildCubit();

    expect(cubit.state, const HomeState());
    expect(cubit.state.getAvailableOrdersState.isLoading, isFalse);
    expect(cubit.state.getAvailableOrdersState.data, isNull);
    expect(cubit.state.acceptOrderId, isEmpty);
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
      ],
      verify: (_) => verify(() => getOrders.call(page: 1)).called(1),
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
  });

  group('AcceptOrderEvent', () {
    blocTest<HomeCubit, HomeState>(
      'marks the order as loading then clears it on success',
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
          {'order-1'},
        ),
        isA<HomeState>().having(
          (state) => state.acceptOrderId,
          'acceptOrderId',
          isEmpty,
        ),
      ],
      verify: (_) => verify(() => acceptOrder.call('order-1')).called(1),
    );

    test('emits success and navigation UI events on success', () async {
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
        AppMessage.orderAccepted,
      );
      final navigation = events.whereType<NavigateTo>().single;
      expect(navigation.routeName, Routes.orderDetails);
      expect(navigation.arguments, {'orderId': 'order-1'});
      expect(events.whereType<ShowFailureMessage>(), isEmpty);

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
        expect(cubit.state.acceptOrderId, {'order-1'});

        completer.complete(const Success<void>(null));
        await future;
        expect(cubit.state.acceptOrderId, isEmpty);

        await cubit.close();
      },
    );

    test('emits a failure UI event and clears the order on error', () async {
      when(
        () => acceptOrder.call('order-1'),
      ).thenAnswer((_) async => const Error<void>(ConflictFailure()));
      final cubit = buildCubit();
      final events = <BaseUiEvent>[];
      final subscription = cubit.uiEventStream.listen(events.add);

      await cubit.doEvent(AcceptOrderEvent('order-1'));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.acceptOrderId, isEmpty);
      final failure = events.whereType<ShowFailureMessage>().single;
      expect(failure.failure, isA<ConflictFailure>());
      expect(events.whereType<ShowSuccessMessage>(), isEmpty);
      expect(events.whereType<NavigateTo>(), isEmpty);

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
