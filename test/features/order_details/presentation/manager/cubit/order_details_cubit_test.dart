<<<<<<< HEAD
=======
import 'dart:async';

>>>>>>> background-reporting
import 'package:bloc_test/bloc_test.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
<<<<<<< HEAD
import 'package:driver_app/config/routing/routes.dart';
=======
import 'package:driver_app/features/order_details/domain/entities/driver_location.dart';
>>>>>>> background-reporting
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_status_update.dart';
import 'package:driver_app/features/order_details/domain/entities/order_status.dart';
<<<<<<< HEAD
import 'package:driver_app/features/order_details/domain/entities/recipient_info.dart';
=======
import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
>>>>>>> background-reporting
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:driver_app/features/order_details/domain/entities/user_address.dart';
import 'package:driver_app/features/order_details/domain/params/update_order_status_params.dart';
import 'package:driver_app/features/order_details/domain/services/contact_launcher.dart';
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

<<<<<<< HEAD
class MockContactLauncher extends Mock implements ContactLauncher {}
=======
class MockReportDriverLocationUseCase extends Mock
    implements ReportDriverLocationUseCase {}

class MockStreamSubscription extends Mock
    implements StreamSubscription<BaseResponse<DriverLocation>> {}
>>>>>>> background-reporting

void main() {
  late MockGetDriverOrderDetailsUseCase getOrderDetails;
  late MockUpdateOrderStatusUseCase updateOrderStatus;
<<<<<<< HEAD
  late MockContactLauncher contactLauncher;
=======
  late MockReportDriverLocationUseCase reportDriverLocation;
>>>>>>> background-reporting
  late OrderDetailsCubit cubit;

  setUpAll(() {
    registerFallbackValue(
      const UpdateOrderStatusParams(
        orderId: '',
        newStatus: DriverStatusUpdate.pickedUp,
      ),
    );
  });

  setUp(() {
    getOrderDetails = MockGetDriverOrderDetailsUseCase();
    updateOrderStatus = MockUpdateOrderStatusUseCase();
<<<<<<< HEAD
    contactLauncher = MockContactLauncher();
    cubit = OrderDetailsCubit(
      getDriverOrderDetailsUseCase: getOrderDetails,
      updateOrderStatusUseCase: updateOrderStatus,
      contactLauncher: contactLauncher,
=======
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
>>>>>>> background-reporting
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
<<<<<<< HEAD
        when(
          () => getOrderDetails.execute(any()),
        ).thenAnswer((_) async => Success(buildDriverOrderDetailsEntity()));
=======
        when(() => getOrderDetails.execute(any())).thenAnswer(
          (_) async => Success(
            buildDriverOrderDetailsEntity(status: OrderStatus.pickedUp),
          ),
        );
>>>>>>> background-reporting
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
            .having((s) => s.orderDetails.errorMessage, 'errorMessage', isNull)
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
        isA<ShowFailureMessage>().having(
          (e) => e.failure,
          'failure',
          isA<NotFoundFailure>(),
        ),
      );
      expect(cubit.state.orderDetails.errorMessage, isA<NotFoundFailure>());
      expect(cubit.state.orderDetails.isLoading, isFalse);
    });
<<<<<<< HEAD

    test('passes the orderId to the use case', () async {
      when(
        () => getOrderDetails.execute(any()),
      ).thenAnswer((_) async => Success(buildDriverOrderDetailsEntity()));

      await cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));

      verify(() => getOrderDetails.execute(kOrderId)).called(1);
    });

    test('rejects an empty order ID without requesting details', () async {
      final events = await collectEvents(
        () => cubit.doEvent(GetDriverOrderDetailsEvent(orderId: '  ')),
      );

      expect(cubit.state.orderDetails.isLoading, isFalse);
      expect(cubit.state.orderDetails.errorMessage, isA<BadRequestFailure>());
      expect(
        events.single,
        isA<ShowFailureMessage>().having(
          (event) => event.failure,
          'failure',
          isA<BadRequestFailure>(),
        ),
      );
      verifyNever(() => getOrderDetails.execute(any()));
    });
=======
>>>>>>> background-reporting
  });

  group('UpdateOrderStatusEvent', () {
    void mockUpdateSuccess() {
      when(
        () => updateOrderStatus.execute(any()),
      ).thenAnswer((_) async => Success(buildUpdateOrderStatusEntity()));
    }

    blocTest<OrderDetailsCubit, OrderDetailsState>(
<<<<<<< HEAD
      'emits loading, success and the reloaded order',
      build: () {
        mockUpdateSuccess();
        when(() => getOrderDetails.execute(any())).thenAnswer(
          (_) async => Success(
            buildDriverOrderDetailsEntity(status: OrderStatus.pickedUp),
          ),
        );
        return cubit;
      },
      act: (c) => c.doEvent(
        UpdateOrderStatusEvent(
          orderId: kOrderId,
          newStatus: DriverStatusUpdate.pickedUp,
=======
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
>>>>>>> background-reporting
        ),
      ),
      expect: () => [
        isA<OrderDetailsState>().having(
          (s) => s.updateOrderStatus.isLoading,
          'updateOrderStatus.isLoading',
          isTrue,
        ),
        isA<OrderDetailsState>()
<<<<<<< HEAD
            .having(
              (s) => s.updateOrderStatus.isLoading,
              'updateOrderStatus.isLoading',
              isFalse,
            )
            .having(
              (s) => s.updateOrderStatus.data,
              'updateOrderStatus.data',
              isNotNull,
            ),
        isA<OrderDetailsState>()
            .having(
              (s) => s.orderDetails.isLoading,
              'orderDetails.isLoading',
              isFalse,
            )
            .having(
              (s) => s.orderDetails.data?.status,
              'orderDetails.status',
              OrderStatus.pickedUp,
=======
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
>>>>>>> background-reporting
            ),
      ],
    );

<<<<<<< HEAD
    test('emits ShowSuccessMessage on success', () async {
      mockUpdateSuccess();
      when(
        () => getOrderDetails.execute(any()),
      ).thenAnswer((_) async => Success(buildDriverOrderDetailsEntity()));

      final events = await collectEvents(
        () => cubit.doEvent(
          UpdateOrderStatusEvent(
            orderId: kOrderId,
            newStatus: DriverStatusUpdate.pickedUp,
          ),
        ),
      );

      expect(events, hasLength(1));
      expect(events.single, isA<ShowSuccessMessage>());
    });

    test('reloads the order so the stored status is rendered', () async {
      mockUpdateSuccess();
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(
          buildDriverOrderDetailsEntity(status: OrderStatus.outForDelivery),
        ),
      );

      await cubit.doEvent(
        UpdateOrderStatusEvent(
          orderId: kOrderId,
          newStatus: DriverStatusUpdate.outForDelivery,
        ),
      );

      verify(() => getOrderDetails.execute(kOrderId)).called(1);
      expect(cubit.state.orderDetails.data?.status, OrderStatus.outForDelivery);
    });

    test('does not reload the order when the update fails', () async {
=======
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
>>>>>>> background-reporting
      when(() => updateOrderStatus.execute(any())).thenAnswer(
        (_) async => Error<UpdateOrderStatusEntity>(
          const ConflictFailure(
            serverMessage: "Cannot transition from 'Preparing' to 'PickedUp'.",
          ),
        ),
      );

      await cubit.doEvent(
        UpdateOrderStatusEvent(
          orderId: kOrderId,
          newStatus: DriverStatusUpdate.pickedUp,
        ),
      );

      verifyNever(() => getOrderDetails.execute(any()));
      expect(cubit.state.orderDetails.data, isNull);
    });

    test('emits ShowFailureMessage on error', () async {
      when(() => updateOrderStatus.execute(any())).thenAnswer(
        (_) async => Error<UpdateOrderStatusEntity>(
          const ConflictFailure(
            serverMessage: "Cannot transition from 'Preparing' to 'PickedUp'.",
          ),
        ),
      );

      final events = await collectEvents(
        () => cubit.doEvent(
<<<<<<< HEAD
          UpdateOrderStatusEvent(
            orderId: kOrderId,
            newStatus: DriverStatusUpdate.pickedUp,
=======
          const UpdateOrderStatusEvent(
            orderId: kOrderId,
            newStatus: 'accepted',
>>>>>>> background-reporting
          ),
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
      expect(
        cubit.state.updateOrderStatus.errorMessage,
        isA<ConflictFailure>(),
      );
      expect(cubit.state.updateOrderStatus.isLoading, isFalse);
    });
  });

<<<<<<< HEAD
    test(
      'keeps the last known order when the reload after a successful update fails',
      () async {
        when(
          () => getOrderDetails.execute(any()),
        ).thenAnswer((_) async => Success(buildDriverOrderDetailsEntity()));
        await cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));
        expect(cubit.state.orderDetails.data, isNotNull);

        mockUpdateSuccess();
        when(() => getOrderDetails.execute(any())).thenAnswer(
          (_) async => Error<DriverOrderDetailsEntity>(const NotFoundFailure()),
        );

        final events = await collectEvents(
          () => cubit.doEvent(
            UpdateOrderStatusEvent(
              orderId: kOrderId,
              newStatus: DriverStatusUpdate.pickedUp,
            ),
          ),
        );

        expect(cubit.state.orderDetails.data, isNotNull);
        expect(cubit.state.orderDetails.errorMessage, isA<NotFoundFailure>());
        expect(events.whereType<ShowSuccessMessage>(), hasLength(1));
        expect(events.whereType<ShowFailureMessage>(), hasLength(1));
      },
    );

    test('passes orderId and newStatus to the use case', () async {
      mockUpdateSuccess();
      when(
        () => getOrderDetails.execute(any()),
      ).thenAnswer((_) async => Success(buildDriverOrderDetailsEntity()));

      await cubit.doEvent(
        UpdateOrderStatusEvent(
          orderId: kOrderId,
          newStatus: DriverStatusUpdate.outForDelivery,
        ),
=======
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
>>>>>>> background-reporting
      );
      expect(
        cubit.state.locationReportingStatus,
        LocationReportingStatus.active,
      );
      expect(events, isEmpty);

<<<<<<< HEAD
      final captured =
          verify(() => updateOrderStatus.execute(captureAny())).captured.single
              as UpdateOrderStatusParams;

      expect(captured.orderId, kOrderId);
      expect(captured.newStatus, DriverStatusUpdate.outForDelivery);
    });
  });

  group('recipient contact', () {
    const recipientPhone = '+201012345678';

    test('calls the loaded order recipient', () async {
      when(
        () => getOrderDetails.execute(any()),
      ).thenAnswer((_) async => Success(buildDriverOrderDetailsEntity()));
      when(
        () => contactLauncher.call(any()),
      ).thenAnswer((_) async => ContactLaunchOutcome.launched);

      await cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));
      await cubit.doEvent(const CallRecipientEvent());

      verify(() => contactLauncher.call(recipientPhone)).called(1);
      verifyNever(() => contactLauncher.whatsApp(any()));
    });

    test('whatsapp uses the same loaded number', () async {
      when(
        () => getOrderDetails.execute(any()),
      ).thenAnswer((_) async => Success(buildDriverOrderDetailsEntity()));
      when(
        () => contactLauncher.whatsApp(any()),
      ).thenAnswer((_) async => ContactLaunchOutcome.launched);

      await cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));
      await cubit.doEvent(const WhatsAppRecipientEvent());

      verify(() => contactLauncher.whatsApp(recipientPhone)).called(1);
    });

    test('falls back to recipientInfo when the address has no phone', () async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(
          buildDriverOrderDetailsEntity(
            userAddress: const UserAddressEntity(
              recipientName: 'Nour Mohamed',
              phone: '',
              addressLine: '20th st, Sheikh Zayed, Giza',
              latitude: 30.0444,
              longitude: 31.2357,
            ),
            recipientInfo: const RecipientInfoEntity(
              isGift: true,
              recipientName: 'Sara',
              recipientPhone: '+201098765432',
            ),
          ),
        ),
      );
      when(
        () => contactLauncher.call(any()),
      ).thenAnswer((_) async => ContactLaunchOutcome.launched);

      await cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));
      await cubit.doEvent(const CallRecipientEvent());

      verify(() => contactLauncher.call('+201098765432')).called(1);
    });

    test(
      'emits InvalidPhoneFailure when the number cannot be resolved',
      () async {
        when(
          () => contactLauncher.call(any()),
        ).thenAnswer((_) async => ContactLaunchOutcome.invalidNumber);

        final events = await collectEvents(
          () => cubit.doEvent(const CallRecipientEvent()),
        );

        expect(
          events.single,
          isA<ShowFailureMessage>().having(
            (e) => e.failure,
            'failure',
            isA<InvalidPhoneFailure>(),
          ),
        );
      },
    );

    test('reports the launcher outcome failures', () async {
      when(
        () => getOrderDetails.execute(any()),
      ).thenAnswer((_) async => Success(buildDriverOrderDetailsEntity()));

      await cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));

      when(
        () => contactLauncher.whatsApp(any()),
      ).thenAnswer((_) async => ContactLaunchOutcome.whatsAppUnavailable);
      var events = await collectEvents(
        () => cubit.doEvent(const WhatsAppRecipientEvent()),
      );
      expect(
        events.single,
        isA<ShowFailureMessage>().having(
          (e) => e.failure,
          'failure',
          isA<WhatsAppUnavailableFailure>(),
        ),
      );

      when(
        () => contactLauncher.call(any()),
      ).thenAnswer((_) async => ContactLaunchOutcome.failed);
      events = await collectEvents(
        () => cubit.doEvent(const CallRecipientEvent()),
      );
      expect(
        events.single,
        isA<ShowFailureMessage>().having(
          (e) => e.failure,
          'failure',
          isA<ContactLaunchFailure>(),
        ),
      );
    });
  });

  group('store contact', () {
    const storePhone = '+201234567890';

    Matcher failedWith<T extends AppFailure>() => isA<ShowFailureMessage>()
        .having((event) => event.failure, 'failure', isA<T>());

    test('calls the pickup store number, not the recipient one', () async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(
          buildDriverOrderDetailsEntity(
            pickupAddress: buildPickupAddressEntity(phone: storePhone),
          ),
        ),
      );
      when(
        () => contactLauncher.call(any()),
      ).thenAnswer((_) async => ContactLaunchOutcome.launched);

      await cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));
      await cubit.doEvent(const CallStoreEvent());

      verify(() => contactLauncher.call(storePhone)).called(1);
      verifyNever(() => contactLauncher.call('+201012345678'));
    });

    test('whatsapp opens the pickup store number', () async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(
          buildDriverOrderDetailsEntity(
            pickupAddress: buildPickupAddressEntity(phone: storePhone),
          ),
        ),
      );
      when(
        () => contactLauncher.whatsApp(any()),
      ).thenAnswer((_) async => ContactLaunchOutcome.launched);

      await cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));
      await cubit.doEvent(const WhatsAppStoreEvent());

      verify(() => contactLauncher.whatsApp(storePhone)).called(1);
      verifyNever(() => contactLauncher.whatsApp('+201012345678'));
    });

    test('reports an invalid number when the store has no phone', () async {
      when(
        () => getOrderDetails.execute(any()),
      ).thenAnswer((_) async => Success(buildDriverOrderDetailsEntity()));
      when(
        () => contactLauncher.call(any()),
      ).thenAnswer((_) async => ContactLaunchOutcome.invalidNumber);

      await cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));
      final events = await collectEvents(
        () => cubit.doEvent(const CallStoreEvent()),
      );

      verify(() => contactLauncher.call('')).called(1);
      expect(events.single, failedWith<InvalidPhoneFailure>());
    });

    test('does nothing beyond reporting when no order is loaded', () async {
      when(
        () => contactLauncher.call(any()),
      ).thenAnswer((_) async => ContactLaunchOutcome.invalidNumber);

      final events = await collectEvents(
        () => cubit.doEvent(const CallStoreEvent()),
      );

      verify(() => contactLauncher.call('')).called(1);
      expect(events.single, failedWith<InvalidPhoneFailure>());
    });
  });

  group('delivery confirmation', () {
    OrderDetailsCubit buildPollingCubit() => OrderDetailsCubit(
      getDriverOrderDetailsUseCase: getOrderDetails,
      updateOrderStatusUseCase: updateOrderStatus,
      contactLauncher: contactLauncher,
      pollInterval: const Duration(milliseconds: 10),
    );

    Matcher navigateToSuccess() => isA<NavigateRepalceTo>().having(
      (event) => event.routeName,
      'routeName',
      Routes.deliverySuccess,
    );

    void mockStatus(OrderStatus status) {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity(status: status)),
      );
    }

    test('navigates to the success screen once the backend reports '
        'Delivered', () async {
      mockStatus(OrderStatus.delivered);

      final events = await collectEvents(
        () => cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId)),
      );

      expect(events.whereType<NavigateRepalceTo>(), [navigateToSuccess()]);
    });

    test(
      'does not navigate while the customer has not confirmed yet',
      () async {
        mockStatus(OrderStatus.arrived);

        final events = await collectEvents(
          () => cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId)),
        );

        expect(events.whereType<NavigateRepalceTo>(), isEmpty);
        expect(cubit.state.orderDetails.data?.status, OrderStatus.arrived);
      },
    );

    test('does not navigate when the order cannot be loaded', () async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Error<DriverOrderDetailsEntity>(const NotFoundFailure()),
      );

      final events = await collectEvents(
        () => cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId)),
      );

      expect(events.whereType<NavigateRepalceTo>(), isEmpty);
      expect(events.whereType<ShowFailureMessage>(), hasLength(1));
    });

    test('does not navigate when the driver moves the order to awaiting '
        'confirmation', () async {
      when(
        () => updateOrderStatus.execute(any()),
      ).thenAnswer((_) async => Success(buildUpdateOrderStatusEntity()));
      mockStatus(OrderStatus.arrived);

      final events = await collectEvents(
        () => cubit.doEvent(
          UpdateOrderStatusEvent(
            orderId: kOrderId,
            newStatus: DriverStatusUpdate.awaitingDeliveryConfirmation,
          ),
        ),
      );

      expect(events.whereType<NavigateRepalceTo>(), isEmpty);
    });

    test(
      're-reads the order and navigates once the customer confirms',
      () async {
        final pollingCubit = buildPollingCubit();
        addTearDown(pollingCubit.close);

        var reads = 0;
        when(() => getOrderDetails.execute(any())).thenAnswer((_) async {
          reads++;
          return Success(
            buildDriverOrderDetailsEntity(
              status: reads == 1 ? OrderStatus.arrived : OrderStatus.delivered,
            ),
          );
        });

        final events = <BaseUiEvent>[];
        pollingCubit.uiEventStream.listen(events.add);

        await pollingCubit.doEvent(
          GetDriverOrderDetailsEvent(orderId: kOrderId),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(reads, greaterThan(1));
        expect(events.whereType<NavigateRepalceTo>(), hasLength(1));
=======
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
>>>>>>> background-reporting
      },
    );

    test(
<<<<<<< HEAD
      'stops re-reading the order once the success screen is shown',
      () async {
        final pollingCubit = buildPollingCubit();
        addTearDown(pollingCubit.close);

        var reads = 0;
        when(() => getOrderDetails.execute(any())).thenAnswer((_) async {
          reads++;
          return Success(
            buildDriverOrderDetailsEntity(
              status: reads == 1 ? OrderStatus.arrived : OrderStatus.delivered,
            ),
          );
        });

        await pollingCubit.doEvent(
          GetDriverOrderDetailsEvent(orderId: kOrderId),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        final settledReads = reads;

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(reads, settledReads);
      },
    );

    test('keeps the last order and stays silent when a background refresh '
        'fails', () async {
      final pollingCubit = buildPollingCubit();
      addTearDown(pollingCubit.close);

      mockStatus(OrderStatus.arrived);
      final events = <BaseUiEvent>[];
      pollingCubit.uiEventStream.listen(events.add);

      await pollingCubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Error<DriverOrderDetailsEntity>(const NotFoundFailure()),
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(events.whereType<ShowFailureMessage>(), isEmpty);
      expect(events.whereType<NavigateRepalceTo>(), isEmpty);
      expect(pollingCubit.state.orderDetails.data?.status, OrderStatus.arrived);
      expect(pollingCubit.state.orderDetails.isLoading, isFalse);
=======
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
>>>>>>> background-reporting
    });
  });
}
