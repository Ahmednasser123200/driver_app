import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DeliveryAddressCard extends StatelessWidget {
  final String title;
  final String address;
  final bool isStore;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onCallPressed;
  final VoidCallback? onWhatsAppPressed;
  final ImageProvider? userImage;

  const DeliveryAddressCard({
    super.key,
    required this.title,
    required this.address,
    this.isStore = false,
    this.isSelected = false,
    this.onTap,
    this.onCallPressed,
    this.onWhatsAppPressed,
    this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              _buildAvatar(),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14.sp,
                          color: AppColors.grey[700],
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _buildActionButton(
                icon: Icons.call_outlined,
                tooltip: 'Call',
                onPressed: onCallPressed,
              ),
              _buildActionButton(
                iconWidget: const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: AppColors.primary,
                  size: 18,
                ),
                tooltip: 'WhatsApp',
                onPressed: onWhatsAppPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (isStore) {
      return Container(
        width: 44.w,
        height: 44.w,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_florist_rounded,
              color: Colors.white,
              size: 16.sp,
            ),
            Text(
              'Flowery',
              style: TextStyle(
                color: Colors.white,
                fontSize: 7.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        shape: BoxShape.circle,
        image: userImage != null
            ? DecorationImage(
                image: userImage!,
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: userImage == null
          ? Icon(
              Icons.person,
              color: AppColors.grey[500],
              size: 26.sp,
            )
          : null,
    );
  }

  Widget _buildActionButton({
    IconData? icon,
    Widget? iconWidget,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      child: IconButton(
        icon: iconWidget ??
            Icon(
              icon,
              color: AppColors.primary,
              size: 20.sp,
            ),
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
