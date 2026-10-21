import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'order_details_sections.dart';
import 'order_widgets.dart';

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

class OrderDetailsContent extends StatelessWidget {
  const OrderDetailsContent({super.key, required this.details});
  final OrderHistoryDetailsEntity details;

  @override
  Widget build(BuildContext context) {
    final sectionGap = SizedBox(height: OrderHistoryDimens.paddingXxl.h);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(OrderHistoryDimens.paddingXl.w),
      children: [
        OrderDetailsHeader(status: details.status, orderId: details.orderId),
        sectionGap,
        PickupSection(store: details.store),
        sectionGap,
        UserSection(user: details.user),
        sectionGap,
        ItemsSection(items: details.items),
        SizedBox(height: OrderHistoryDimens.paddingM.h),
        SummarySection(details: details),
      ],
    );
  }
}
