import 'package:equatable/equatable.dart';

import '../../../../config/base/base_state.dart';
import '../../../../config/errors/app_failure.dart';
import '../../domain/entities/order_history_entities.dart';

class OrderDetailsState extends Equatable {
  final BaseState<OrderHistoryDetailsEntity> orderDetails;
  final AppFailure? failure;

  const OrderDetailsState({
    this.orderDetails = const BaseState(),
    this.failure,
  });

  @override
  List<Object?> get props => [orderDetails, failure];
}