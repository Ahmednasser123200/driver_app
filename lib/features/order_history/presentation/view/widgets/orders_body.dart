import 'package:driver_app/features/order_history/presentation/manager/orders_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'order_details_body.dart';
import 'orders_content.dart';

class OrdersBody extends StatelessWidget {
  const OrdersBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        final listState = state.ordersListState;
        if (listState.data != null) return OrdersContent(state: state);
        if (listState.errorMessage.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return OrderDetailsError(
          message: listState.errorMessage,
          onRetry: () =>
              context.read<OrdersCubit>().doIntent(LoadOrdersEvent()),
        );
      },
    );
  }
}