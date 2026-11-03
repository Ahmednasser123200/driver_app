import 'package:driver_app/features/delivery_map/domain/models/address_model.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryMapState extends Equatable {
  static const AddressModel defaultPickup = AddressModel(
    title: 'Flowery store',
    addressLine: '20th st, Sheikh Zayed, Giza',
    latitude: 30.0131,
    longitude: 31.2089,
    phoneNumber: '+201000000000',
  );

  static const AddressModel defaultUser = AddressModel(
    title: 'Nour mohamed',
    addressLine: '20th st, Sheikh Zayed, Giza',
    latitude: 30.0250,
    longitude: 31.2200,
    phoneNumber: '+201011111111',
  );

  static const LatLng defaultDriverPosition = LatLng(30.0190, 31.2140);

  final DeliveryMapTarget target;
  final LatLng driverPosition;
  final AddressModel pickupAddress;
  final AddressModel userAddress;
  final bool isLoading;
  final bool isTrackingLocation;
  final bool hasLocationPermission;
  final bool isRouteLoading;
  final String? errorMessage;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final RouteModel? route;

  const DeliveryMapState({
    this.target = DeliveryMapTarget.pickup,
    this.driverPosition = defaultDriverPosition,
    this.pickupAddress = defaultPickup,
    this.userAddress = defaultUser,
    this.isLoading = false,
    this.isTrackingLocation = false,
    this.hasLocationPermission = false,
    this.isRouteLoading = false,
    this.errorMessage,
    this.markers = const <Marker>{},
    this.polylines = const <Polyline>{},
    this.route,
  });

  AddressModel get activeDestinationAddress =>
      target.isPickup ? pickupAddress : userAddress;

  LatLng get destinationLatLng => LatLng(
        activeDestinationAddress.latitude,
        activeDestinationAddress.longitude,
      );

  DeliveryMapState copyWith({
    DeliveryMapTarget? target,
    LatLng? driverPosition,
    AddressModel? pickupAddress,
    AddressModel? userAddress,
    bool? isLoading,
    bool? isTrackingLocation,
    bool? hasLocationPermission,
    bool? isRouteLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    RouteModel? route,
    bool clearRoute = false,
  }) {
    return DeliveryMapState(
      target: target ?? this.target,
      driverPosition: driverPosition ?? this.driverPosition,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      userAddress: userAddress ?? this.userAddress,
      isLoading: isLoading ?? this.isLoading,
      isTrackingLocation: isTrackingLocation ?? this.isTrackingLocation,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      isRouteLoading: isRouteLoading ?? this.isRouteLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
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
        errorMessage,
        markers,
        polylines,
        route,
      ];
}
