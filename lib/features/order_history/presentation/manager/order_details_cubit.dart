
import 'package:injectable/injectable.dart';

import '../../../../config/base/base_cubit.dart';
import '../../../../config/base/base_response.dart';
import '../../../../config/base/base_state.dart';
import '../../../../config/base/base_ui_event.dart';
import '../../../../config/errors/app_failure.dart';
import '../../domain/entities/order_history_entities.dart';
import '../../domain/use_case/get_order_details_use_case.dart';
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
    _emitLoading();
    final result = await _getOrderDetailsUseCase.execute(orderId: orderId);
    if (isClosed) return;
    switch (result) {
      case Success<OrderHistoryDetailsEntity>(:final data):
        _emitLoaded(data);
      case Error<OrderHistoryDetailsEntity>(:final failure):
        _emitFailure(failure);
    }
  }

  void _emitLoading() {
    emit(
      OrderDetailsState(
        orderDetails: BaseState(
          isLoading: true,
          data: state.orderDetails.data,
        ),
      ),
    );
  }

  void _emitLoaded(OrderHistoryDetailsEntity details) {
    emit(OrderDetailsState(orderDetails: BaseState(data: details)));
  }

  void _emitFailure(AppFailure failure) {
    emit(
      OrderDetailsState(
        orderDetails: BaseState(data: state.orderDetails.data),
        failure: failure,
      ),
    );
    emitEvent(ShowFailure(failure));
  }
}
