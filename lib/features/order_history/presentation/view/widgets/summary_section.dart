import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../../../core/constants/app_strings/app_strings.dart';
import '../../../domain/entities/order_history_entities.dart';
import 'summary_row.dart';

class SummarySection extends StatelessWidget {
  const SummarySection({super.key, required this.details});
  final OrderHistoryDetailsEntity details;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SummaryRow(
          label: AppStrings.total,
          value: formatPrice(details.totalPrice, details.currency),
        ),
        if (details.isCashOnDelivery) ...[
          SizedBox(height: OrderHistoryDimens.paddingL.h),
          const SummaryRow(
            label: AppStrings.paymentMethod,
            value: AppStrings.cashOnDelivery,
          ),
        ],
      ],
    );
  }
}
