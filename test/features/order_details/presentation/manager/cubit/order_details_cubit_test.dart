import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_location.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/order_status.dart';
import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:driver_app/features/order_details/domain/params/update_order_status_params.dart';
import 'package:driver_app/features/order_details/domain/usecases/get_driver_order_details_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/report_driver_location_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/update_order_status_use_case.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_cubit.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_event.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_state.dart';
import 'package:driver_app/features/order_details/presentation/utils/location_reporting_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/fixtures.dart';

class MockGetDriverOrderDetailsUseCase extends Mock
    implements GetDriverOrderDetailsUseCase {}

class MockUpdateOrderStatusUseCase extends Mock
    implements UpdateOrderStatusUseCase {}

class MockReportDriverLocationUseCase extends Mock
    implements ReportDriverLocationUseCase {}

class MockStreamSubscription extends Mock
    implements StreamSubscription<BaseResponse<DriverLocation>> {}

void main() {
  late MockGetDriverOrderDetailsUseCase getOrderDetails;
  late MockUpdateOrderStatusUseCase updateOrderStatus;
  late MockReportDriverLocationUseCase reportDriverLocation;
  late OrderDetailsCubit cubit;

  setUpAll(() {
    registerFallbackValue(
      const UpdateOrderStatusParams(orderId: '', newStatus: ''),
    );
  });

  setUp(() {
    getOrderDetails = MockGetDriverOrderDetailsUseCase();
    updateOrderStatus = MockUpdateOrderStatusUseCase();
    reportDriverLocation = MockReportDriverLocationUseCase();

    when(
      () => reportDriverLocation.start(
        onReportResult: any(named: 'onReportResult'),
        onLocationError: any(named: 'onLocationError'),
        minDisplacementMeters: any(named: 'minDisplacementMeters'),
      ),
    ).thenAnswer((_) {
      final sub = MockStreamSubscription();
      when(() => sub.cancel()).thenAnswer((_) async {});
      return sub;
    });

    cubit = OrderDetailsCubit(
      getDriverOrderDetailsUseCase: getOrderDetails,
      updateOrderStatusUseCase: updateOrderStatus,
      reportDriverLocationUseCase: reportDriverLocation,
    );
  });

  tearDown(() => cubit.close());

  Future<List<BaseUiEvent>> collectEvents(
    Future<void> Function() trigger,
  ) async {
    final events = <BaseUiEvent>[];
    final subscription = cubit.uiEventStream.listen(events.add);
    await trigger();
    await pumpEventQueue();
    await subscription.cancel();
    return events;
  }

  group('initial state', () {
    test('starts with empty slices and inactive tracking', () {
      expect(cubit.state, const OrderDetailsState());
      expect(cubit.state.orderDetails.data, isNull);
      expect(cubit.state.updateOrderStatus.data, isNull);
      expect(cubit.state.reportDriverLocation.data, isNull);
      expect(
        cubit.state.locationReportingStatus,
        LocationReportingStatus.inactive,
      );
    });
  });

  group('GetDriverOrderDetailsEvent', () {
    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'emits loading then success state and starts tracking for in-transit order',
      build: () {
        when(() => getOrderDetails.execute(any())).thenAnswer(
          (_) async => Success(
            buildDriverOrderDetailsEntity(status: OrderStatus.pickedUp),
          ),
        );
        return cubit;
      },
      act: (c) =>
          c.doEvent(const GetDriverOrderDetailsEvent(orderId: kOrderId)),
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
        isA<OrderDetailsState>()
            .having(
              (s) => s.locationReportingStatus,
              'locationReportingStatus',
              LocationReportingStatus.active,
            )
            .having(
              (s) => s.reportDriverLocation.isLoading,
              'reportDriverLocation.isLoading',
              isTrue,
            ),
      ],
      verify: (_) {
        verify(
          () => reportDriverLocation.start(
            onReportResult: any(named: 'onReportResult'),
            onLocationError: any(named: 'onLocationError'),
            minDisplacementMeters: any(named: 'minDisplacementMeters'),
          ),
        ).called(1);
      },
    );

    test('does not start location reporting for pending orders', () async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async =>
            Success(buildDriverOrderDetailsEntity(status: OrderStatus.pending)),
      );

      await cubit.doEvent(const GetDriverOrderDetailsEvent(orderId: kOrderId));

      expect(
        cubit.state.locationReportingStatus,
        LocationReportingStatus.inactive,
      );
      verifyNever(
        () => reportDriverLocation.start(
          onReportResult: any(named: 'onReportResult'),
          onLocationError: any(named: 'onLocationError'),
        ),
      );
    });

    test('emits failure ui event and stores the failure', () async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Error<DriverOrderDetailsEntity>(const NotFoundFailure()),
      );

      final events = await collectEvents(
        () =>
            cubit.doEvent(const GetDriverOrderDetailsEvent(orderId: kOrderId)),
      );

      expect(events, hasLength(1));
      expect(
        events.single,
        isA<ShowOrderDetailsFailure>().having(
          (e) => e.failure,
          'failure',
          isA<NotFoundFailure>(),
        ),
      );
      expect(cubit.state.orderDetails.failure, isA<NotFoundFailure>());
      expect(cubit.state.orderDetails.isLoading, isFalse);
    });
  });

  group('UpdateOrderStatusEvent', () {
    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'emits loading then success state and starts tracking on on_the_way',
      build: () {
        when(
          () => updateOrderStatus.execute(any()),
        ).thenAnswer((_) async => Success(buildUpdateOrderStatusEntity()));
        return cubit;
      },
      act: (c) => c.doEvent(
        const UpdateOrderStatusEvent(
          orderId: kOrderId,
          newStatus: 'on_the_way',
        ),
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
        isA<OrderDetailsState>()
            .having(
              (s) => s.locationReportingStatus,
              'locationReportingStatus',
              LocationReportingStatus.active,
            )
            .having(
              (s) => s.reportDriverLocation.isLoading,
              'reportDriverLocation.isLoading',
              isTrue,
            ),
      ],
    );

    test(
      'stops location reporting when updating to terminal status (arrived)',
      () async {
        when(
          () => updateOrderStatus.execute(any()),
        ).thenAnswer((_) async => Success(buildUpdateOrderStatusEntity()));

        await cubit.doEvent(const StartLocationReportingEvent());
        expect(
          cubit.state.locationReportingStatus,
          LocationReportingStatus.active,
        );

        await cubit.doEvent(
          const UpdateOrderStatusEvent(orderId: kOrderId, newStatus: 'arrived'),
        );

        expect(
          cubit.state.locationReportingStatus,
          LocationReportingStatus.inactive,
        );
      },
    );

    test('emits ShowOrderDetailsFailure on update error', () async {
      when(() => updateOrderStatus.execute(any())).thenAnswer(
        (_) async => Error<UpdateOrderStatusEntity>(
          const ConflictFailure(serverMessage: 'busy'),
        ),
      );

      final events = await collectEvents(
        () => cubit.doEvent(
          const UpdateOrderStatusEvent(
            orderId: kOrderId,
            newStatus: 'accepted',
          ),
        ),
      );

      expect(events, hasLength(1));
      expect(
        events.single,
        isA<ShowOrderDetailsFailure>().having(
          (e) => e.failure,
          'failure',
          isA<ConflictFailure>(),
        ),
      );
      expect(cubit.state.updateOrderStatus.failure, isA<ConflictFailure>());
    });
  });

  group('StartLocationReportingEvent & StopLocationReportingEvent', () {
    test(
      'StartLocationReportingEvent begins tracking and handles successful reports',
      () async {
        void Function(BaseResponse<ReportDriverLocationEntity>, DriverLocation)?
        capturedCallback;

        when(
          () => reportDriverLocation.start(
            onReportResult: any(named: 'onReportResult'),
            onLocationError: any(named: 'onLocationError'),
            minDisplacementMeters: any(named: 'minDisplacementMeters'),
          ),
        ).thenAnswer((invocation) {
          capturedCallback =
              invocation.namedArguments[#onReportResult]
                  as void Function(
                    BaseResponse<ReportDriverLocationEntity>,
                    DriverLocation,
                  );
          final sub = MockStreamSubscription();
          when(() => sub.cancel()).thenAnswer((_) async {});
          return sub;
        });

        await cubit.doEvent(const StartLocationReportingEvent());

        expect(
          cubit.state.locationReportingStatus,
          LocationReportingStatus.active,
        );
        expect(cubit.state.reportDriverLocation.isLoading, isTrue);
        expect(capturedCallback, isNotNull);

        // Trigger a report success
        final locationEntity = buildReportDriverLocationEntity();
        const reportedLocation = DriverLocation(
          latitude: 30.0444,
          longitude: 31.2357,
        );
        capturedCallback!(Success(locationEntity), reportedLocation);

        expect(cubit.state.reportDriverLocation.isLoading, isFalse);
        expect(cubit.state.reportDriverLocation.data, locationEntity);
        expect(cubit.state.driverLocation, reportedLocation);
      },
    );

    test('StartLocationReportingEvent handles report errors', () async {
      void Function(BaseResponse<ReportDriverLocationEntity>, DriverLocation)?
      capturedCallback;

      when(
        () => reportDriverLocation.start(
          onReportResult: any(named: 'onReportResult'),
          onLocationError: any(named: 'onLocationError'),
          minDisplacementMeters: any(named: 'minDisplacementMeters'),
        ),
      ).thenAnswer((invocation) {
        capturedCallback =
            invocation.namedArguments[#onReportResult]
                as void Function(
                  BaseResponse<ReportDriverLocationEntity>,
                  DriverLocation,
                );
        final sub = MockStreamSubscription();
        when(() => sub.cancel()).thenAnswer((_) async {});
        return sub;
      });

      final events = <BaseUiEvent>[];
      final subscription = cubit.uiEventStream.listen(events.add);

      await cubit.doEvent(const StartLocationReportingEvent());

      capturedCallback!(
        const Error<ReportDriverLocationEntity>(InternetConnectionFailure()),
        const DriverLocation(latitude: 30.0444, longitude: 31.2357),
      );
      await pumpEventQueue();

      expect(cubit.state.reportDriverLocation.isLoading, isFalse);
      expect(
        cubit.state.reportDriverLocation.failure,
        isA<InternetConnectionFailure>(),
      );
      expect(
        cubit.state.locationReportingStatus,
        LocationReportingStatus.active,
      );
      expect(events, isEmpty);

      await subscription.cancel();
    });

    test(
      'StartLocationReportingEvent handles location stream errors',
      () async {
        void Function(AppFailure)? capturedLocationError;

        when(
          () => reportDriverLocation.start(
            onReportResult: any(named: 'onReportResult'),
            onLocationError: any(named: 'onLocationError'),
            minDisplacementMeters: any(named: 'minDisplacementMeters'),
          ),
        ).thenAnswer((invocation) {
          capturedLocationError =
              invocation.namedArguments[#onLocationError]
                  as void Function(AppFailure);
          final sub = MockStreamSubscription();
          when(() => sub.cancel()).thenAnswer((_) async {});
          return sub;
        });

        await cubit.doEvent(const StartLocationReportingEvent());
        expect(
          cubit.state.locationReportingStatus,
          LocationReportingStatus.active,
        );

        capturedLocationError!(const UnknownFailure());
        await pumpEventQueue();

        expect(cubit.state.reportDriverLocation.isLoading, isFalse);
        expect(cubit.state.reportDriverLocation.failure, isA<UnknownFailure>());
        expect(
          cubit.state.locationReportingStatus,
          LocationReportingStatus.error,
        );
      },
    );

    test(
      'StopLocationReportingEvent cancels subscription and sets active to false',
      () async {
        final mockSub = MockStreamSubscription();
        when(() => mockSub.cancel()).thenAnswer((_) async {});

        when(
          () => reportDriverLocation.start(
            onReportResult: any(named: 'onReportResult'),
            onLocationError: any(named: 'onLocationError'),
            minDisplacementMeters: any(named: 'minDisplacementMeters'),
          ),
        ).thenReturn(mockSub);

        await cubit.doEvent(const StartLocationReportingEvent());
        expect(
          cubit.state.locationReportingStatus,
          LocationReportingStatus.active,
        );

        await cubit.doEvent(const StopLocationReportingEvent());
        expect(
          cubit.state.locationReportingStatus,
          LocationReportingStatus.inactive,
        );
        verify(() => mockSub.cancel()).called(1);
      },
    );

    test('close cancels active subscription', () async {
      final mockSub = MockStreamSubscription();
      when(() => mockSub.cancel()).thenAnswer((_) async {});

      when(
        () => reportDriverLocation.start(
          onReportResult: any(named: 'onReportResult'),
          onLocationError: any(named: 'onLocationError'),
          minDisplacementMeters: any(named: 'minDisplacementMeters'),
        ),
      ).thenReturn(mockSub);

      await cubit.doEvent(const StartLocationReportingEvent());
      await cubit.close();

      verify(() => mockSub.cancel()).called(1);
    });
  });
}
