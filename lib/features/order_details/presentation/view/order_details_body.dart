
import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/core/shared/widgets/order_item_card.dart';
import 'package:driver_app/core/shared/widgets/user_address_card.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/order_status.dart';
import 'package:driver_app/features/order_details/presentation/extensions/currency_extension.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_cubit.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_event.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_state.dart';
import 'package:driver_app/features/order_details/presentation/utils/order_status_helper.dart';
import 'package:driver_app/features/order_details/presentation/widgets/order_status_header.dart';
import 'package:driver_app/features/order_details/presentation/widgets/order_total.dart';
import 'package:driver_app/features/order_details/presentation/widgets/payment_method_card.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class OrderDetailsBody extends StatelessWidget {
  final String orderId;

  const OrderDetailsBody({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      OrderDetailsCubit,
      OrderDetailsState,
      BaseState<DriverOrderDetailsEntity>
    >(
      selector: (state) => state.orderDetails,
      builder: (context, state) {
        final data = state.data;

        if (state.isLoading && data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (data == null) {
          return OrderDetailsError(
            orderId: orderId,
            failure: state.errorMessage,
          );
        }

        return OrderDetailsContent(
          orderId: orderId,
          data: data,
        );
      },
    );
  }
}

class OrderDetailsError extends StatelessWidget {
  final String orderId;
  final dynamic failure;

  const OrderDetailsError({
    super.key,
    required this.orderId,
    required this.failure,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final message = failure != null
        ? _failureMessage(failure, l10n)
        : l10n.failureUnknown;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.sp),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            CustomButton(
              label: l10n.retry,
              onPressed: () {
                context.read<OrderDetailsCubit>().doEvent(
                  GetDriverOrderDetailsEvent(orderId: orderId),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _failureMessage(dynamic failure, AppLocalizations l10n) {
    return mapAppFailureToMessage(failure, l10n);
  }
}

class OrderDetailsContent extends StatelessWidget {
  final String orderId;
  final DriverOrderDetailsEntity data;

  const OrderDetailsContent({
    super.key,
    required this.orderId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderStatusSection(
            status: data.status,
            orderId: data.orderNumber.isNotEmpty
                ? data.orderNumber
                : '#$orderId',
            timeline: data.timeline,
          ),
          SizedBox(height: 16.h),
          OrderAddressesSection(data: data),
          SizedBox(height: 16.h),
          OrderItemsSection(data: data),
          SizedBox(height: 13.h),
          PaymentMethodCard(
            title: l10n.paymentMethod,
            method: data.paymentMethod ,
          ),
          SizedBox(height: 13.h),
        ],
      ),
    );
  }
}

class OrderStatusSection extends StatelessWidget {
  final OrderStatus status;
  final String orderId;
  final List timeline;

  const OrderStatusSection({
    super.key,
    required this.status,
    required this.orderId,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        StepProgressIndicator(
          totalSteps: 5,
          currentStep: status.step,
          selectedColor: Colors.green,
          unselectedColor: Colors.grey,
          size: 4,
          roundedEdges: const Radius.circular(2),
        ),
        SizedBox(height: 12.h),
        OrderStatusHeader(
          status: status.getLocalizedStatus(l10n),
          orderId: orderId,
          date: timeline.isNotEmpty
              ? timeline.last.timestamp
              : l10n.orderDate,
        ),
      ],
    );
  }
}

class OrderAddressesSection extends StatelessWidget {
  final DriverOrderDetailsEntity data;

  const OrderAddressesSection({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.pickupAddress,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.h),
        UserAddressCard(
          address: data.pickupAddress.addressLine,
          userName: data.pickupAddress.storeName,
        ),
        SizedBox(height: 16.h),
        Text(
          l10n.userAddress,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.h),
        UserAddressCard(
          address: data.userAddress.addressLine,
          userName: data.userAddress.recipientName ,
        ),
      ],
    );
  }
}

class OrderItemsSection extends StatelessWidget {
  final DriverOrderDetailsEntity data;

  const OrderItemsSection({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.orderDetails,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 13.h),
        ...data.items.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: OrderItemCard(
              productName: item.productName,
              quantity: item.quantity,
              price:
                  '${data.currency.currencyLabel}'
                  '${item.unitPrice.toStringAsFixed(2)}',
            ),
          ),
        ),
        if (data.items.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: OrderItemCard(
              productName: 'Unknown',
              price: 'Unknown',
              quantity: 0,
            ),
          ),
        SizedBox(height: 8.h),
        OrderTotal(
          totalLabel: l10n.total,
          totalAmount:
              '${data.currency.currencyLabel}'
              '${data.totalPrice.toStringAsFixed(2)}',
        ),
      ],
    );
  }
}
