import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/core/shared/widgets/base_ui_event_listener.dart';
import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/core/shared/widgets/order_item_card.dart';
import 'package:driver_app/core/shared/widgets/user_address_card.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_cubit.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_event.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_state.dart';
import 'package:driver_app/features/order_details/presentation/widgets/order_status_header.dart';
import 'package:driver_app/features/order_details/presentation/widgets/order_total.dart';
import 'package:driver_app/features/order_details/presentation/widgets/payment_method_card.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

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

  String _localizedStatus(String? status, AppLocalizations l10n) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return l10n.pending;
      case 'accepted':
      case 'assigned':
        return l10n.accepted;
      case 'picked_up':
      case 'picked':
        return l10n.picked;
      case 'on_the_way':
      case 'ontheway':
      case 'in_progress':
        return l10n.outForDelivery;
      case 'arrived':
        return l10n.arrived;
      case 'delivered':
        return l10n.delivered;
      case 'completed':
        return l10n.completed;
      case 'cancelled':
        return l10n.cancelled;
      default:
        return status ?? l10n.accepted;
    }
  }

  String _currencyLabel(String? currency) {
    final value = currency ?? '\$';

    return value.contains('\$') || value.contains('€') || value.contains('£')
        ? value
        : '$value ';
  }

  void _handleCustomUiEvent(BuildContext context, BaseUiEvent event) {
    final l10n = AppLocalizations.of(context)!;

    switch (event) {
      case ShowFailureMessage(:final failure):
        final message = mapAppFailureToMessage(failure, l10n);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));

      case ShowOrderStatusUpdated():
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseUiEventListener<
      OrderDetailsCubit,
      OrderDetailsState,
      BaseUiEvent
    >(onCustomEvent: _handleCustomUiEvent, child: _buildOrderDetails(context));
  }

  Widget _buildOrderDetails(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocSelector<
      OrderDetailsCubit,
      OrderDetailsState,
      BaseState<DriverOrderDetailsEntity>
    >(
      selector: (state) => state.orderDetails,
      builder: (context, orderDetailsState) {
        final data = orderDetailsState.data;
        final pickupAddress = data?.pickupAddress;
        final userAddress = data?.userAddress;
        final itemList = data?.items ?? const [];
        final timeline = data?.timeline ?? const [];

        if (orderDetailsState.isLoading && data == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.orderDetails)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!orderDetailsState.isLoading && data == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.orderDetails)),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48.sp),
                    SizedBox(height: 16.h),
                    Text(l10n.failureUnknown, textAlign: TextAlign.center),
                    SizedBox(height: 16.h),
                    CustomButton(
                      label: l10n.continueButton,
                      onPressed: () {
                        context.read<OrderDetailsCubit>().doEvent(
                          GetDriverOrderDetailsEvent(orderId: widget.orderId),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(l10n.orderDetails)),
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
                    status: _localizedStatus(data?.status, l10n),
                    orderId: data?.orderNumber ?? '#${widget.orderId}',
                    date: timeline.isNotEmpty
                        ? timeline.last.timestamp
                        : l10n.orderDate,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    l10n.pickupAddress,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  UserAddressCard(
                    address: pickupAddress?.addressLine ?? l10n.pickupAddress,
                    userName: pickupAddress?.storeName ?? l10n.floweryStore,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    l10n.userAddress,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  UserAddressCard(
                    address: userAddress?.addressLine ?? l10n.userAddress,
                    userName:
                        userAddress?.recipientName ??
                        data?.recipientInfo.recipientName ??
                        l10n.customerName,
                  ),
                  SizedBox(height: 13.h),
                  Text(
                    l10n.orderDetails,
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
                            '${_currencyLabel(data?.currency)}'
                            '${item.unitPrice.toStringAsFixed(2)}',
                      ),
                    ),
                  ),
                  if (itemList.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: const OrderItemCard(
                        productName: 'Unknown',
                        price: 'Unknown',
                        quantity: 0,
                      ),
                    ),
                  SizedBox(height: 8.h),
                  OrderTotal(
                    totalLabel: l10n.total,
                    totalAmount:
                        '${_currencyLabel(data?.currency)}'
                        '${(data?.totalPrice ?? 0).toStringAsFixed(2)}',
                  ),
                  SizedBox(height: 13.h),
                  PaymentMethodCard(
                    title: l10n.paymentMethod,
                    method: data?.paymentMethod ?? l10n.cashOnDelivery,
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
            child:
                BlocSelector<
                  OrderDetailsCubit,
                  OrderDetailsState,
                  BaseState<UpdateOrderStatusEntity>
                >(
                  selector: (state) => state.updateOrderStatus,
                  builder: (context, updateState) {
                    return CustomButton(
                      label: l10n.startDeliver,
                      isLoading: updateState.isLoading,
                      onPressed: () {
                        context.read<OrderDetailsCubit>().doEvent(
                          UpdateOrderStatusEvent(
                            orderId: widget.orderId,
                            newStatus: 'OnTheWay',
                          ),
                        );
                      },
                    );
                  },
                ),
          ),
        );
      },
    );
  }
}
