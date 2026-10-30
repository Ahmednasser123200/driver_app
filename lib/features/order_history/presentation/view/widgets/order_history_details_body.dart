import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_history_details_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_history_details_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_history_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../config/errors/app_failure.dart';
import 'order_history_details_sections.dart';
import 'order_widgets.dart';

class OrderHistoryDetailsBody extends StatelessWidget {
  const OrderHistoryDetailsBody({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context
          .read<OrderHistoryDetailsCubit>()
          .doIntent(GetOrderHistoryDetailsEvent(orderId: orderId)),
      child: BlocBuilder<OrderHistoryDetailsCubit, OrderHistoryDetailsState>(
        builder: (context, state) => OrderHistoryDetailsStateView(state: state),
      ),
    );
  }
}

class OrderHistoryDetailsStateView extends StatelessWidget {
  const OrderHistoryDetailsStateView({super.key, required this.state});

  final OrderHistoryDetailsState state;

  @override
  Widget build(BuildContext context) {
    final details = state.orderDetails.data;
    if (details != null) return OrderHistoryDetailsContent(details: details);
    final failure = state.failure;
    if (failure != null) return ErrorMessageView(failure: failure);
    if (state.orderDetails.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return const ErrorMessageView(failure: NotFoundFailure());
  }
}

class OrderHistoryDetailsContent extends StatelessWidget {
  const OrderHistoryDetailsContent({super.key, required this.details});
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
