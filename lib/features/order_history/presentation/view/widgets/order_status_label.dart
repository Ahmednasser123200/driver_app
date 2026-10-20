import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_status_ui.dart';
import 'package:flutter/material.dart';

class OrderStatusLabel extends StatelessWidget {
  const OrderStatusLabel({
    super.key,
    required this.status,
    required this.iconSize,
    required this.spacing,
    required this.textStyle,
  });
  final OrderStatus status;
  final double iconSize;
  final double spacing;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(status.icon, color: status.color, size: iconSize),
        SizedBox(width: spacing),
        Text(status.label, style: textStyle),
      ],
    );
  }
}
