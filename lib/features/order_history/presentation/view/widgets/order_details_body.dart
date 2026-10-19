import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../manager/order_details_cubit.dart';
import '../../manager/order_details_event.dart';
import '../../manager/order_details_state.dart';
import 'order_details_state_view.dart';

class OrderDetailsBody extends StatelessWidget {
  const OrderDetailsBody({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context
          .read<OrderDetailsCubit>()
          .doIntent(GetOrderDetailsEvent(orderId: orderId)),
      child: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
        builder: (context, state) => OrderDetailsStateView(state: state),
      ),
    );
  }
}
