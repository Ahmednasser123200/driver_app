import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/core/shared/widgets/base_ui_event_listener.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_cubit.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_state.dart';
import 'package:driver_app/features/pickup_location/domain/params/driving_route_params.dart';
import 'package:driver_app/features/pickup_location/presentation/manager/cubit/pickup_location_cubit.dart';
import 'package:driver_app/features/pickup_location/presentation/manager/cubit/pickup_location_state.dart';
import 'package:driver_app/features/pickup_location/presentation/utils/map_helper.dart';
import 'package:driver_app/features/pickup_location/presentation/view/pickup_location_body.dart';
import 'package:driver_app/features/pickup_location/presentation/widgets/go_pack_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickupLocationView extends StatelessWidget {
  const PickupLocationView({super.key});

  
  static const LatLng fallbackPickupLocation = LatLng(30.0444, 31.2357);
  static const LatLng fallbackCustomerLocation = LatLng(30.0398, 31.2302);

  @override
  Widget build(BuildContext context) {
    final orderDetails = context
        .read<OrderDetailsCubit?>()
        ?.state
        .orderDetails
        .data;

    final pickup = resolvePickupLocation(
      orderDetails,
      fallback: fallbackPickupLocation,
    );
    final customer = resolveCustomerLocation(
      orderDetails,
      fallback: fallbackCustomerLocation,
    );

    return BlocProvider(
      create: (_) => getIt<PickupLocationCubit>()
        ..loadDrivingRoute(
          DrivingRouteParams(
            origin: pickup.toMapLocation(),
            destination: customer.toMapLocation(),
          ),
        ),
      child:
          BaseUiEventListener<
            PickupLocationCubit,
            PickupLocationState,
            BaseUiEvent
          >(
            child: Scaffold(
              body: Stack(
                children: [
                  BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
                    builder: (context, state) {
                      final location = state.driverLocation;

                      final driverPosition = location == null
                          ? null
                          : LatLng(location.latitude, location.longitude);

                      final currentPickup = resolvePickupLocation(
                        state.orderDetails.data,
                        fallback: fallbackPickupLocation,
                      );
                      final currentCustomer = resolveCustomerLocation(
                        state.orderDetails.data,
                        fallback: fallbackCustomerLocation,
                      );

                      return BlocBuilder<
                        PickupLocationCubit,
                        PickupLocationState
                      >(
                        builder: (context, routeState) {
                          return PickupLocationBody(
                            pickupLocation: currentPickup,
                            userLocation: currentCustomer,
                            driverLocation: driverPosition,
                            route: routeState.drivingRoute.data,
                            isLoadingRoute: routeState.drivingRoute.isLoading,
                          );
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
    );
  }
}
