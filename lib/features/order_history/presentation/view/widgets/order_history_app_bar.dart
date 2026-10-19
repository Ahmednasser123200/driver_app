import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../core/themes/app_colors/app_colors.dart';

class OrderHistoryAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const OrderHistoryAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: 20.w),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
      ),
    );
  }
}