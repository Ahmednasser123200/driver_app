import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_cubit.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_event.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_state.dart';
import 'package:driver_app/features/delivery_map/presentation/widgets/delivery_address_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class DeliveryBottomSheet extends StatelessWidget {
  const DeliveryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryMapCubit, DeliveryMapState>(
      builder: (context, state) {
        final cubit = context.read<DeliveryMapCubit>();
        final isPickupActive = state.target.isPickup;

        final pickupSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pickup address',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey[700],
              ),
            ),
            SizedBox(height: 8.h),
            DeliveryAddressCard(
              title: state.pickupAddress.title,
              address: state.pickupAddress.addressLine,
              isStore: true,
              isSelected: isPickupActive,
              onTap: () => cubit.doEvent(
                const SwitchTargetEvent(DeliveryMapTarget.pickup),
              ),
              onCallPressed: () => cubit.doEvent(
                CallPhoneEvent(state.pickupAddress.phoneNumber),
              ),
              onWhatsAppPressed: () => cubit.doEvent(
                OpenWhatsAppEvent(state.pickupAddress.phoneNumber),
              ),
            ),
          ],
        );

        final userSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'User address',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey[700],
              ),
            ),
            SizedBox(height: 8.h),
            DeliveryAddressCard(
              title: state.userAddress.title,
              address: state.userAddress.addressLine,
              isStore: false,
              isSelected: !isPickupActive,
              onTap: () => cubit.doEvent(
                const SwitchTargetEvent(DeliveryMapTarget.user),
              ),
              onCallPressed: () => cubit.doEvent(
                CallPhoneEvent(state.userAddress.phoneNumber),
              ),
              onWhatsAppPressed: () => cubit.doEvent(
                OpenWhatsAppEvent(state.userAddress.phoneNumber),
              ),
            ),
          ],
        );

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 56.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              if (state.route != null) ...[
                SizedBox(height: 12.h),
                Center(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.shade50,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: AppColors.primary.shade100,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_car_rounded,
                          size: 16.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '${state.route!.formattedDistance} • ${state.route!.formattedDuration}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 16.h),
              if (isPickupActive) ...[
                pickupSection,
                SizedBox(height: 16.h),
                userSection,
              ] else ...[
                userSection,
                SizedBox(height: 16.h),
                pickupSection,
              ],
            ],
          ),
        );
      },
    );
  }
}
