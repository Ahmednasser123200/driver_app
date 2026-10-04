import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/core/shared/widgets/order_item_card.dart';
import 'package:driver_app/core/shared/widgets/user_address_card.dart';
import 'package:driver_app/features/order_details/presentation/widgets/order_status_header.dart';
import 'package:driver_app/features/order_details/presentation/widgets/order_total.dart';
import 'package:driver_app/features/order_details/presentation/widgets/payment_method_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../../../../core/constants/app_strings/app_strings.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StepProgressIndicator(
                totalSteps: 5,
                currentStep: 1,
                selectedColor: Colors.green,
                unselectedColor: Colors.grey,
                size: 4,
                roundedEdges: Radius.circular(2),
              ),
              SizedBox(height: 12.h),
              OrderStatusHeader(),
              SizedBox(height: 10.0.h),
              Text(
                AppStrings.pickupAddress,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0.h),
              UserAddressCard(
                address: '123 Main St, Springfield, USA',
                userName: 'Flowery store',
              ),
              SizedBox(height: 10.0.h),
              Text(
                AppStrings.userAddress,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0.h),
              UserAddressCard(
                address: '123 Main St, Springfield, USA',
                userName: 'Ahmed Ali',
              ),
              SizedBox(height: 13.0.h),
              Text(
                AppStrings.orderDetails,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 13.0.h),
              OrderItemCard(
                productName: 'Item 1',
                quantity: 2,
                price: '\$20.00',
              ),
              SizedBox(height: 8.h),
              OrderItemCard(
                productName: 'Item 2',
                quantity: 1,
                price: '\$15.00',
              ),
              SizedBox(height: 8.h),
              OrderTotal(),
              SizedBox(height: 13.0.h),
              PaymentMethodCard(),
              SizedBox(height: 13.0.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[300]!, width: 3)),
        ),
        padding: EdgeInsets.all(16.0.w),
        child: CustomButton(
          label: 'Start Delivery',
          onPressed: () {
            // Handle button press
          },
        ),
      ),
    );
  }
}
