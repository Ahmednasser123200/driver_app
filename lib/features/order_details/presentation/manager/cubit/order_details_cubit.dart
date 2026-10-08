
import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
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
import 'package:injectable/injectable.dart';

@injectable
class OrderDetailsCubit extends BaseCubit<OrderDetailsState, BaseUiEvent> {
  final GetDriverOrderDetailsUseCase _getDriverOrderDetailsUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  final ReportDriverLocationUseCase _reportDriverLocationUseCase;

  OrderDetailsCubit({
    required this._getDriverOrderDetailsUseCase,
    required this._updateOrderStatusUseCase,
    required this._reportDriverLocationUseCase,
  }) : super(const OrderDetailsState());

  void doEvent(OrderDetailsEvent event) {
    switch (event) {
      case GetDriverOrderDetailsEvent():
        _getOrderDetails(event.orderId);

      case ReportDriverLocationEvent():
        _reportDriverLocation(
          event.lat,
          event.lng,
          event.recordedAt,
        );

      case UpdateOrderStatusEvent():
        _updateOrderStatus(
          event.orderId,
          event.newStatus,
        );
    }
  }

  Future<void> _getOrderDetails(String orderId) async {
    emit(
      state.copyWith(
        orderDetails: state.orderDetails.copyWith(
          isLoading: true,
          errorMessage: '',
        ),
      ),
    );

    final result =
        await _getDriverOrderDetailsUseCase.execute(orderId);

    switch (result) {
      case Success<DriverOrderDetailsEntity>():
        emit(
          state.copyWith(
            orderDetails: state.orderDetails.copyWith(
              isLoading: false,
              data: result.data,
              errorMessage: '',
            ),
          ),
        );

      case Error<DriverOrderDetailsEntity>():
        emit(
          state.copyWith(
            orderDetails: state.orderDetails.copyWith(
              isLoading: false,
            ),
          ),
        );

        emitEvent(
          ShowFailureMessage(result.failure),
        );
    }
  }

  Future<void> _updateOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    emit(
      state.copyWith(
        updateOrderStatus: state.updateOrderStatus.copyWith(
          isLoading: true,
          errorMessage: '',
        ),
      ),
    );

    final result = await _updateOrderStatusUseCase.execute(
      UpdateOrderStatusParams(
        orderId: orderId,
        newStatus: newStatus,
      ),
    );

    switch (result) {
      case Success<UpdateOrderStatusEntity>():
        emit(
          state.copyWith(
            updateOrderStatus:
                state.updateOrderStatus.copyWith(
              isLoading: false,
              data: result.data,
              errorMessage: '',
            ),
          ),
        );

        emitEvent(
          const ShowOrderStatusUpdated(),
        );

      case Error<UpdateOrderStatusEntity>():
        emit(
          state.copyWith(
            updateOrderStatus:
                state.updateOrderStatus.copyWith(
              isLoading: false,
            ),
          ),
        );

        emitEvent(
          ShowFailureMessage(result.failure),
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
        reportDriverLocation:
            state.reportDriverLocation.copyWith(
          isLoading: true,
          errorMessage: '',
        ),
      ),
    );

    final result =
        await _reportDriverLocationUseCase.execute(
      ReportDriverLocationParams(
        lat: lat,
        lng: lng,
        recordedAt: recordedAt,
      ),
    );

    switch (result) {
      case Success<ReportDriverLocationEntity>():
        emit(
          state.copyWith(
            reportDriverLocation:
                state.reportDriverLocation.copyWith(
              isLoading: false,
              data: result.data,
              errorMessage: '',
            ),
          ),
        );

      case Error<ReportDriverLocationEntity>():
        emit(
          state.copyWith(
            reportDriverLocation:
                state.reportDriverLocation.copyWith(
              isLoading: false,
            ),
          ),
        );

        emitEvent(
          ShowFailureMessage(result.failure),
        );
    }
  }
}

