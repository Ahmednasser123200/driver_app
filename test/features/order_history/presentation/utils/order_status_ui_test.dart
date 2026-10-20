import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_status_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderStatusUi', () {
    test('completed status properties', () {
      const status = OrderStatus.completed;
      expect(status.isCompleted, isTrue);
      expect(status.color, AppColors.success);
      expect(status.icon, Icons.check_circle_outline);
      expect(status.label, AppStrings.statusCompleted);
    });

    test('cancelled status properties', () {
      const status = OrderStatus.cancelled;
      expect(status.isCompleted, isFalse);
      expect(status.color, AppColors.error);
      expect(status.icon, Icons.cancel_outlined);
      expect(status.label, AppStrings.statusCancelled);
    });
  });
}
