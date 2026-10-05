import 'package:bloc_test/bloc_test.dart';
import 'package:driver_app/config/base/base_response.dart';
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
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
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
  late AppLocalizations l10n;
  late OrderDetailsCubit cubit;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
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
      l10n: l10n,
    );
  });

  tearDown(() => cubit.close());

  group('GetDriverOrderDetailsEvent', () {
    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'emits loading then the mapped entity on success',
      build: () {
        final entity = buildDriverOrderDetailsEntity();
        when(() => getOrderDetails.execute(any())).thenAnswer(
          (_) async => Success(entity),
        );
        return cubit;
      },
      act: (c) => c.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId)),
      expect: () => [
        isA<OrderDetailsState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.errorMessage, 'errorMessage', '')
            .having((s) => s.data, 'data', isNull),
        isA<OrderDetailsState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', '')
            .having((s) => s.data, 'data', isNotNull),
      ],
      verify: (c) {
        expect(
          c.state.data,
          isA<DriverOrderDetailsEntity>()
              .having((e) => e.orderId, 'orderId', kOrderId)
              .having((e) => e.status, 'status', 'PickedUp'),
        );
      },
    );

    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'emits loading then a localised message on failure',
      build: () {
        when(() => getOrderDetails.execute(any())).thenAnswer(
          (_) async => Error<DriverOrderDetailsEntity>(
            const NotFoundFailure(),
          ),
        );
        return cubit;
      },
      act: (c) => c.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId)),
      expect: () => [
        isA<OrderDetailsState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<OrderDetailsState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', isNotEmpty)
            .having((s) => s.data, 'data', isNull),
      ],
    );

    test('clears a previous error message when a new load starts', () async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Error<DriverOrderDetailsEntity>(
          const NotFoundFailure(),
        ),
      );

      final states = <OrderDetailsState>[];
      final subscription = cubit.stream.listen(states.add);

      cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));
      await pumpEventQueue();
      cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));
      await pumpEventQueue();

      await subscription.cancel();

      expect(states, hasLength(4));
      expect(states[0].isLoading, isTrue);
      expect(states[1].errorMessage, isNotEmpty);
      expect(states[2].isLoading, isTrue);
      expect(states[2].errorMessage, '');
      expect(states[3].errorMessage, isNotEmpty);
      expect(states[3].isLoading, isFalse);
    });

    test('forwards the orderId to the use case', () async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity()),
      );

      cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));
      await Future<void>.delayed(Duration.zero);

      verify(() => getOrderDetails.execute(kOrderId)).called(1);
    });
  });

  group('UpdateOrderStatusEvent', () {
    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'emits loading then updateStatusSuccess on success',
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
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.updateStatusSuccess, 'updateStatusSuccess', isFalse),
        isA<OrderDetailsState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.updateStatusSuccess, 'updateStatusSuccess', isTrue)
            .having((s) => s.errorMessage, 'errorMessage', ''),
      ],
      verify: (_) {
        final state = cubit.state;
        expect(state.updateStatusSuccess, isTrue);
      },
    );

    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'emits a localised message and keeps success false on failure',
      build: () {
        when(() => updateOrderStatus.execute(any())).thenAnswer(
          (_) async => Error<UpdateOrderStatusEntity>(
            const ConflictFailure(serverMessage: 'busy'),
          ),
        );
        return cubit;
      },
      act: (c) => c.doEvent(
        UpdateOrderStatusEvent(orderId: kOrderId, newStatus: 'PickedUp'),
      ),
      expect: () => [
        isA<OrderDetailsState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<OrderDetailsState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.updateStatusSuccess, 'updateStatusSuccess', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', isNotEmpty),
      ],
    );

    test('passes orderId and newStatus through to the use case', () async {
      when(() => updateOrderStatus.execute(any())).thenAnswer(
        (_) async => Success(buildUpdateOrderStatusEntity()),
      );

      cubit.doEvent(
        UpdateOrderStatusEvent(orderId: kOrderId, newStatus: 'OutForDelivery'),
      );
      await Future<void>.delayed(Duration.zero);

      final captured = verify(
        () => updateOrderStatus.execute(captureAny()),
      ).captured.single as dynamic;
      expect(captured.orderId, kOrderId);
      expect(captured.newStatus, 'OutForDelivery');
    });

    test('does not call the location use case', () async {
      when(() => updateOrderStatus.execute(any())).thenAnswer(
        (_) async => Success(buildUpdateOrderStatusEntity()),
      );

      cubit.doEvent(
        UpdateOrderStatusEvent(orderId: kOrderId, newStatus: 'PickedUp'),
      );
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => reportDriverLocation.execute(any()));
      verifyNever(() => getOrderDetails.execute(any()));
    });
  });

  group('ReportDriverLocationEvent', () {
    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'emits loading then reportLocationSuccess on success',
      build: () {
        when(() => reportDriverLocation.execute(any())).thenAnswer(
          (_) async => Success(buildReportDriverLocationEntity()),
        );
        return cubit;
      },
      act: (c) => c.doEvent(
        ReportDriverLocationEvent(
          lat: 30.0444,
          lng: 31.2357,
          recordedAt: '2026-09-19T18:00:00Z',
        ),
      ),
      expect: () => [
        isA<OrderDetailsState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having(
              (s) => s.reportLocationSuccess,
              'reportLocationSuccess',
              isFalse,
            ),
        isA<OrderDetailsState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having(
              (s) => s.reportLocationSuccess,
              'reportLocationSuccess',
              isTrue,
            ),
      ],
      verify: (_) {
        expect(cubit.state.reportLocationSuccess, isTrue);
      },
    );

    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'emits a localised message and keeps success false on failure',
      build: () {
        when(() => reportDriverLocation.execute(any())).thenAnswer(
          (_) async => Error<ReportDriverLocationEntity>(
            const InternetConnectionFailure(),
          ),
        );
        return cubit;
      },
      act: (c) => c.doEvent(
        ReportDriverLocationEvent(lat: 1, lng: 2, recordedAt: 'ts'),
      ),
      expect: () => [
        isA<OrderDetailsState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<OrderDetailsState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having(
              (s) => s.reportLocationSuccess,
              'reportLocationSuccess',
              isFalse,
            )
            .having((s) => s.errorMessage, 'errorMessage', isNotEmpty),
      ],
    );

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
      await Future<void>.delayed(Duration.zero);

      final captured =
          verify(() => reportDriverLocation.execute(captureAny()))
              .captured
              .single as dynamic;
      expect(captured.lat, 30.0444);
      expect(captured.lng, 31.2357);
      expect(captured.recordedAt, '2026-09-19T18:00:00Z');
    });
  });
}