import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/delivery_map/domain/models/address_model.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_cubit.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_event.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_state.dart';
import 'package:driver_app/features/delivery_map/presentation/widgets/delivery_address_card.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class DeliveryBottomSheet extends StatelessWidget {
  const DeliveryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<DeliveryMapCubit, DeliveryMapState>(
      buildWhen: (previous, current) =>
          previous.target != current.target ||
          previous.pickupAddress != current.pickupAddress ||
          previous.userAddress != current.userAddress ||
          previous.route != current.route ||
          previous.routeFailure != current.routeFailure,
      builder: (context, state) {
        final cubit = context.read<DeliveryMapCubit>();
        final isPickupActive = state.target.isPickup;

        final pickupAddress =
            state.pickupAddress ??
            AddressModel(
              title: l10n.floweryStore,
              addressLine: l10n.address,
              latitude: 0,
              longitude: 0,
            );
        final userAddress =
            state.userAddress ??
            AddressModel(
              title: l10n.customerName,
              addressLine: l10n.address,
              latitude: 0,
              longitude: 0,
            );

        final pickupSection = _DeliveryAddressSection(
          sectionLabel: l10n.pickupAddress,
          address: pickupAddress,
          isStore: true,
          isSelected: isPickupActive,
          onTap: () => cubit.doEvent(
            const SwitchTargetEvent(DeliveryMapTarget.pickup),
          ),
          onCallPressed: () => cubit.doEvent(
            CallPhoneEvent(pickupAddress.phoneNumber),
          ),
          onWhatsAppPressed: () => cubit.doEvent(
            OpenWhatsAppEvent(pickupAddress.phoneNumber),
          ),
        );

        final userSection = _DeliveryAddressSection(
          sectionLabel: l10n.userAddress,
          address: userAddress,
          isStore: false,
          isSelected: !isPickupActive,
          onTap: () => cubit.doEvent(
            const SwitchTargetEvent(DeliveryMapTarget.user),
          ),
          onCallPressed: () => cubit.doEvent(
            CallPhoneEvent(userAddress.phoneNumber),
          ),
          onWhatsAppPressed: () => cubit.doEvent(
            OpenWhatsAppEvent(userAddress.phoneNumber),
          ),
        );

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.1),
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
                  child: _RouteSummaryBadge(route: state.route!),
                ),
              ] else if (state.hasRouteFailure) ...[
                SizedBox(height: 12.h),
                Center(
                  child: _RouteUnavailableBadge(
                    label: l10n.routeUnavailable,
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

class _DeliveryAddressSection extends StatelessWidget {
  final String sectionLabel;
  final AddressModel address;
  final bool isStore;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onCallPressed;
  final VoidCallback onWhatsAppPressed;

  const _DeliveryAddressSection({
    required this.sectionLabel,
    required this.address,
    required this.isStore,
    required this.isSelected,
    required this.onTap,
    required this.onCallPressed,
    required this.onWhatsAppPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          sectionLabel,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        DeliveryAddressCard(
          title: address.title,
          address: address.addressLine,
          isStore: isStore,
          isSelected: isSelected,
          onTap: onTap,
          onCallPressed: onCallPressed,
          onWhatsAppPressed: onWhatsAppPressed,
        ),
      ],
    );
  }
}

class _RouteSummaryBadge extends StatelessWidget {
  final RouteModel route;

  const _RouteSummaryBadge({required this.route});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
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
            '${route.formattedDistance} • ${route.formattedDuration}',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteUnavailableBadge extends StatelessWidget {
  final String label;

  const _RouteUnavailableBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.error.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.error.shade100,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 16.sp,
            color: AppColors.error,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
