import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/home/domain/entities/available_order.dart';
import 'package:driver_app/features/home/presentation/widgets/accept_order_button.dart';
import 'package:driver_app/features/home/presentation/widgets/information_card.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class AvailableOrderCard extends StatelessWidget {
  const AvailableOrderCard({super.key, required this.order});

  final AvailableOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              local.flowerOrder,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              local.pickupAddress,
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            InformationCard(
              theme: theme,
              image: 'https://picsum.photos/100',
              title: order.store.name,
              address: order.store.address,
            ),

            const SizedBox(height: 18),

            /// User Address
            Text(
              local.userAddress,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 8),

            InformationCard(
              theme: theme,
              image: 'https://picsum.photos/101',
              title: order.recipient.name,
              address: '${order.recipient.city} , ${order.recipient.area}',
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Text(
                  order.total.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const Spacer(),

                AcceptOrderButton(local: local, orderId: order.orderId),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
