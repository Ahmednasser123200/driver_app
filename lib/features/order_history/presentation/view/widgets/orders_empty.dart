import 'package:flutter/material.dart';
import '../../../../../core/constants/app_strings/app_strings.dart';
import 'common/centered_scroll_view.dart';

class OrdersEmpty extends StatelessWidget {
  const OrdersEmpty({super.key, required this.isLoading});
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return CenteredScrollView(
      child: isLoading
          ? const CircularProgressIndicator()
          : const Text(AppStrings.noOrdersYet),
    );
  }
}