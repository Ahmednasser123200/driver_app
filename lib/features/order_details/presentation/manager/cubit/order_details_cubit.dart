import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:driver_app/features/order_details/domain/params/report_driver_location_params.dart';
import 'package:driver_app/features/order_details/domain/params/update_order_status_params.dart';
import 'package:driver_app/features/order_details/domain/usecases/get_driver_order_details_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/report_driver_location_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/update_order_status_use_case.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_event.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_state.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  final GetDriverOrderDetailsUseCase _getDriverOrderDetailsUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  final ReportDriverLocationUseCase _reportDriverLocationUseCase;
  final AppLocalizations _l10n;

  OrderDetailsCubit({
    required this._getDriverOrderDetailsUseCase,
    required this._updateOrderStatusUseCase,
    required this._reportDriverLocationUseCase,
    required this._l10n,
  }) : super(const OrderDetailsState());

  void doEvent(OrderDetailsEvent event) {
    switch (event) {
      case GetDriverOrderDetailsEvent():
        _getOrderDetails(event.orderId);
      case ReportDriverLocationEvent():
        _reportDriverLocation(event.lat, event.lng, event.recordedAt);
      case UpdateOrderStatusEvent():
        _updateOrderStatus(event.orderId, event.newStatus);
    }
  }

  Future<void> _getOrderDetails(String orderId) async {
    emit(state.copyWith(isLoading: true, errorMessage: '', data: null));

    final result = await _getDriverOrderDetailsUseCase.execute(orderId);

    switch (result) {
      case Success<DriverOrderDetailsEntity>():
        emit(state.copyWith(isLoading: false, data: result.data));
      case Error<DriverOrderDetailsEntity>():
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: mapAppFailureToMessage(result.failure, _l10n),
          ),
        );
    }
  }

  Future<void> _reportDriverLocation(
    double lat,
    double lng,
    String recordedAt,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: '',
        reportLocationSuccess: false,
      ),
    );

    final result = await _reportDriverLocationUseCase.execute(
      ReportDriverLocationParams(lat: lat, lng: lng, recordedAt: recordedAt),
    );

    switch (result) {
      case Success<ReportDriverLocationEntity>():
        emit(state.copyWith(isLoading: false, reportLocationSuccess: true));
      case Error<ReportDriverLocationEntity>():
        emit(
          state.copyWith(
            isLoading: false,
            reportLocationSuccess: false,
            errorMessage: mapAppFailureToMessage(result.failure, _l10n),
          ),
        );
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: '',
        updateStatusSuccess: false,
      ),
    );

    final result = await _updateOrderStatusUseCase.execute(
      UpdateOrderStatusParams(orderId: orderId, newStatus: newStatus),
    );

    switch (result) {
      case Success<UpdateOrderStatusEntity>():
        emit(state.copyWith(isLoading: false, updateStatusSuccess: true));
      case Error<UpdateOrderStatusEntity>():
        emit(
          state.copyWith(
            isLoading: false,
            updateStatusSuccess: false,
            errorMessage: mapAppFailureToMessage(result.failure, _l10n),
          ),
        );
    }
  }
}
