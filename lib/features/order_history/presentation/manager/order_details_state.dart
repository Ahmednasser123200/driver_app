import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:equatable/equatable.dart';

class OrderDetailsState extends Equatable {
  final BaseState<OrderHistoryDetailsEntity> orderDetails;

  const OrderDetailsState({
    this.orderDetails = const BaseState(),
  });

  OrderDetailsState copyWith({
    BaseState<OrderHistoryDetailsEntity>? orderDetails,
  }) {
    return OrderDetailsState(
      orderDetails: orderDetails ?? this.orderDetails,
    );
  }

  @override
  List<Object?> get props => [orderDetails];
}