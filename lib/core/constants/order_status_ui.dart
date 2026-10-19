import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:flutter/material.dart';

import 'app_strings/app_strings.dart';

extension OrderStatusUi on OrderStatus {
  bool get isCompleted => this == OrderStatus.completed;

  Color get color => isCompleted ? AppColors.success : AppColors.error;

  IconData get icon =>
      isCompleted ? Icons.check_circle_outline : Icons.cancel_outlined;

  String get label =>
      isCompleted ? AppStrings.statusCompleted : AppStrings.statusCancelled;
}