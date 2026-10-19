import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
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
      case RefreshActiveOrderEvent():
        await _refreshActiveOrderId();
      case AcceptOrderEvent():
        await _acceptOrder(event.orderId);
      case OpenOrderDetailsEvent():
        _openOrderDetails(event.orderId);
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
        await _refreshActiveOrderId();
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
    if (state.acceptOrderId.isNotEmpty) return;
    if (orderId.trim().isEmpty) {
      emitEvent(const ShowFailureMessage(BadRequestFailure()));
      return;
    }

    final activeOrderId = state.activeOrderId;
    // A delivery of this driver is already running. Their own order simply
    // opens its details; any other order is refused locally with an explanation
    // instead of being sent to the backend only to be rejected there.
    if (activeOrderId != null && activeOrderId.isNotEmpty) {
      if (activeOrderId == orderId) {
        _openOrderDetails(orderId);
      } else {
        emitEvent(const ShowFailureMessage(AlreadyActiveOrderFailure()));
      }
      return;
    }

    emit(state.copyWith(acceptOrderId: orderId));
    var result = await _acceptOrderUseCase.call(orderId);
    if (isClosed) return;
    switch (result) {
      case Success<void>():
        emit(state.copyWith(acceptOrderId: '', activeOrderId: orderId));
        emitEvent(ShowSuccessMessage(AppSuccessEnum.orderAccepted));
        emitEvent(NavigateRepalceTo(Routes.orderDetails, arguments: orderId));
      case Error<void>():
        emit(state.copyWith(acceptOrderId: ''));
        emitEvent(ShowFailureMessage(result.failure));
        // A rejected accept usually means a delivery is already running, so
        // refresh which order is the driver's own (the list stays as-is).
        await _refreshActiveOrderId();
    }
  }

  /// Opens the details of the order the driver is already assigned to, using
  /// that order's own id (never a shared/global fallback).
  void _openOrderDetails(String orderId) {
    if (orderId.trim().isEmpty) {
      emitEvent(const ShowFailureMessage(BadRequestFailure()));
      return;
    }
    emitEvent(NavigateTo(Routes.orderDetails, arguments: orderId));
  }

  /// Best-effort lookup of the driver's current order so the list can tell it
  /// apart from the others (its card opens the details, the rest explain that a
  /// delivery is already running).
  ///
  /// Only a successful response resolves the state: the backend contract
  /// answers 200 with an order id, or 200 with a null/empty id when the driver
  /// has no active delivery. A failed request (network, 5xx, ...) is not proof
  /// of absence, so the previously known value is kept — or the state stays
  /// unresolved — and the accept request is still sent to the backend, which
  /// remains the source of truth. The lookup itself never surfaces an error to
  /// the user.
  Future<void> _refreshActiveOrderId() async {
    final result = await _acceptOrderUseCase.getActiveOrderId();
    if (isClosed) return;
    switch (result) {
      case Success<String>(:final data):
        final activeOrderId = data.trim();
        if (activeOrderId == state.activeOrderId) return;
        emit(state.copyWith(activeOrderId: activeOrderId));
      case Error<String>():
        return;
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
    final latest = state.getAvailableOrdersState.data;
    if (latest == null) {
      emit(state.copyWith(isLoadingMore: false));
      return;
    }
    switch (result) {
      case Success<AvailableOrders>():
        var merged = AvailableOrders(
          items: [...latest.items, ...result.data.items],
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
