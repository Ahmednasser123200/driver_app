import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/features/home/domain/entities/available_orders.dart';
import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final BaseState<AvailableOrders> getAvailableOrdersState;
  final Set<String> acceptOrderId;
  final bool isLoadingMore;
  const HomeState({
    this.getAvailableOrdersState = const BaseState(),
    this.acceptOrderId = const {},
    this.isLoadingMore = false,
  });

  HomeState copyWith({
    BaseState<AvailableOrders>? getAvailableOrdersState,
    Set<String>? acceptOrderId,
    bool? isLoadingMore,
  }) {
    return HomeState(
      getAvailableOrdersState:
          getAvailableOrdersState ?? this.getAvailableOrdersState,
      acceptOrderId: acceptOrderId ?? this.acceptOrderId,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [getAvailableOrdersState, acceptOrderId , isLoadingMore];
}
