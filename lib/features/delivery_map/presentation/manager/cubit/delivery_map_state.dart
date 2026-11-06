import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/delivery_map/domain/models/address_model.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:equatable/equatable.dart';

class DeliveryMapState extends Equatable {
  final DeliveryMapTarget target;
  final GeoPoint? driverPosition;
  final AddressModel? pickupAddress;
  final AddressModel? userAddress;
  final bool isLoading;
  final bool isTrackingLocation;
  final bool hasLocationPermission;
  final bool isRouteLoading;
  final AppFailure? routeFailure;
  final String? errorMessage;
  final RouteModel? route;

  const DeliveryMapState({
    this.target = DeliveryMapTarget.pickup,
    this.driverPosition,
    this.pickupAddress,
    this.userAddress,
    this.isLoading = false,
    this.isTrackingLocation = false,
    this.hasLocationPermission = false,
    this.isRouteLoading = false,
    this.routeFailure,
    this.errorMessage,
    this.route,
  });

  AddressModel? get activeDestinationAddress =>
      target.isPickup ? pickupAddress : userAddress;

  GeoPoint? get destinationPosition => activeDestinationAddress?.location;

  bool get hasRouteFailure => routeFailure != null;

  DeliveryMapState copyWith({
    DeliveryMapTarget? target,
    GeoPoint? driverPosition,
    bool clearDriverPosition = false,
    AddressModel? pickupAddress,
    AddressModel? userAddress,
    bool? isLoading,
    bool? isTrackingLocation,
    bool? hasLocationPermission,
    bool? isRouteLoading,
    AppFailure? routeFailure,
    bool clearRouteFailure = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    RouteModel? route,
    bool clearRoute = false,
  }) {
    return DeliveryMapState(
      target: target ?? this.target,
      driverPosition: clearDriverPosition
          ? null
          : (driverPosition ?? this.driverPosition),
      pickupAddress: pickupAddress ?? this.pickupAddress,
      userAddress: userAddress ?? this.userAddress,
      isLoading: isLoading ?? this.isLoading,
      isTrackingLocation: isTrackingLocation ?? this.isTrackingLocation,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      isRouteLoading: isRouteLoading ?? this.isRouteLoading,
      routeFailure: clearRouteFailure
          ? null
          : (routeFailure ?? this.routeFailure),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      route: clearRoute ? null : (route ?? this.route),
    );
  }

  @override
  List<Object?> get props => [
        target,
        driverPosition,
        pickupAddress,
        userAddress,
        isLoading,
        isTrackingLocation,
        hasLocationPermission,
        isRouteLoading,
        routeFailure,
        errorMessage,
        route,
      ];
}
