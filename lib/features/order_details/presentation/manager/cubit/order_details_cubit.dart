import 'dart:async';

import 'package:driver_app/config/base/base_cubit.dart';
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
import 'package:driver_app/features/order_details/presentation/extensions/order_status_string_extension.dart';
import 'package:driver_app/features/order_details/presentation/extensions/order_status_tracking_extension.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_event.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_state.dart';
import 'package:driver_app/features/order_details/presentation/utils/location_reporting_status.dart';
import 'package:injectable/injectable.dart';

@injectable
class OrderDetailsCubit
    extends BaseCubit<OrderDetailsState, OrderDetailsUiEvent> {
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

  Future<void> _getOrderDetails(String orderId) async {
    emit(
      state.copyWith(
        orderDetails: state.orderDetails.copyWith(
          isLoading: true,
          clearFailure: true,
        ),
      ),
    );

    final result = await getDriverOrderDetailsUseCase.execute(orderId);

    switch (result) {
      case Success<DriverOrderDetailsEntity>():
        emit(
          state.copyWith(
            orderDetails: state.orderDetails.copyWith(
              isLoading: false,
              data: result.data,
              clearFailure: true,
            ),
          ),
        );

        if (result.data.status?.shouldTrackLocation ?? false) {
          await _startLocationReporting();
        }
      case Error<DriverOrderDetailsEntity>():
        emit(
          state.copyWith(
            orderDetails: state.orderDetails.copyWith(
              isLoading: false,
              failure: result.failure,
            ),
          ),
        );

        _reportFailure(result.failure);
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
            updateOrderStatus: state.updateOrderStatus.copyWith(
              isLoading: false,
              failure: result.failure,
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
      onReportResult: (result) {
        switch (result) {
          case Success<ReportDriverLocationEntity>():
            emit(
              state.copyWith(
                reportDriverLocation: state.reportDriverLocation.copyWith(
                  isLoading: false,
                  data: result.data,
                  clearFailure: true,
                ),
              ),
            );

          case Error<ReportDriverLocationEntity>():
            // Background reporting: update state without showing a UI event.
            emit(
              state.copyWith(
                reportDriverLocation: state.reportDriverLocation.copyWith(
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

  bool _shouldTrackLocation(OrderStatus? status) {
    if (status == null) return false;

    switch (status) {
      case OrderStatus.pickedUp:
      case OrderStatus.picked:
      case OrderStatus.onTheWay:
      case OrderStatus.outForDelivery:
      case OrderStatus.inProgress:
        return true;

      case OrderStatus.pending:
      case OrderStatus.accepted:
      case OrderStatus.assigned:
      case OrderStatus.arrived:
        return false;
    }
  }

  bool _isTerminalStatus(String normalizedStatus) {
    return normalizedStatus == 'arrived' ||
        normalizedStatus == 'delivered' ||
        normalizedStatus == 'awaitingdeliveryconfirmation' ||
        normalizedStatus == 'cancelled';
  }

  bool _isInTransitStatus(String normalizedStatus) {
    return normalizedStatus == 'ontheway' ||
        normalizedStatus == 'outfordelivery' ||
        normalizedStatus == 'pickedup' ||
        normalizedStatus == 'inprogress';
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
