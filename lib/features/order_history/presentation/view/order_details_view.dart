import 'package:driver_app/features/order_history/presentation/view/widgets/order_details_body.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../../config/base/base_ui_event.dart';
import '../../../../config/di/di.dart';
import '../../../../core/constants/app_strings/app_strings.dart';
import '../../../../core/shared/widgets/base_ui_event_listener.dart';
import '../../../../core/themes/app_colors/app_colors.dart';
import '../manager/order_details_cubit.dart';
import '../manager/order_details_event.dart';
import '../manager/order_details_state.dart';

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
          appBar: const OrderDetailsAppBar(),
          body: OrderDetailsBody(orderId: orderId),
        ),
      ),
    );
  }
}

class OrderDetailsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const OrderDetailsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: 20.w),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        AppStrings.orderDetailsTitle,
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
      ),
    );
  }
}