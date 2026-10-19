import 'package:bloc_test/bloc_test.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_status_update.dart';
import 'package:driver_app/features/order_details/domain/entities/order_status.dart';
import 'package:driver_app/features/order_details/domain/entities/recipient_info.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:driver_app/features/order_details/domain/entities/user_address.dart';
import 'package:driver_app/features/order_details/domain/params/update_order_status_params.dart';
import 'package:driver_app/features/order_details/domain/services/contact_launcher.dart';
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

class MockContactLauncher extends Mock implements ContactLauncher {}

void main() {
  late MockGetDriverOrderDetailsUseCase getOrderDetails;
  late MockUpdateOrderStatusUseCase updateOrderStatus;
  late MockContactLauncher contactLauncher;
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
    contactLauncher = MockContactLauncher();
    cubit = OrderDetailsCubit(
      getDriverOrderDetailsUseCase: getOrderDetails,
      updateOrderStatusUseCase: updateOrderStatus,
      contactLauncher: contactLauncher,
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
        when(
          () => getOrderDetails.execute(any()),
        ).thenAnswer((_) async => Success(buildDriverOrderDetailsEntity()));
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
            .having((s) => s.orderDetails.errorMessage, 'errorMessage', isNull)
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
  });

  group('UpdateOrderStatusEvent', () {
    void mockUpdateSuccess() {
      when(
        () => updateOrderStatus.execute(any()),
      ).thenAnswer((_) async => Success(buildUpdateOrderStatusEntity()));
    }

    blocTest<OrderDetailsCubit, OrderDetailsState>(
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
        ),
      ),
      expect: () => [
        isA<OrderDetailsState>().having(
          (s) => s.updateOrderStatus.isLoading,
          'updateOrderStatus.isLoading',
          isTrue,
        ),
        isA<OrderDetailsState>()
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
            ),
      ],
    );

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
          UpdateOrderStatusEvent(
            orderId: kOrderId,
            newStatus: DriverStatusUpdate.pickedUp,
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
      );

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
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity()),
      );
      when(() => contactLauncher.call(any())).thenAnswer(
        (_) async => ContactLaunchOutcome.launched,
      );

      await cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));
      await cubit.doEvent(const CallRecipientEvent());

      verify(() => contactLauncher.call(recipientPhone)).called(1);
      verifyNever(() => contactLauncher.whatsApp(any()));
    });

    test('whatsapp uses the same loaded number', () async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity()),
      );
      when(() => contactLauncher.whatsApp(any())).thenAnswer(
        (_) async => ContactLaunchOutcome.launched,
      );

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
      when(() => contactLauncher.call(any())).thenAnswer(
        (_) async => ContactLaunchOutcome.launched,
      );

      await cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));
      await cubit.doEvent(const CallRecipientEvent());

      verify(() => contactLauncher.call('+201098765432')).called(1);
    });

    test('emits InvalidPhoneFailure when the number cannot be resolved', () async {
      when(() => contactLauncher.call(any())).thenAnswer(
        (_) async => ContactLaunchOutcome.invalidNumber,
      );

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
    });

    test('reports the launcher outcome failures', () async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity()),
      );

      await cubit.doEvent(GetDriverOrderDetailsEvent(orderId: kOrderId));

      when(() => contactLauncher.whatsApp(any())).thenAnswer(
        (_) async => ContactLaunchOutcome.whatsAppUnavailable,
      );
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

      when(() => contactLauncher.call(any())).thenAnswer(
        (_) async => ContactLaunchOutcome.failed,
      );
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
}
