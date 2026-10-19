import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/base/base_ui_event.dart';
import '../../../../config/di/di.dart';
import '../../../../core/constants/app_strings/app_strings.dart';
import '../../../../core/shared/widgets/base_ui_event_listener.dart';
import '../../../../core/themes/app_colors/app_colors.dart';
import '../manager/order_details_cubit.dart';
import '../manager/order_details_event.dart';
import '../manager/order_details_state.dart';
import 'widgets/order_details_body.dart';
import 'widgets/order_history_app_bar.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderDetailsCubit>()
        ..doIntent(GetOrderDetailsEvent(orderId: orderId)),
      child: BaseUiEventListener<OrderDetailsCubit, OrderDetailsState,
          BaseUiEvent>(
        child: Scaffold(
          backgroundColor: AppColors.surface,
          appBar: const OrderHistoryAppBar(title: AppStrings.orderDetails),
          body: OrderDetailsBody(orderId: orderId),
        ),
      ),
    );
  }
}