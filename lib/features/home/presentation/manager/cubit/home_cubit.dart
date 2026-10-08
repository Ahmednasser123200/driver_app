import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/localization/handle_success_text.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/features/home/domain/entities/available_orders.dart';
import 'package:driver_app/features/home/domain/usecases/accept_order_use_case.dart';
import 'package:driver_app/features/home/domain/usecases/get_available_orders_use_case.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_event.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeCubit extends BaseCubit<HomeState, BaseUiEvent> {
  HomeCubit({
    required this._acceptOrderUseCase,
    required this._getAvailableOrdersUseCase,
  }) : super(HomeState());
  final GetAvailableOrdersUseCase _getAvailableOrdersUseCase;
  final AcceptOrderUseCase _acceptOrderUseCase;

  Future<void> doEvent(HomeEvent event) async {
    switch (event) {
      case GetAvailableOrdersEvent():
        await _getAvailableOrders();
      case AcceptOrderEvent():
        await _acceptOrder(event.orderId);
      case LoadMoreOrdersEvent():
        await _loadMoreOrders();
    }
  }

  Future<void> _getAvailableOrders() async {
    emit(state.copyWith(getAvailableOrdersState: BaseState(isLoading: true)));
    var result = await _getAvailableOrdersUseCase.call();
    if (isClosed) return;
    switch (result) {
      case Success<AvailableOrders>():
        emit(
          state.copyWith(
            getAvailableOrdersState: BaseState(
              data: result.data,
              isLoading: false,
            ),
          ),
        );
      case Error<AvailableOrders>():
        emit(
          state.copyWith(
            getAvailableOrdersState: BaseState(
              isLoading: false,
              errorMessage: result.failure,
            ),
          ),
        );
        emitEvent(ShowFailureMessage(result.failure));
    }
  }

  Future<void> _acceptOrder(String orderId) async {
    emit(state.copyWith(acceptOrderId: {...state.acceptOrderId, orderId}));
    var result = await _acceptOrderUseCase.call(orderId);
    if (isClosed) return;
    emit(
      state.copyWith(acceptOrderId: {...state.acceptOrderId}..remove(orderId)),
    );
    switch (result) {
      case Success<void>():
        emitEvent(ShowSuccessMessage(AppMessage.orderAccepted));
        emitEvent(
          NavigateTo(Routes.orderDetails, arguments: {'orderId': orderId}),
        );
      case Error<void>():
        emitEvent(ShowFailureMessage(result.failure));
    }
  }

  Future<void> _loadMoreOrders() async {
    final current = state.getAvailableOrdersState.data;
    if (current == null) return;
    if (!current.pagination.hasNextPage) return;
    if (state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    var result = await _getAvailableOrdersUseCase.call(
      page: current.pagination.page + 1,
    );
    if (isClosed) return;
    switch (result) {
      case Success<AvailableOrders>():
        var merged = AvailableOrders(
          items: [...current.items, ...result.data.items],
          pagination: result.data.pagination,
        );
        emit(
          state.copyWith(
            isLoadingMore: false,
            getAvailableOrdersState: BaseState(data: merged),
          ),
        );
      case Error<AvailableOrders>():
        emit(state.copyWith(isLoadingMore: false));
        emitEvent(ShowFailureMessage(result.failure));
    }
  }
}
