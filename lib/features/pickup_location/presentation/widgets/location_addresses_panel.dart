import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/core/shared/widgets/user_address_card.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class LocationAddressesPanel extends StatelessWidget {
  const LocationAddressesPanel({
    super.key,
    required this.userName,
    required this.userAddress,
    required this.storeName,
    required this.storeAddress,
    this.userImage,
    this.storeImage,
    this.onUserCallPressed,
    this.onUserWhatsAppPressed,
    this.onStoreCallPressed,
    this.onStoreWhatsAppPressed,
  });

  final String userName;
  final String userAddress;
  final String storeName;
  final String storeAddress;

  final ImageProvider? userImage;
  final ImageProvider? storeImage;

  final VoidCallback? onUserCallPressed;
  final VoidCallback? onUserWhatsAppPressed;
  final VoidCallback? onStoreCallPressed;
  final VoidCallback? onStoreWhatsAppPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: Column(
        children: [
          SizedBox(height: 12.h),

          Container(
            width: 64.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),

          SizedBox(height: 20.h),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.userAddress,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.grey[700],
                    ),
                  ),

                  SizedBox(height: 8.h),

                  UserAddressCard(
                    userName: userName,
                    address: userAddress,
                    userImage: userImage,
                    onCallPressed: onUserCallPressed,
                    onWhatsAppPressed: onUserWhatsAppPressed,
                  ),

                  SizedBox(height: 20.h),

                  Text(
                    l10n.pickupAddress,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.grey[700],
                    ),
                  ),

                  SizedBox(height: 8.h),

                  UserAddressCard(
                    userName: storeName,
                    address: storeAddress,
                    userImage: storeImage,
                    onCallPressed: onStoreCallPressed,
                    onWhatsAppPressed: onStoreWhatsAppPressed,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
