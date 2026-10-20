import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:flutter/material.dart';

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
