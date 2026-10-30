import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/base/base_ui_event.dart';
import '../../../../config/di/di.dart';
import '../../../../core/shared/widgets/base_ui_event_listener.dart';
import '../../../../core/themes/app_colors/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../manager/order_history_details_cubit.dart';
import '../manager/order_history_details_event.dart';
import '../manager/order_history_details_state.dart';
import 'widgets/order_history_details_body.dart';
import 'widgets/order_widgets.dart';

class OrderHistoryDetailsView extends StatelessWidget {
  const OrderHistoryDetailsView({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<OrderHistoryDetailsCubit>()
            ..doIntent(GetOrderHistoryDetailsEvent(orderId: orderId)),
      child:
          BaseUiEventListener<
              OrderHistoryDetailsCubit,
              OrderHistoryDetailsState,
            BaseUiEvent
          >(
            child: Scaffold(
              backgroundColor: AppColors.surface,
              appBar: OrderHistoryAppBar(
                title: AppLocalizations.of(context)!.orderDetails,
              ),
              body: OrderHistoryDetailsBody(orderId: orderId),
            ),
          ),
    );
  }
}
