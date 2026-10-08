import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_cubit.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_state.dart';
import 'package:driver_app/features/home/presentation/widgets/available_order_card.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AvailableOrdersList extends StatelessWidget {
  const AvailableOrdersList({super.key});


  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) {
        return previous.getAvailableOrdersState !=
            current.getAvailableOrdersState;
      },
      builder: (context, state) {
        final orderState = state.getAvailableOrdersState;
        if (orderState.isLoading) {
          return Center(child: const CircularProgressIndicator());
        }
        if (orderState.errorMessage != null) {
          return Center(child: Text(mapAppFailureToMessage(orderState.errorMessage!, local)));
        }
        final orderData = orderState.data?.items ?? [];
        if (orderData.isEmpty) {
          return const Center(child: Text('No orders available'));
        }

        return ListView.builder(
          itemCount: orderData.length,
          itemBuilder: (context, index) =>
              AvailableOrderCard(order: orderData[index]),
        );
      },
    );
  }
}
