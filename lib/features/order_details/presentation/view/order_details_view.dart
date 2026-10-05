import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/core/shared/widgets/order_item_card.dart';
import 'package:driver_app/core/shared/widgets/user_address_card.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_cubit.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_event.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_state.dart';
import 'package:driver_app/features/order_details/presentation/widgets/order_status_header.dart';
import 'package:driver_app/features/order_details/presentation/widgets/order_total.dart';
import 'package:driver_app/features/order_details/presentation/widgets/payment_method_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../../../../core/constants/app_strings/app_strings.dart';

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

    context.read<OrderDetailsCubit>().doEvent(
      GetDriverOrderDetailsEvent(orderId: widget.orderId),
    );
  }

  int _statusStep(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 1;
      case 'accepted':
      case 'assigned':
        return 2;
      case 'on_the_way':
      case 'ontheway':
      case 'in_progress':
        return 3;
      case 'picked_up':
      case 'arrived':
        return 4;
      case 'delivered':
      case 'completed':
        return 5;
      default:
        return 1;
    }
  }

  String _currencyLabel(String? currency) {
    final value = currency ?? '\$';
    return value.contains('\$') || value.contains('€') || value.contains('£')
        ? value
        : '$value ';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderDetailsCubit, OrderDetailsState>(
      listener: (context, state) {
        if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }

        if (state.updateStatusSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order status updated successfully')),
          );
        }

        if (state.reportLocationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location reported successfully')),
          );
        }
      },
      builder: (context, state) {
        final data = state.data;
        final pickupAddress = data?.pickupAddress;
        final userAddress = data?.userAddress;
        final itemList = data?.items ?? const [];
        final timeline = data?.timeline ?? const [];

        if (state.isLoading && data == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

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
                    currentStep: _statusStep(data?.status),
                    selectedColor: Colors.green,
                    unselectedColor: Colors.grey,
                    size: 4,
                    roundedEdges: const Radius.circular(2),
                  ),

                  SizedBox(height: 12.h),

                  OrderStatusHeader(
                    status: data?.status ?? 'Accepted',
                    orderId: data?.orderNumber ?? '#${widget.orderId}',
                    date: timeline.isNotEmpty
                        ? timeline.last.timestamp
                        : 'Wed, 03 Sep 2024, 11:00 AM',
                  ),

                  SizedBox(height: 10.h),

                  Text(
                    AppStrings.pickupAddress,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10.h),

                  UserAddressCard(
                    address:
                        pickupAddress?.addressLine ??
                        'Pickup address not available',
                    userName: pickupAddress?.storeName ?? 'Flowery store',
                  ),

                  SizedBox(height: 10.h),

                  Text(
                    AppStrings.userAddress,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10.h),

                  UserAddressCard(
                    address:
                        userAddress?.addressLine ??
                        'Recipient address not available',
                    userName:
                        userAddress?.recipientName ??
                        data?.recipientInfo.recipientName ??
                        'Ahmed Ali',
                  ),

                  SizedBox(height: 13.h),

                  Text(
                    AppStrings.orderDetails,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 13.h),

                  ...itemList.map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: OrderItemCard(
                        productName: item.productName,
                        quantity: item.quantity,
                        price:
                            '${_currencyLabel(data?.currency)}${item.unitPrice.toStringAsFixed(2)}',
                      ),
                    ),
                  ),

                  if (itemList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: OrderItemCard(),
                    ),

                  SizedBox(height: 8.h),

                  OrderTotal(
                    totalAmount:
                        '${_currencyLabel(data?.currency)}${(data?.totalPrice ?? 0).toStringAsFixed(2)}',
                  ),

                  SizedBox(height: 13.h),

                  PaymentMethodCard(
                    method: data?.paymentMethod ?? 'Cash on delivery',
                  ),

                  SizedBox(height: 13.h),
                ],
              ),
            ),
          ),

          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 3),
              ),
            ),
            padding: EdgeInsets.all(16.w),
            child: CustomButton(
              label: 'Start Delivery',
              onPressed: () {
                context.read<OrderDetailsCubit>().doEvent(
                  UpdateOrderStatusEvent(
                    orderId: widget.orderId,
                    newStatus: 'OnTheWay',
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
