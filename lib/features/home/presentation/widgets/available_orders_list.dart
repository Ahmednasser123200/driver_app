import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_cubit.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_event.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_state.dart';
import 'package:driver_app/features/home/presentation/widgets/available_order_card.dart';
import 'package:driver_app/features/home/presentation/widgets/refresh_widget.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AvailableOrdersList extends StatelessWidget {
  const AvailableOrdersList({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<RefreshIndicatorState> refreshKey =
        GlobalKey<RefreshIndicatorState>();
    final local = AppLocalizations.of(context)!;
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) {
        return previous.getAvailableOrdersState !=
                current.getAvailableOrdersState ||
            previous.isLoadingMore != current.isLoadingMore;
      },
      builder: (context, state) {
        final orderState = state.getAvailableOrdersState;
        if (orderState.isLoading) {
          return Center(child: const CircularProgressIndicator());
        }
        if (orderState.errorMessage != null) {
          return Center(
            child: Text(
              mapAppFailureToMessage(orderState.errorMessage!, local),
            ),
          );
        }
        final orderData = orderState.data?.items ?? [];
        if (orderData.isEmpty) {
          return const Center(child: Text('No orders available'));
        }

        return RefreshWidget(
          refreshKey: refreshKey,
          onRefresh: () =>
              context.read<HomeCubit>().doEvent(GetAvailableOrdersEvent()),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                final metrics = notification.metrics;
                final distance = metrics.maxScrollExtent - 200;
                // log(metrics.pixels.toString(), name: 'metrics.pixels');
                // log(distance.toString(), name: 'distance');
                // log( metrics.maxScrollExtent.toString(),name: 'metrics.maxScrollExtent');
                if (metrics.pixels >= distance) {
                  context.read<HomeCubit>().doEvent(LoadMoreOrdersEvent());
                }
              }
              return false;
            },
            child: ListView.builder(
              itemCount: orderData.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == orderData.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return AvailableOrderCard(order: orderData[index]);
              },
            ),
          ),
        );
      },
    );
  }
}
