import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/features/home/domain/entities/available_orders.dart';
import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final BaseState<AvailableOrders> getAvailableOrdersState;
  final Set<String> acceptOrderId;
  const HomeState({
    this.getAvailableOrdersState = const BaseState(),
      this.acceptOrderId = const {},
  });


  HomeState copyWith({
    BaseState<AvailableOrders>? getAvailableOrdersState,
    Set<String>? acceptOrderId
  }) {
    return HomeState(
      getAvailableOrdersState: getAvailableOrdersState ?? this.getAvailableOrdersState,
      acceptOrderId:  acceptOrderId ?? this.acceptOrderId
    );
  }

  @override
  List<Object?> get props => [getAvailableOrdersState, acceptOrderId];
}
