import 'package:driver_app/core/shared/widgets/base_ui_event_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/base/base_ui_event.dart';
import '../../../../config/di/di.dart';
import '../../../../core/constants/app_strings/app_strings.dart';
import '../../../../core/themes/app_colors/app_colors.dart';
import '../manager/orders_cubit.dart';
import '../manager/orders_event.dart';
import '../manager/orders_state.dart';
import 'widgets/order_widgets.dart';
import 'widgets/orders_body.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrdersCubit>()..doIntent(LoadOrdersEvent()),
      child: BaseUiEventListener<OrdersCubit, OrdersState, BaseUiEvent>(
        child: const Scaffold(
          backgroundColor: AppColors.surface,
          appBar: OrderHistoryAppBar(
            title: AppStrings.myOrders,
            showBack: false,
          ),
          body: OrdersBody(),
        ),
      ),
    );
  }
}
