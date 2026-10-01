import 'package:driver_app/core/shared/widgets/order_item_card.dart';
import 'package:driver_app/core/shared/widgets/user_address_card.dart';
import 'package:driver_app/features/order_details/presentation/widgets/order_status_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: OrderStatusHeader(),
    );
  }
}