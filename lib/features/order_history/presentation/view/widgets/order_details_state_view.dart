import 'package:driver_app/features/order_history/presentation/manager/order_details_state.dart';
import 'package:flutter/material.dart';

import 'error_message_view.dart';
import 'order_details_content.dart';

class OrderDetailsStateView extends StatelessWidget {
  const OrderDetailsStateView({super.key, required this.state});

  final OrderDetailsState state;

  @override
  Widget build(BuildContext context) {
    final details = state.orderDetails.data;
    if (details != null) return OrderDetailsContent(details: details);
    final failure = state.failure;
    if (failure != null) return ErrorMessageView(failure: failure);
    return const Center(child: CircularProgressIndicator());
  }
}
