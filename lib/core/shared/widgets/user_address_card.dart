import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserAddressCard extends StatelessWidget {
  const UserAddressCard({
    super.key,
    this.userImage,
    this.userName = 'User Name',
    this.address = 'Address',
    this.onCallPressed,
    this.onWhatsAppPressed,
  });

  final ImageProvider? userImage;
  final String userName;
  final String address;
  final VoidCallback? onCallPressed;
  final VoidCallback? onWhatsAppPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 365.w,
      height: 80.h,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey[300]!),

        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.grey[200],
                borderRadius: BorderRadius.circular(60.r),
              ),
              child: userImage == null
                  ? const Icon(Icons.image, size: 40)
                  : ClipOval(
                      child: Image(
                        image: userImage!,
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.grey[800]),
                ),
                SizedBox(height: 4.h),
                Text(
                  address,

                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 5.w),
          IconButton(
            tooltip: 'Call',
            icon: const Icon(Icons.call, color: AppColors.primary),
            onPressed: onCallPressed,
          ),
          IconButton(
            tooltip: 'WhatsApp',
            icon: const FaIcon(
              FontAwesomeIcons.whatsapp,
              color: AppColors.primary,
            ),
            onPressed: onWhatsAppPressed,
          ),
          SizedBox(width: 0.w),
        ],
      ),
    );
  }
}
