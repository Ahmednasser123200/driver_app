import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../../../core/constants/app_strings/app_strings.dart';
import '../../../domain/entities/order_history_entities.dart';
import 'address_card.dart';
import 'common/section_title.dart';

class UserSection extends StatelessWidget {
  const UserSection({super.key, required this.user});
  final OrderUserEntity user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(text: AppStrings.userAddress),
        SizedBox(height: OrderHistoryDimens.paddingL.h),
        AddressCard(
          name: user.name,
          address: user.address,
          imageUrl: user.imageUrl,
        ),
      ],
    );
  }
}
