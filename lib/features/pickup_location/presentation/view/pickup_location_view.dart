import 'dart:async';

import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/core/shared/widgets/base_ui_event_listener.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_cubit.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_state.dart';
import 'package:driver_app/features/pickup_location/domain/params/driving_route_params.dart';
import 'package:driver_app/features/pickup_location/presentation/manager/cubit/pickup_location_cubit.dart';
import 'package:driver_app/features/pickup_location/presentation/manager/cubit/pickup_location_state.dart';
import 'package:driver_app/features/pickup_location/presentation/utils/map_helper.dart';
import 'package:driver_app/features/pickup_location/presentation/view/pickup_location_body.dart';
import 'package:driver_app/features/pickup_location/presentation/widgets/go_pack_button.dart';
import 'package:driver_app/features/pickup_location/presentation/widgets/pickup_map.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickupLocationView extends StatelessWidget {
  const PickupLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final initialOrderDetails = context
        .read<OrderDetailsCubit>()
        .state
        .orderDetails
        .data;

    return BlocProvider(
      create: (_) {
        final cubit = getIt<PickupLocationCubit>();
        unawaited(cubit.loadCurrentLocation());
        if (initialOrderDetails != null) {
          unawaited(cubit.loadDrivingRoute(_routeParams(initialOrderDetails)));
        }
        return cubit;
      },
      child: BaseUiEventListener<
        PickupLocationCubit,
        PickupLocationState,
        BaseUiEvent
      >(
        child: BlocListener<OrderDetailsCubit, OrderDetailsState>(
          listenWhen: (previous, current) =>
              previous.orderDetails.data == null &&
              current.orderDetails.data != null,
          listener: (context, state) {
            final orderDetails = state.orderDetails.data;
            if (orderDetails != null) {
              unawaited(
                context.read<PickupLocationCubit>().loadDrivingRoute(
                  _routeParams(orderDetails),
                ),
              );
            }
          },
          child: Scaffold(
            body: Stack(
              children: [
                BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
                  builder: (context, orderState) {
                    return BlocBuilder<
                      PickupLocationCubit,
                      PickupLocationState
                    >(
                      builder: (context, pickupState) {
                        final orderDetails = orderState.orderDetails.data;
                        if (orderDetails != null) {
                          return _buildOrderMap(
                            orderDetails,
                            orderState,
                            pickupState,
                          );
                        }

                        return _buildCurrentLocationMap(context, pickupState);
                      },
                    );
                  },
                ),
                const Align(
                  alignment: Alignment.topLeft,
                  child: GoPackButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderMap(
    DriverOrderDetailsEntity orderDetails,
    OrderDetailsState orderState,
    PickupLocationState pickupState,
  ) {
    final driverPosition =
        orderState.driverLocation ?? pickupState.currentLocation.data;
    final pickupLocation = LatLng(
      orderDetails.pickupAddress.latitude,
      orderDetails.pickupAddress.longitude,
    );
    final customerLocation = LatLng(
      orderDetails.userAddress.latitude,
      orderDetails.userAddress.longitude,
    );

    return PickupLocationBody(
      pickupLocation: pickupLocation,
      userLocation: customerLocation,
      driverLocation: driverPosition,
      route: pickupState.drivingRoute.data,
      isLoadingRoute: pickupState.drivingRoute.isLoading,
    );
  }

  Widget _buildCurrentLocationMap(
    BuildContext context,
    PickupLocationState state,
  ) {
    final localizations = AppLocalizations.of(context)!;
    final location = state.currentLocation;

    if (location.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (location.data case final currentLocation?) {
      return PickupMap(driverLocation: currentLocation);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              location.errorMessage == null
                  ? localizations.failureUnknown
                  : mapAppFailureToMessage(location.errorMessage!, localizations),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => unawaited(
                context.read<PickupLocationCubit>().loadCurrentLocation(),
              ),
              child: Text(localizations.retry),
            ),
          ],
        ),
      ),
    );
  }

  DrivingRouteParams _routeParams(DriverOrderDetailsEntity orderDetails) {
    return DrivingRouteParams(
      origin: LatLng(
        orderDetails.pickupAddress.latitude,
        orderDetails.pickupAddress.longitude,
      ).toMapLocation(),
      destination: LatLng(
        orderDetails.userAddress.latitude,
        orderDetails.userAddress.longitude,
      ).toMapLocation(),
    );
  }
}
