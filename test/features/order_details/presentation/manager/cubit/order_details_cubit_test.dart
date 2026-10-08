import 'package:bloc_test/bloc_test.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:driver_app/features/order_details/domain/params/report_driver_location_params.dart';
import 'package:driver_app/features/order_details/domain/params/update_order_status_params.dart';
import 'package:driver_app/features/order_details/domain/usecases/get_driver_order_details_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/report_driver_location_use_case.dart';
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

class MockReportDriverLocationUseCase extends Mock
    implements ReportDriverLocationUseCase {}

void main() {
  late MockGetDriverOrderDetailsUseCase getOrderDetails;
  late MockUpdateOrderStatusUseCase updateOrderStatus;
  late MockReportDriverLocationUseCase reportDriverLocation;
  late OrderDetailsCubit cubit;

  setUpAll(() {
    registerFallbackValue(
      const UpdateOrderStatusParams(orderId: '', newStatus: ''),
    );
    registerFallbackValue(
      const ReportDriverLocationParams(lat: 0, lng: 0, recordedAt: ''),
    );
  });

  setUp(() {
    getOrderDetails = MockGetDriverOrderDetailsUseCase();
    updateOrderStatus = MockUpdateOrderStatusUseCase();
    reportDriverLocation = MockReportDriverLocationUseCase();
    cubit = OrderDetailsCubit(
      getDriverOrderDetailsUseCase: getOrderDetails,
      updateOrderStatusUseCase: updateOrderStatus,
      reportDriverLocationUseCase: reportDriverLocation,
    );
  });

  tearDown(() => cubit.close());

  Future<List<BaseUiEvent>> collectEvents(void Function() trigger) async {
    final events = <BaseUiEvent>[];
    final subscription = cubit.uiEventStream.listen(events.add);
    trigger();
    await pumpEventQueue();
    await subscription.cancel();
    return events;
  }

  group('initial state', () {
    test('every slice starts idle and empty', () {
      expect(cubit.state, const OrderDetailsState());
      expect(cubit.state.orderDetails.data, isNull);
      expect(cubit.state.updateOrderStatus.data, isNull);
      expect(cubit.state.reportDriverLocation.data, isNull);
    });
  });

  group('GetDriverOrderDetailsEvent', () {
    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'marks the orderDetails slice loading then stores the entity',
      build: () {
        when(() => getOrderDetails.execute(any())).thenAnswer(
          (_) async => Success(buildDriverOrderDetailsEntity()),
        );
        return cubit;
      },
      act: (c) => c.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId)),
      expect: () => [
        isA<OrderDetailsState>()
            .having((s) => s.orderDetails.isLoading, 'isLoading', isTrue)
            .having((s) => s.orderDetails.data, 'data', isNull),
        isA<OrderDetailsState>()
            .having((s) => s.orderDetails.isLoading, 'isLoading', isFalse)
            .having((s) => s.orderDetails.errorMessage, 'errorMessage', '')
            .having((s) => s.orderDetails.data, 'data', isNotNull),
      ],
      verify: (_) {
        expect(
          cubit.state.orderDetails.data,
          isA<DriverOrderDetailsEntity>()
              .having((e) => e.orderId, 'orderId', kOrderId)
              .having((e) => e.status, 'status', 'PickedUp'),
        );
      },
    );

    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'clears loading without storing data on failure',
      build: () {
        when(() => getOrderDetails.execute(any())).thenAnswer(
          (_) async => Error<DriverOrderDetailsEntity>(const NotFoundFailure()),
        );
        return cubit;
      },
      act: (c) => c.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId)),
      expect: () => [
        isA<OrderDetailsState>()
            .having((s) => s.orderDetails.isLoading, 'isLoading', isTrue),
        isA<OrderDetailsState>()
            .having((s) => s.orderDetails.isLoading, 'isLoading', isFalse)
            .having((s) => s.orderDetails.data, 'data', isNull),
      ],
    );

    test('publishes the failure on the ui event stream', () async {
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
    });

    test('publishes no ui event on success', () async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity()),
      );

      final events = await collectEvents(
        () => cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId)),
      );

      expect(events, isEmpty);
    });

    test('forwards the orderId to the use case', () async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity()),
      );

      cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));
      await pumpEventQueue();

      verify(() => getOrderDetails.execute(kOrderId)).called(1);
    });

    test('does not touch the other slices', () async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity()),
      );

      cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));
      await pumpEventQueue();

      expect(cubit.state.updateOrderStatus.isLoading, isFalse);
      expect(cubit.state.updateOrderStatus.data, isNull);
      expect(cubit.state.reportDriverLocation.isLoading, isFalse);
      expect(cubit.state.reportDriverLocation.data, isNull);
    });
  });

  group('UpdateOrderStatusEvent', () {
    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'marks the updateOrderStatus slice loading then stores the result',
      build: () {
        when(() => updateOrderStatus.execute(any())).thenAnswer(
          (_) async => Success(buildUpdateOrderStatusEntity()),
        );
        return cubit;
      },
      act: (c) => c.doEvent(
        UpdateOrderStatusEvent(orderId: kOrderId, newStatus: 'PickedUp'),
      ),
      expect: () => [
        isA<OrderDetailsState>()
            .having(
              (s) => s.updateOrderStatus.isLoading,
              'isLoading',
              isTrue,
            )
            .having((s) => s.updateOrderStatus.data, 'data', isNull),
        isA<OrderDetailsState>()
            .having(
              (s) => s.updateOrderStatus.isLoading,
              'isLoading',
              isFalse,
            )
            .having((s) => s.updateOrderStatus.data, 'data', isNotNull),
      ],
      verify: (_) {
        expect(cubit.state.updateOrderStatus.data, isNotNull);
      },
    );

    test('publishes ShowOrderStatusUpdated on success', () async {
      when(() => updateOrderStatus.execute(any())).thenAnswer(
        (_) async => Success(buildUpdateOrderStatusEntity()),
      );

      final events = await collectEvents(
        () => cubit.doEvent(
          UpdateOrderStatusEvent(orderId: kOrderId, newStatus: 'PickedUp'),
        ),
      );

      expect(events, hasLength(1));
      expect(events.single, isA<ShowOrderStatusUpdated>());
    });

    test('publishes ShowFailureMessage on failure', () async {
      when(() => updateOrderStatus.execute(any())).thenAnswer(
        (_) async => Error<UpdateOrderStatusEntity>(
          const ConflictFailure(serverMessage: 'busy'),
        ),
      );

      final events = await collectEvents(
        () => cubit.doEvent(
          UpdateOrderStatusEvent(orderId: kOrderId, newStatus: 'PickedUp'),
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
      expect(cubit.state.updateOrderStatus.data, isNull);
    });

    test('passes orderId and newStatus through to the use case', () async {
      when(() => updateOrderStatus.execute(any())).thenAnswer(
        (_) async => Success(buildUpdateOrderStatusEntity()),
      );

      cubit.doEvent(
        UpdateOrderStatusEvent(orderId: kOrderId, newStatus: 'OutForDelivery'),
      );
      await pumpEventQueue();

      final captured =
          verify(() => updateOrderStatus.execute(captureAny()))
              .captured
              .single
              as UpdateOrderStatusParams;
      expect(captured.orderId, kOrderId);
      expect(captured.newStatus, 'OutForDelivery');
    });

    test('does not call the other use cases', () async {
      when(() => updateOrderStatus.execute(any())).thenAnswer(
        (_) async => Success(buildUpdateOrderStatusEntity()),
      );

      cubit.doEvent(
        UpdateOrderStatusEvent(orderId: kOrderId, newStatus: 'PickedUp'),
      );
      await pumpEventQueue();

      verifyNever(() => getOrderDetails.execute(any()));
      verifyNever(() => reportDriverLocation.execute(any()));
    });
  });

  group('ReportDriverLocationEvent', () {
    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'marks the reportDriverLocation slice loading then stores the result',
      build: () {
        when(() => reportDriverLocation.execute(any())).thenAnswer(
          (_) async => Success(buildReportDriverLocationEntity()),
        );
        return cubit;
      },
      act: (c) => c.doEvent(
        ReportDriverLocationEvent(lat: 30.0444, lng: 31.2357, recordedAt: 'ts'),
      ),
      expect: () => [
        isA<OrderDetailsState>()
            .having(
              (s) => s.reportDriverLocation.isLoading,
              'isLoading',
              isTrue,
            )
            .having((s) => s.reportDriverLocation.data, 'data', isNull),
        isA<OrderDetailsState>()
            .having(
              (s) => s.reportDriverLocation.isLoading,
              'isLoading',
              isFalse,
            )
            .having((s) => s.reportDriverLocation.data, 'data', isNotNull),
      ],
    );

    test('publishes ShowFailureMessage on failure', () async {
      when(() => reportDriverLocation.execute(any())).thenAnswer(
        (_) async => Error<ReportDriverLocationEntity>(
          const InternetConnectionFailure(),
        ),
      );

      final events = await collectEvents(
        () => cubit.doEvent(
          ReportDriverLocationEvent(lat: 1, lng: 2, recordedAt: 'ts'),
        ),
      );

      expect(events, hasLength(1));
      expect(
        events.single,
        isA<ShowFailureMessage>().having(
          (e) => e.failure,
          'failure',
          isA<InternetConnectionFailure>(),
        ),
      );
      expect(cubit.state.reportDriverLocation.data, isNull);
    });

    test('builds the params with lat, lng and recordedAt', () async {
      when(() => reportDriverLocation.execute(any())).thenAnswer(
        (_) async => Success(buildReportDriverLocationEntity()),
      );

      cubit.doEvent(
        ReportDriverLocationEvent(
          lat: 30.0444,
          lng: 31.2357,
          recordedAt: '2026-09-19T18:00:00Z',
        ),
      );
      await pumpEventQueue();

      final captured =
          verify(() => reportDriverLocation.execute(captureAny()))
              .captured
              .single
              as ReportDriverLocationParams;
      expect(captured.lat, 30.0444);
      expect(captured.lng, 31.2357);
      expect(captured.recordedAt, '2026-09-19T18:00:00Z');
    });

    test('does not touch the other slices', () async {
      when(() => reportDriverLocation.execute(any())).thenAnswer(
        (_) async => Success(buildReportDriverLocationEntity()),
      );

      cubit.doEvent(
        ReportDriverLocationEvent(lat: 1, lng: 2, recordedAt: 'ts'),
      );
      await pumpEventQueue();

      expect(cubit.state.orderDetails.isLoading, isFalse);
      expect(cubit.state.orderDetails.data, isNull);
      expect(cubit.state.updateOrderStatus.isLoading, isFalse);
      expect(cubit.state.updateOrderStatus.data, isNull);
    });
  });
}
