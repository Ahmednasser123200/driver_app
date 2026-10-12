
import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:driver_app/features/order_details/domain/params/update_order_status_params.dart';
import 'package:driver_app/features/order_details/domain/usecases/get_driver_order_details_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/update_order_status_use_case.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_event.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class OrderDetailsCubit
    extends BaseCubit<OrderDetailsState, OrderDetailsUiEvent> {
  OrderDetailsCubit({
    required this._getDriverOrderDetailsUseCase,
    required this._updateOrderStatusUseCase,
  }) : super(const OrderDetailsState());

  final GetDriverOrderDetailsUseCase _getDriverOrderDetailsUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;

  Future<void> doEvent(OrderDetailsEvent event) async {
    switch (event) {
      case GetDriverOrderDetailsEvent():
        await _getOrderDetails(event.orderId);

      case UpdateOrderStatusEvent():
        await _updateOrderStatus(event.orderId, event.newStatus);
    }
  }

  Future<void> _getOrderDetails(String orderId) async {
    emit(
      state.copyWith(
        orderDetails: const BaseState<DriverOrderDetailsEntity>(
          isLoading: true,
        ),
      ),
    );

    final result = await _getDriverOrderDetailsUseCase.execute(orderId);

    switch (result) {
      case Success<DriverOrderDetailsEntity>():
        emit(
          state.copyWith(
            orderDetails: BaseState<DriverOrderDetailsEntity>(
              isLoading: false,
              data: result.data,
            ),
          ),
        );

      case Error<DriverOrderDetailsEntity>():
        emit(
          state.copyWith(
            orderDetails: BaseState<DriverOrderDetailsEntity>(
              isLoading: false,
              errorMessage: result.failure.toString(),
            ),
          ),
        );

        _reportFailure(result.failure);
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
            updateOrderStatus: state.updateOrderStatus.copyWith(
              isLoading: false,
              data: result.data,
              errorMessage: '',
            ),
          ),
        );

        emitEvent(const ShowOrderStatusUpdated());

      case Error<UpdateOrderStatusEntity>():
        emit(
          state.copyWith(
            updateOrderStatus: state.updateOrderStatus.copyWith(
              isLoading: false,
              errorMessage: result.failure.toString(),
            ),
          ),
        );

        _reportFailure(result.failure);
    }
  }

  void _reportFailure(AppFailure failure) {
    emitEvent(ShowOrderDetailsFailure(failure));
  }
}

