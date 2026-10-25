import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/config/localization/handle_success_text.dart';
import 'package:driver_app/core/shared/widgets/base_ui_event_listener.dart';
import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_cubit.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_event.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_state.dart';
import 'package:driver_app/features/order_details/presentation/view/order_details_body.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../utils/order_status_helper.dart';

class OrderDetailsView extends StatefulWidget {
  final String orderId;

  const OrderDetailsView({super.key, required this.orderId});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<OrderDetailsCubit>().doEvent(
        GetDriverOrderDetailsEvent(orderId: widget.orderId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseUiEventListener<
      OrderDetailsCubit,
      OrderDetailsState,
      BaseUiEvent
    >(
      onEvent: (context, event) {
        final l10n = AppLocalizations.of(context)!;
        switch (event) {
          case ShowSuccessMessage():
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(handleSuccessText(l10n, event.message)),
                backgroundColor: Colors.green,
              ),
            );
          case ShowFailureMessage():
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(mapAppFailureToMessage(event.failure, l10n)),
                backgroundColor: Colors.red,
              ),
            );
          default:
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.orderDetails)),
        body: OrderDetailsBody(orderId: widget.orderId),
        bottomNavigationBar: OrderStatusAction(orderId: widget.orderId),
      ),
    );
  }
<<<<<<< HEAD
=======

  void _handleUiEvent(BuildContext context, OrderDetailsUiEvent event) {
    final l10n = AppLocalizations.of(context)!;

    switch (event) {
      case ShowOrderStatusUpdated():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.orderStatusUpdatedSuccessfully),
            backgroundColor: AppColors.success,
          ),
        );

      case ShowOrderDetailsFailure():
        final message = mapAppFailureToMessage(event.failure, l10n);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );

      case ShowLocationPermissionDenied():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.locationPermissionToTrackDelivery),
            backgroundColor: AppColors.amber,
          ),
        );
    }
  }
>>>>>>> background-reporting
}

class OrderStatusAction extends StatelessWidget {
  final String orderId;

  const OrderStatusAction({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
      builder: (context, state) {
        final status = state.orderDetails.data?.status;
        final updateState = state.updateOrderStatus;

        if (status != null && status.nextStatus == null) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.grey[300]!, width: 3),
            ),
          ),
          padding: EdgeInsets.all(16.w),
          child: CustomButton(
            label: status?.getNextStatusLabel(l10n) ?? l10n.startDeliver,
            isLoading: updateState.isLoading,
            onPressed: () {
              final nextStatus = status?.nextStatus;

              if (nextStatus == null || updateState.isLoading) {
                return;
              }

              context.read<OrderDetailsCubit>().doEvent(
                UpdateOrderStatusEvent(orderId: orderId, newStatus: nextStatus),
              );
            },
          ),
        );
      },
    );
  }
}
