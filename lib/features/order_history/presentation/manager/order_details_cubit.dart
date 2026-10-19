import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/domain/use_case/get_order_details_use_case.dart';
import 'package:injectable/injectable.dart';

import 'order_details_event.dart';
import 'order_details_state.dart';

@injectable
class OrderDetailsCubit extends BaseCubit<OrderDetailsState, BaseUiEvent> {
  final GetOrderDetailsUseCase _getOrderDetailsUseCase;

  OrderDetailsCubit(this._getOrderDetailsUseCase)
      : super(const OrderDetailsState());

  Future<void> doIntent(OrderDetailsEvent event) async {
    switch (event) {
      case GetOrderDetailsEvent():
        await _getOrderDetails(event.orderId);
    }
  }

  Future<void> _getOrderDetails(String orderId) async {
    emit(
      state.copyWith(
        orderDetails: const BaseState(isLoading: true),
      ),
    );

    final result = await _getOrderDetailsUseCase.execute(orderId: orderId);

    if (isClosed) return;

    switch (result) {
      case Success<OrderHistoryDetailsEntity>():
        emit(
          state.copyWith(
            orderDetails: BaseState(
              isLoading: false,
              data: result.data,
            ),
          ),
        );

      case Error<OrderHistoryDetailsEntity>():
        emit(
          state.copyWith(
            orderDetails: BaseState(
              isLoading: false,
              errorMessage: result.failure.toString(),
            ),
          ),
        );
        emitEvent(ShowErrorMessage(result.failure.toString()));
    }
  }
}