import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../../../core/constants/app_strings/app_strings.dart';
import 'common/section_title.dart';
import 'orders_list_area.dart';
import 'orders_stats_row.dart';

class OrdersContent extends StatelessWidget {
  const OrdersContent({super.key, required this.state});
  final OrdersState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(OrderHistoryDimens.paddingXl.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrdersStatsRow(
            data: state.ordersListState.data ?? const OrdersDataState(),
            selected: state.statusFilter,
            onToggle: (status) => _toggleFilter(context, status),
          ),
          SizedBox(height: OrderHistoryDimens.paddingXxl.h),
          const SectionTitle(text: AppStrings.recentOrders),
          SizedBox(height: OrderHistoryDimens.paddingL.h),
          Expanded(child: OrdersListArea(state: state)),
        ],
      ),
    );
  }

  void _toggleFilter(BuildContext context, OrderStatus status) {
    context.read<OrdersCubit>().doIntent(ToggleStatusFilterEvent(status));
  }
}
