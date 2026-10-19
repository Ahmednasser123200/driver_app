import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/domain/entities/pagination_entities.dart';
import 'package:driver_app/features/order_history/domain/use_case/get_orders_use_case..dart';
import 'package:injectable/injectable.dart';

import 'orders_event.dart';
import 'orders_state.dart';

@injectable
class OrdersCubit extends BaseCubit<OrdersState, BaseUiEvent> {
  static const int _pageSize = 10;

  final GetOrdersUseCase _getOrdersUseCase;

  OrdersCubit(this._getOrdersUseCase) : super(const OrdersState());

  Future<void> doIntent(OrdersEvent event) async {
    switch (event) {
      case LoadOrdersEvent():
        await _loadPage(1, refresh: true);
      case LoadMoreOrdersEvent():
        await _loadMore();
      case ToggleStatusFilterEvent():
        await _toggleFilter(event.status);
    }
  }

  Future<void> _toggleFilter(OrderStatus status) async {
    final next = state.statusFilter == status ? null : status;
    emit(state.withFilter(next));
    await _loadMoreIfNeeded();
  }

  Future<void> _loadMore() async {
    final listState = state.ordersListState;
    final pagination = listState.data?.pagination;
    if (listState.isLoading || pagination == null) return;
    if (!pagination.hasNextPage) return;
    await _loadPage(pagination.page + 1);
  }

  Future<void> _loadMoreIfNeeded() async {
    final pagination = state.ordersListState.data?.pagination;
    final hasNext = pagination?.hasNextPage ?? false;
    if (hasNext && state.visibleOrders.length < _pageSize) await _loadMore();
  }

  Future<void> _loadPage(int page, {bool refresh = false}) async {
    final previous = state.ordersListState.data;
    final kept = _keptOrders(refresh);
    _emitLoading(previous);
    final result = await _getOrdersUseCase.execute(
      page: page,
      pageSize: _pageSize,
    );
    if (isClosed) return;
    switch (result) {
      case Success<PaginatedEntity<OrderHistoryEntity>>(:final data):
        _emitLoaded(kept, data);
        await _loadMoreIfNeeded();
      case Error<PaginatedEntity<OrderHistoryEntity>>(:final failure):
        _emitError(previous, failure);
    }
  }

  List<OrderHistoryEntity> _keptOrders(bool refresh) {
    if (refresh) return const [];
    return state.ordersListState.data?.orders ?? const [];
  }

  void _emitLoading(OrdersDataState? data) {
    emit(
      state.copyWith(
        ordersListState: BaseState(isLoading: true, data: data),
      ),
    );
  }

  void _emitLoaded(
      List<OrderHistoryEntity> kept,
      PaginatedEntity<OrderHistoryEntity> page,
      ) {
    final orders = [...kept, ...page.items];
    emit(
      state.copyWith(
        ordersListState: BaseState(
          isLoading: false,
          data: OrdersDataState(
            orders: orders,
            pagination: page.pagination,
            completedCount: _count(orders, OrderStatus.completed),
            cancelledCount: _count(orders, OrderStatus.cancelled),
          ),
        ),
      ),
    );
  }

  void _emitError(OrdersDataState? data, AppFailure failure) {
    final message = failure.toString();
    emit(
      state.copyWith(
        ordersListState: BaseState(
          isLoading: false,
          errorMessage: message,
          data: data,
        ),
      ),
    );
    emitEvent(ShowErrorMessage(message));
  }

  int _count(List<OrderHistoryEntity> orders, OrderStatus status) {
    return orders.where((order) => order.status == status).length;
  }
}