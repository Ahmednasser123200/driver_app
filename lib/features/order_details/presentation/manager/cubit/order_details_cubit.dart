import 'dart:async';

import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_location.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:driver_app/features/order_details/domain/params/update_order_status_params.dart';
import 'package:driver_app/features/order_details/domain/services/contact_launcher.dart';
import 'package:driver_app/features/order_details/domain/usecases/get_driver_order_details_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/report_driver_location_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/update_order_status_use_case.dart';
import 'package:driver_app/features/order_details/presentation/extensions/order_status_string_extension.dart';
import 'package:driver_app/features/order_details/presentation/extensions/order_status_tracking_extension.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_event.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_state.dart';
import 'package:driver_app/features/order_details/presentation/utils/location_reporting_status.dart';
import 'package:injectable/injectable.dart';

@injectable
class OrderDetailsCubit extends BaseCubit<OrderDetailsState, BaseUiEvent> {
  OrderDetailsCubit({
    required this.getDriverOrderDetailsUseCase,
    required this.updateOrderStatusUseCase,
    required this.reportDriverLocationUseCase,
  }) : super(const OrderDetailsState());

  final GetDriverOrderDetailsUseCase getDriverOrderDetailsUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final ReportDriverLocationUseCase reportDriverLocationUseCase;

  StreamSubscription<BaseResponse<DriverLocation>>? _locationSubscription;

  Future<void> doEvent(OrderDetailsEvent event) async {
    switch (event) {
      case GetDriverOrderDetailsEvent():
        await _getOrderDetails(event.orderId);

      case UpdateOrderStatusEvent():
        await _updateOrderStatus(event.orderId, event.newStatus);

      case StartLocationReportingEvent():
        await _startLocationReporting();

      case StopLocationReportingEvent():
        await _stopLocationReporting();
    }
  }

  Future<void> _handleLocationError(AppFailure failure) async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;

    emit(
      state.copyWith(
        locationReportingStatus: LocationReportingStatus.error,
        reportDriverLocation: state.reportDriverLocation.copyWith(
          isLoading: false,
          failure: failure,
        ),
      ),
    );
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

    final result = await getDriverOrderDetailsUseCase.execute(orderId);

    switch (result) {
      case Success<DriverOrderDetailsEntity>():
        emit(
          state.copyWith(
            orderDetails: BaseState(isLoading: false, data: result.data),
          ),
        );

        if (result.data.status.shouldTrackLocation) {
          await _startLocationReporting();
        }
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

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    emit(
      state.copyWith(
        updateOrderStatus: state.updateOrderStatus.copyWith(
          isLoading: true,
          clearFailure: true,
        ),
      ),
    );

    final result = await updateOrderStatusUseCase.execute(
      UpdateOrderStatusParams(orderId: orderId, newStatus: newStatus),
    );

    if (isClosed) return;

    switch (result) {
      case Success<UpdateOrderStatusEntity>():
        emit(
          state.copyWith(
            updateOrderStatus: state.updateOrderStatus.copyWith(
              isLoading: false,
              data: result.data,
              clearFailure: true,
            ),
          ),
        );

        emitEvent(const ShowOrderStatusUpdated());

        if (newStatus.isTerminalOrderStatus) {
          await _stopLocationReporting();
        } else if (newStatus.isInTransitOrderStatus) {
          await _startLocationReporting();
        }

      case Error<UpdateOrderStatusEntity>():
        emit(
          state.copyWith(
            updateOrderStatus: BaseState(
              isLoading: false,
              errorMessage: result.failure,
            ),
          ),
        );

        _reportFailure(result.failure);
    }
  }

  Future<void> _startLocationReporting() async {
  await _locationSubscription?.cancel();
  _locationSubscription = null;

  emit(
    state.copyWith(
      locationReportingStatus: LocationReportingStatus.active,
      reportDriverLocation: state.reportDriverLocation.copyWith(
        isLoading: true,
        clearFailure: true,
      ),
    ),
  );

  _locationSubscription = reportDriverLocationUseCase.start(
    onReportResult: (result, location) {
      switch (result) {
        case Success<ReportDriverLocationEntity>():
          emit(
            state.copyWith(
              driverLocation: location,
              reportDriverLocation:
                  state.reportDriverLocation.copyWith(
                isLoading: false,
                data: result.data,
                clearFailure: true,
              ),
            ),
          );

        case Error<ReportDriverLocationEntity>():
          emit(
            state.copyWith(
              reportDriverLocation:
                  state.reportDriverLocation.copyWith(
                isLoading: false,
                failure: result.failure,
              ),
            ),
          );
      }
    },
    onLocationError: (failure) {
      unawaited(_handleLocationError(failure));
    },
  );
}

  Future<void> _stopLocationReporting() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;

    emit(
      state.copyWith(
        locationReportingStatus: LocationReportingStatus.inactive,
        reportDriverLocation: state.reportDriverLocation.copyWith(
          isLoading: false,
        ),
      ),
    );
  }

  void _reportFailure(AppFailure failure) {
    emitEvent(ShowOrderDetailsFailure(failure));
  }

  @override
  Future<void> close() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    return super.close();
  }
}
