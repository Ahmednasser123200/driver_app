import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver_app/core/constants/app_images/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../order_history_dimens.dart';

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