import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../core/constants/app_strings/app_strings.dart';
import '../../manager/order_details_cubit.dart';
import '../../manager/order_details_event.dart';
import '../../manager/order_details_state.dart';
import 'order_details_content.dart';

class OrderDetailsBody extends StatelessWidget {
  const OrderDetailsBody({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
      builder: (context, state) {
        final details = state.orderDetails.data;
        if (details != null) return OrderDetailsContent(details: details);
        if (state.orderDetails.errorMessage.isNotEmpty) {
          return OrderDetailsError(
            message: state.orderDetails.errorMessage,
            onRetry: () => _retry(context),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _retry(BuildContext context) {
    context
        .read<OrderDetailsCubit>()
        .doIntent(GetOrderDetailsEvent(orderId: orderId));
  }
}

class OrderDetailsError extends StatelessWidget {
  const OrderDetailsError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}