import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:flutter/material.dart';

import 'error_message_view.dart';
import 'orders_content.dart';

class OrdersStateView extends StatelessWidget {
  const OrdersStateView({super.key, required this.state});

  final OrdersState state;

  @override
  Widget build(BuildContext context) {
    if (state.ordersListState.data != null) return OrdersContent(state: state);
    final failure = state.failure;
    if (failure != null) return ErrorMessageView(failure: failure);
    return const Center(child: CircularProgressIndicator());
  }
}
