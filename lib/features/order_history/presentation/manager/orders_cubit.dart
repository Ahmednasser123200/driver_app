import 'package:injectable/injectable.dart';

import '../../../../config/base/base_cubit.dart';
import '../../../../config/base/base_response.dart';
import '../../../../config/base/base_state.dart';
import '../../../../config/base/base_ui_event.dart';
import '../../../../config/errors/app_failure.dart';
import '../../domain/entities/order_history_entities.dart';
import '../../domain/entities/pagination_entities.dart';
import '../../domain/use_case/get_orders_use_case.dart';
import '../constants/order_history_constants.dart';
import 'orders_event.dart';
import 'orders_state.dart';
import 'dart:async';

@injectable
class OrdersCubit extends BaseCubit<OrdersState, BaseUiEvent> {
  final GetOrdersUseCase _getOrdersUseCase;

  int _requestId = 0;
  int _countId = 0;

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
    final needsMore =
        state.visibleOrders.length < OrderHistoryConstants.pageSize;
    if (hasNext && needsMore) await _loadMore();
  }
  Future<void> _countRemainingPages(bool hasNext) async {
    final countId = ++_countId;
    var page = 2;
    while (hasNext) {
      final result = await _getOrdersUseCase.execute(
        page: page,
        pageSize: OrderHistoryConstants.pageSize,
      );
      if (isClosed || countId != _countId) return;
      if (result is! Success<PaginatedEntity<OrderHistoryEntity>>) return;
      _addCounts(result.data.items);
      hasNext = result.data.pagination.hasNextPage;
      page++;
    }
  }

  void _addCounts(List<OrderHistoryEntity> items) {
    final data = state.ordersListState.data;
    if (data == null) return;
    emit(
      state.copyWith(
        ordersListState: state.ordersListState.copyWith(
          data: data.copyWith(
            completedCount:
            data.completedCount + _count(items, OrderStatus.completed),
            cancelledCount:
            data.cancelledCount + _count(items, OrderStatus.cancelled),
          ),
        ),
        failure: state.failure,
      ),
    );
  }

  Future<void> _loadPage(int page, {bool refresh = false}) async {
    final requestId = ++_requestId;
    if (refresh) _countId++;
    final previous = state.ordersListState.data;
    final kept = _keptOrders(refresh);
    _emitLoading(previous);
    final result = await _getOrdersUseCase.execute(
      page: page,
      pageSize: OrderHistoryConstants.pageSize,
    );
    if (isClosed || requestId != _requestId) return;
    switch (result) {
      case Success<PaginatedEntity<OrderHistoryEntity>>(:final data):
        _emitLoaded(kept, data);
        if (data.pagination.page == 1) {
          unawaited(_countRemainingPages(data.pagination.hasNextPage));
        }
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

    final currentData = state.ordersListState.data;

    final completedCount = page.pagination.page == 1
        ? _count(page.items, OrderStatus.completed)
        : currentData?.completedCount ?? 0;

    final cancelledCount = page.pagination.page == 1
        ? _count(page.items, OrderStatus.cancelled)
        : currentData?.cancelledCount ?? 0;

    emit(
      state.copyWith(
        ordersListState: BaseState(
          isLoading: false,
          data: OrdersDataState(
            orders: orders,
            pagination: page.pagination,
            completedCount: completedCount,
            cancelledCount: cancelledCount,
          ),
        ),
      ),
    );
  }

  void _emitError(OrdersDataState? data, AppFailure failure) {
    emit(
      state.copyWith(
        ordersListState: BaseState(isLoading: false, data: data),
        failure: failure,
      ),
    );
    emitEvent(ShowFailure(failure));
  }

  int _count(List<OrderHistoryEntity> orders, OrderStatus status) {
    return orders.where((order) => order.status == status).length;
  }
}
