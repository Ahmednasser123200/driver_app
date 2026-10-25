// import 'package:driver_app/config/base/base_cubit.dart';
// import 'package:driver_app/config/base/base_response.dart';
// import 'package:driver_app/config/errors/app_failure.dart';
// import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
// import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
// import 'package:driver_app/features/order_details/domain/params/update_order_status_params.dart';
// import 'package:driver_app/features/order_details/domain/usecases/get_driver_order_details_use_case.dart';
// import 'package:driver_app/features/order_details/domain/usecases/update_order_status_use_case.dart';
// import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_event.dart';
// import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_state.dart';
// import 'package:injectable/injectable.dart';

// import '../../../../../config/base/base_ui_event.dart';

// @injectable
// class OrderDetailsCubit extends BaseCubit<OrderDetailsState, BaseUiEvent> {
//   OrderDetailsCubit({
//     required this._getDriverOrderDetailsUseCase,
//     required this._updateOrderStatusUseCase,
//   }) : super(const OrderDetailsState());

//   final GetDriverOrderDetailsUseCase _getDriverOrderDetailsUseCase;
//   final UpdateOrderStatusUseCase _updateOrderStatusUseCase;

//   Future<void> doEvent(OrderDetailsEvent event) async {
//     switch (event) {
//       case GetDriverOrderDetailsEvent():
//         await _getOrderDetails(event.orderId);

//       case UpdateOrderStatusEvent():
//         await _updateOrderStatus(event.orderId, event.newStatus);
//     }
//   }

//   Future<void> _getOrderDetails(String orderId) async {
//     emit(
//       state.copyWith(
//         orderDetails: state.orderDetails.copyWith(isLoading: true),
//       ),
//     );

//     final result = await _getDriverOrderDetailsUseCase.execute(orderId);

//     switch (result) {
//       case Success<DriverOrderDetailsEntity>():
//         emit(
//           state.copyWith(
//             orderDetails: state.orderDetails.copyWith(
//               isLoading: false,
//               data: result.data,
//             ),
//           ),
//         );

//       case Error<DriverOrderDetailsEntity>():
//         emit(
//           state.copyWith(
//             orderDetails: state.orderDetails.copyWith(isLoading: false),
//           ),
//         );

//         _reportFailure(result.failure);
//     }
//   }

//   Future<void> _updateOrderStatus(String orderId, String newStatus) async {
//     emit(
//       state.copyWith(
//         updateOrderStatus: state.updateOrderStatus.copyWith(isLoading: true),
//       ),
//     );

//     final result = await _updateOrderStatusUseCase.execute(
//       UpdateOrderStatusParams(orderId: orderId, newStatus: newStatus),
//     );

//     switch (result) {
//       case Success<UpdateOrderStatusEntity>():
//         emit(
//           state.copyWith(
//             updateOrderStatus: state.updateOrderStatus.copyWith(
//               isLoading: false,
//               data: result.data,
//             ),
//           ),
//         );

//         emitEvent(const ShowOrderStatusUpdated());

//       case Error<UpdateOrderStatusEntity>():
//         emit(
//           state.copyWith(
//             updateOrderStatus: state.updateOrderStatus.copyWith(
//               isLoading: false,
//             ),
//           ),
//         );

//         _reportFailure(result.failure);
//     }
//   }

//   void _reportFailure(AppFailure failure) {
//     emitEvent(ShowOrderDetailsFailure(failure));
//   }
// }

import 'dart:async';

import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/localization/handle_success_text.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_status_update.dart';
import 'package:driver_app/features/order_details/domain/entities/order_status.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:driver_app/features/order_details/domain/params/update_order_status_params.dart';
import 'package:driver_app/features/order_details/domain/services/contact_launcher.dart';
import 'package:driver_app/features/order_details/domain/usecases/get_driver_order_details_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/update_order_status_use_case.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_event.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class OrderDetailsCubit extends BaseCubit<OrderDetailsState, BaseUiEvent> {
  OrderDetailsCubit({
    required GetDriverOrderDetailsUseCase getDriverOrderDetailsUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
    required ContactLauncher contactLauncher,
    this.pollInterval = const Duration(seconds: 5),
  }) : _getDriverOrderDetailsUseCase = getDriverOrderDetailsUseCase,
       _updateOrderStatusUseCase = updateOrderStatusUseCase,
       _contactLauncher = contactLauncher,
       super(const OrderDetailsState());

  final GetDriverOrderDetailsUseCase _getDriverOrderDetailsUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  final ContactLauncher _contactLauncher;

  /// How often the order is re-read while it waits for the customer to
  /// confirm the delivery. Overridable so tests do not depend on real seconds.
  final Duration pollInterval;

  Timer? _deliveryPollTimer;
  String _polledOrderId = '';
  bool _deliverySuccessNavigated = false;

  Future<void> doEvent(OrderDetailsEvent event) async {
    switch (event) {
      case GetDriverOrderDetailsEvent():
        await _getOrderDetails(event.orderId);

      case UpdateOrderStatusEvent():
        await _updateOrderStatus(event.orderId, event.newStatus);

      case CallRecipientEvent():
        await _contactRecipient();

      case WhatsAppRecipientEvent():
        await _contactRecipient(whatsApp: true);

      case CallStoreEvent():
        await _contactStore();

      case WhatsAppStoreEvent():
        await _contactStore(whatsApp: true);
    }
  }

  /// Loads the order details. [showLoading] is disabled when refreshing after
  /// a successful status update so the screen keeps rendering the current order
  /// instead of flashing a spinner. [reportFailure] is disabled for the silent
  /// re-reads that watch for the customer's confirmation, so a network blip
  /// does not spam the driver with snackbars.
  Future<void> _getOrderDetails(
    String orderId, {
    bool showLoading = true,
    bool reportFailure = true,
  }) async {
    if (orderId.trim().isEmpty) {
      const failure = BadRequestFailure();
      emit(
        state.copyWith(orderDetails: const BaseState(errorMessage: failure)),
      );
      emitEvent(const ShowFailureMessage(failure));
      return;
    }

    if (showLoading) {
      emit(state.copyWith(orderDetails: const BaseState(isLoading: true)));
    }

    final result = await _getDriverOrderDetailsUseCase.execute(orderId);

    if (isClosed) return;

    switch (result) {
      case Success<DriverOrderDetailsEntity>():
        emit(
          state.copyWith(
            orderDetails: BaseState(isLoading: false, data: result.data),
          ),
        );
        _syncDeliveryOutcome(orderId);

      case Error<DriverOrderDetailsEntity>():
        if (!reportFailure) return;

        emit(
          state.copyWith(
            orderDetails: BaseState(
              isLoading: false,
              data: state.orderDetails.data,
              errorMessage: result.failure,
            ),
          ),
        );

        emitEvent(ShowFailureMessage(result.failure));
    }
  }

  Future<void> _updateOrderStatus(
    String orderId,
    DriverStatusUpdate newStatus,
  ) async {
    emit(state.copyWith(updateOrderStatus: const BaseState(isLoading: true)));

    final result = await _updateOrderStatusUseCase.execute(
      UpdateOrderStatusParams(orderId: orderId, newStatus: newStatus),
    );

    if (isClosed) return;

    switch (result) {
      case Success<UpdateOrderStatusEntity>():
        emit(
          state.copyWith(
            updateOrderStatus: BaseState(isLoading: false, data: result.data),
          ),
        );
        emitEvent(const ShowSuccessMessage(AppSuccessEnum.orderUpdated));

        // The request body only carries the requested status, so re-read the
        // order to render the status the backend actually stored.
        await _getOrderDetails(orderId, showLoading: false);

      case Error<UpdateOrderStatusEntity>():
        emit(
          state.copyWith(
            updateOrderStatus: BaseState(
              isLoading: false,
              errorMessage: result.failure,
            ),
          ),
        );

        emitEvent(ShowFailureMessage(result.failure));
    }
  }

  /// Reacts to the status the backend stored. `Delivered` is the customer's
  /// confirmation of receipt — it is never sent by the driver, so it can only
  /// appear on a fresh read of the order.
  void _syncDeliveryOutcome(String orderId) {
    final status = state.orderDetails.data?.status;

    if (status == OrderStatus.delivered) {
      _stopDeliveryPolling();
      if (_deliverySuccessNavigated) return;
      _deliverySuccessNavigated = true;
      emitEvent(const NavigateRepalceTo(Routes.deliverySuccess));
      return;
    }

    // While the order sits at `AwaitingDeliveryConfirmation` the only thing
    // that can move it forward is the customer, so re-read it periodically
    // until the backend reports `Delivered` (or the order leaves that state).
    if (status == OrderStatus.arrived) {
      _startDeliveryPolling(orderId);
      return;
    }

    _stopDeliveryPolling();
  }

  void _startDeliveryPolling(String orderId) {
    if (_deliveryPollTimer != null && _polledOrderId == orderId) return;

    _stopDeliveryPolling();
    _polledOrderId = orderId;
    _deliveryPollTimer = Timer.periodic(pollInterval, (_) {
      if (isClosed) {
        _stopDeliveryPolling();
        return;
      }
      unawaited(
        _getOrderDetails(
          _polledOrderId,
          showLoading: false,
          reportFailure: false,
        ),
      );
    });
  }

  void _stopDeliveryPolling() {
    _deliveryPollTimer?.cancel();
    _deliveryPollTimer = null;
    _polledOrderId = '';
  }

  @override
  Future<void> close() {
    _stopDeliveryPolling();
    return super.close();
  }

  /// Opens the dialer / WhatsApp for the order's recipient. The number is
  /// resolved from the loaded order, so the widget layer never touches it.
  Future<void> _contactRecipient({bool whatsApp = false}) =>
      _contactPhone(_recipientPhone(), whatsApp: whatsApp);

  /// Opens the dialer / WhatsApp for the store the driver picks the order up
  /// from. The number comes from the order's pickup data only (never the
  /// recipient's); an empty number is reported as invalid instead of dialled.
  Future<void> _contactStore({bool whatsApp = false}) => _contactPhone(
    state.orderDetails.data?.pickupAddress.phone ?? '',
    whatsApp: whatsApp,
  );

  Future<void> _contactPhone(String phone, {required bool whatsApp}) async {
    if (whatsApp) {
      final outcome = await _contactLauncher.whatsApp(phone);
      if (isClosed) return;
      _reportContactOutcome(outcome);
      return;
    }

    final outcome = await _contactLauncher.call(phone);
    if (isClosed) return;
    _reportContactOutcome(outcome);
  }

  String _recipientPhone() {
    final data = state.orderDetails.data;
    if (data == null) return '';

    final addressPhone = data.userAddress.phone;
    if (addressPhone.trim().isNotEmpty) return addressPhone;

    return data.recipientInfo.recipientPhone;
  }

  void _reportContactOutcome(ContactLaunchOutcome outcome) {
    switch (outcome) {
      case ContactLaunchOutcome.launched:
        break;
      case ContactLaunchOutcome.invalidNumber:
        emitEvent(const ShowFailureMessage(InvalidPhoneFailure()));
      case ContactLaunchOutcome.whatsAppUnavailable:
        emitEvent(const ShowFailureMessage(WhatsAppUnavailableFailure()));
      case ContactLaunchOutcome.failed:
        emitEvent(const ShowFailureMessage(ContactLaunchFailure()));
    }
  }
}
