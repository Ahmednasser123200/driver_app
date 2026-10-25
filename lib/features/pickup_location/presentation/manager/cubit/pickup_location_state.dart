import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/features/pickup_location/domain/entities/driving_route.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickupLocationState extends Equatable {
  const PickupLocationState({
    this.drivingRoute = const BaseState(),
    this.currentLocation = const BaseState(),
  });

  final BaseState<DrivingRoute> drivingRoute;
  final BaseState<LatLng> currentLocation;

  PickupLocationState copyWith({
    BaseState<DrivingRoute>? drivingRoute,
    BaseState<LatLng>? currentLocation,
  }) {
    return PickupLocationState(
      drivingRoute: drivingRoute ?? this.drivingRoute,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }

  @override
  List<Object?> get props => [drivingRoute, currentLocation];
}
