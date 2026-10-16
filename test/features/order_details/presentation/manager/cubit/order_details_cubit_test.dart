import 'package:bloc_test/bloc_test.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/order_status.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:driver_app/features/order_details/domain/params/update_order_status_params.dart';
import 'package:driver_app/features/order_details/domain/usecases/get_driver_order_details_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/update_order_status_use_case.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_cubit.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_event.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/fixtures.dart';

class MockGetDriverOrderDetailsUseCase extends Mock
    implements GetDriverOrderDetailsUseCase {}

class MockUpdateOrderStatusUseCase extends Mock
    implements UpdateOrderStatusUseCase {}

void main() {
  late MockGetDriverOrderDetailsUseCase getOrderDetails;
  late MockUpdateOrderStatusUseCase updateOrderStatus;
  late OrderDetailsCubit cubit;

  setUpAll(() {
    registerFallbackValue(
      const UpdateOrderStatusParams(orderId: '', newStatus: ''),
    );
  });

  setUp(() {
    getOrderDetails = MockGetDriverOrderDetailsUseCase();
    updateOrderStatus = MockUpdateOrderStatusUseCase();
    cubit = OrderDetailsCubit(
      getDriverOrderDetailsUseCase: getOrderDetails,
      updateOrderStatusUseCase: updateOrderStatus,
    );
  });

  tearDown(() => cubit.close());

  Future<List<BaseUiEvent>> collectEvents(Future<void> Function() trigger) async {
    final events = <BaseUiEvent>[];
    final subscription = cubit.uiEventStream.listen(events.add);
    await trigger();
    await pumpEventQueue();
    await subscription.cancel();
    return events;
  }

  group('initial state', () {
    test('starts with empty slices', () {
      expect(cubit.state, const OrderDetailsState());
      expect(cubit.state.orderDetails.data, isNull);
      expect(cubit.state.updateOrderStatus.data, isNull);
    });
  });

  group('GetDriverOrderDetailsEvent', () {
    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'emits loading then success state',
      build: () {
        when(() => getOrderDetails.execute(any())).thenAnswer(
          (_) async => Success(buildDriverOrderDetailsEntity()),
        );
        return cubit;
      },
      act: (c) => c.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId)),
      expect: () => [
        isA<OrderDetailsState>().having(
          (s) => s.orderDetails.isLoading,
          'isLoading',
          isTrue,
        ),
        isA<OrderDetailsState>()
            .having((s) => s.orderDetails.isLoading, 'isLoading', isFalse)
            .having((s) => s.orderDetails.failure, 'failure', isNull)
            .having((s) => s.orderDetails.data, 'data', isNotNull),
      ],
      verify: (_) {
        final data = cubit.state.orderDetails.data;
        expect(data, isA<DriverOrderDetailsEntity>());
        expect(data?.orderId, kOrderId);
        expect(data?.status, OrderStatus.pickedUp);
      },
    );

    test('emits failure ui event and stores the failure', () async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Error<DriverOrderDetailsEntity>(const NotFoundFailure()),
      );

      final events = await collectEvents(
        () => cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId)),
      );

      expect(events, hasLength(1));
      expect(
        events.single,
        isA<ShowFailureMessage>().having(
          (e) => e.failure,
          'failure',
          isA<NotFoundFailure>(),
        ),
      );
      expect(cubit.state.orderDetails.errorMessage, isA<NotFoundFailure>());
      expect(cubit.state.orderDetails.isLoading, isFalse);
    });

    test('passes the orderId to the use case', () async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity()),
      );

      await cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));

      verify(() => getOrderDetails.execute(kOrderId)).called(1);
    });
  });

  group('UpdateOrderStatusEvent', () {
    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'emits loading then success state and success event',
      build: () {
        when(() => updateOrderStatus.execute(any())).thenAnswer(
          (_) async => Success(buildUpdateOrderStatusEntity()),
        );
        return cubit;
      },
      act: (c) => c.doEvent(
        UpdateOrderStatusEvent(orderId: kOrderId, newStatus: 'accepted'),
      ),
      expect: () => [
        isA<OrderDetailsState>().having(
          (s) => s.updateOrderStatus.isLoading,
          'isLoading',
          isTrue,
        ),
        isA<OrderDetailsState>()
            .having((s) => s.updateOrderStatus.isLoading, 'isLoading', isFalse)
            .having((s) => s.updateOrderStatus.data, 'data', isNotNull),
      ],
    );

    test('emits ShowOrderStatusUpdated on success', () async {
      when(() => updateOrderStatus.execute(any())).thenAnswer(
        (_) async => Success(buildUpdateOrderStatusEntity()),
      );

      final events = await collectEvents(
        () => cubit.doEvent(
          UpdateOrderStatusEvent(orderId: kOrderId, newStatus: 'accepted'),
        ),
      );

      expect(events, hasLength(1));
      expect(events.single, isA<ShowSuccessMessage>());
    });

    test('emits ShowOrderDetailsFailure on error', () async {
      when(() => updateOrderStatus.execute(any())).thenAnswer(
        (_) async => Error<UpdateOrderStatusEntity>(
          const ConflictFailure(serverMessage: 'busy'),
        ),
      );

      final events = await collectEvents(
        () => cubit.doEvent(
          UpdateOrderStatusEvent(orderId: kOrderId, newStatus: 'accepted'),
        ),
      );

      expect(events, hasLength(1));
      expect(
        events.single,
        isA<ShowFailureMessage>().having(
          (e) => e.failure,
          'failure',
          isA<ConflictFailure>(),
        ),
      );
      expect(cubit.state.updateOrderStatus.errorMessage, isA<ConflictFailure>());
    });

    test('passes orderId and newStatus to the use case', () async {
      when(() => updateOrderStatus.execute(any())).thenAnswer(
        (_) async => Success(buildUpdateOrderStatusEntity()),
      );

      await cubit.doEvent(
        UpdateOrderStatusEvent(orderId: kOrderId, newStatus: 'on_the_way'),
      );

      final captured =
          verify(() => updateOrderStatus.execute(captureAny()))
              .captured
              .single
              as UpdateOrderStatusParams;

      expect(captured.orderId, kOrderId);
      expect(captured.newStatus, 'on_the_way');
    });
  });
}
