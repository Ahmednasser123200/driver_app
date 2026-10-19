import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/features/home/domain/entities/available_orders.dart';
import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  /// Sentinel used by [copyWith] to tell "leave unchanged" from an explicit
  /// assignment of `null`.
  static const Object _undefined = Object();

  final BaseState<AvailableOrders> getAvailableOrdersState;
  final String acceptOrderId;

  /// The order the driver is currently assigned to.
  ///
  /// - `null` — not known yet (still loading, or the lookup failed): every
  ///   Accept button stays disabled so no order can be opened by mistake.
  /// - `''` — the backend confirmed the driver has no active delivery.
  /// - non-empty — the id of the driver's own order.
  final String? activeOrderId;
  final bool isLoadingMore;
  const HomeState({
    this.getAvailableOrdersState = const BaseState(),
    this.acceptOrderId = '',
    this.activeOrderId,
    this.isLoadingMore = false,
  });

  HomeState copyWith({
    BaseState<AvailableOrders>? getAvailableOrdersState,
    String? acceptOrderId,
    Object? activeOrderId = _undefined,
    bool? isLoadingMore,
  }) {
    return HomeState(
      getAvailableOrdersState:
          getAvailableOrdersState ?? this.getAvailableOrdersState,
      acceptOrderId: acceptOrderId ?? this.acceptOrderId,
      activeOrderId: identical(activeOrderId, _undefined)
          ? this.activeOrderId
          : activeOrderId as String?,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    getAvailableOrdersState,
    acceptOrderId,
    activeOrderId,
    isLoadingMore,
  ];
}
