import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver_app/core/constants/app_images/app_images.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge);
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w400,
        color: AppColors.grey,
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(OrderHistoryDimens.paddingL.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(OrderHistoryDimens.radiusM.r),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

/// Centers [child] inside a scrollable that is always draggable, so a
/// [RefreshIndicator] can be pulled even when there is little or no content.
class CenteredScrollView extends StatelessWidget {
  const CenteredScrollView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class AvatarImage extends StatelessWidget {
  const AvatarImage({
    super.key,
    required this.imageUrl,
    this.size = OrderHistoryDimens.avatarSize,
  });

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return ClipOval(
      child: SizedBox(
        width: size.w,
        height: size.w,
        child: (url == null || url.isEmpty)
            ? const _FallbackAssetImage()
            : CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          errorWidget: (context, error, stack) => const _FallbackAssetImage(),
        ),
      ),
    );
  }
}

class _FallbackAssetImage extends StatelessWidget {
  const _FallbackAssetImage();

  @override
  Widget build(BuildContext context) {
    return Image.asset(AppImages.defaultAvatar, fit: BoxFit.cover);
  }
}
