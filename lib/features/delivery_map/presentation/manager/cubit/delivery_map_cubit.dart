import 'dart:async';
import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/core/services/location/location_service.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_driver_location_stream_use_case.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_route_use_case.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_event.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_state.dart';
import 'package:driver_app/features/delivery_map/presentation/utils/map_marker_generator.dart';
import 'package:driver_app/features/delivery_map/presentation/utils/polyline_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

@injectable
class DeliveryMapCubit extends BaseCubit<DeliveryMapState, DeliveryMapUiEvent> {
  DeliveryMapCubit({
    required this.getDriverLocationStreamUseCase,
    required this.locationService,
    required this.getRouteUseCase,
  }) : super(const DeliveryMapState());

  final GetDriverLocationStreamUseCase getDriverLocationStreamUseCase;
  final LocationService locationService;
  final GetRouteUseCase getRouteUseCase;

  StreamSubscription<Position>? _driverLocationSubscription;
  LatLng? _lastRoutedDriverPosition;

  Future<void> doEvent(DeliveryMapEvent event) async {
    switch (event) {
      case InitDeliveryMapEvent():
        await _onInit(event);

      case SwitchTargetEvent():
        await _onSwitchTarget(event.target);

      case StartDriverLocationTrackingEvent():
        await _startLocationTracking();

      case StopDriverLocationTrackingEvent():
        await _stopLocationTracking();

      case DriverPositionUpdatedEvent():
        await _onDriverPositionUpdated(event.position);

      case CallPhoneEvent():
        await _callPhone(event.phoneNumber);

      case OpenWhatsAppEvent():
        await _openWhatsApp(event.phoneNumber);
    }
  }

  Future<void> _onInit(InitDeliveryMapEvent event) async {
    emit(
      state.copyWith(
        pickupAddress: event.pickupAddress ?? state.pickupAddress,
        userAddress: event.userAddress ?? state.userAddress,
        target: event.initialTarget ?? state.target,
        isLoading: true,
      ),
    );

    await _fetchRoute(force: true);
    await _updateMapOverlays();
    await _startLocationTracking();

    emit(state.copyWith(isLoading: false));
  }

  Future<void> _onSwitchTarget(DeliveryMapTarget target) async {
    if (state.target == target) return;

    emit(state.copyWith(target: target));
    await _fetchRoute(force: true);
    await _updateMapOverlays();
  }

  Future<void> _fetchRoute({bool force = false}) async {
    final origin = state.driverPosition;
    final destination = state.destinationLatLng;

    if (!force && _lastRoutedDriverPosition != null) {
      final distance = PolylineHelper.calculateHaversineDistance(
        _lastRoutedDriverPosition!,
        origin,
      );
      if (distance < 40.0 && state.route != null) {
        return;
      }
    }

    emit(state.copyWith(isRouteLoading: true));

    final result = await getRouteUseCase(
      origin: origin,
      destination: destination,
    );

    switch (result) {
      case Success(:final data):
        _lastRoutedDriverPosition = origin;
        emit(state.copyWith(route: data, isRouteLoading: false));
      case Error():
        emit(state.copyWith(isRouteLoading: false));
    }
  }

  Future<void> _startLocationTracking() async {
    final hasPermission = await locationService.checkAndRequestPermission();

    if (!hasPermission) {
      emit(
        state.copyWith(
          hasLocationPermission: false,
          isTrackingLocation: false,
        ),
      );
      emitEvent(const DeliveryMapLocationPermissionDenied());
      return;
    }

    emit(
      state.copyWith(
        hasLocationPermission: true,
        isTrackingLocation: true,
      ),
    );

    final currentPosition = await locationService.getCurrentPosition();
    if (currentPosition != null) {
      final newDriverPosition = LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      );
      emit(state.copyWith(driverPosition: newDriverPosition));
      await _fetchRoute(force: false);
      await _updateMapOverlays();
    }

    await _driverLocationSubscription?.cancel();
    _driverLocationSubscription = getDriverLocationStreamUseCase().listen(
      (position) {
        doEvent(DriverPositionUpdatedEvent(position));
      },
      onError: (error) {
        if (error is LocationServiceDisabledException) {
          emitEvent(const DeliveryMapLocationServiceDisabled());
        }
      },
    );
  }

  Future<void> _stopLocationTracking() async {
    await _driverLocationSubscription?.cancel();
    _driverLocationSubscription = null;
    emit(state.copyWith(isTrackingLocation: false));
  }

  Future<void> _onDriverPositionUpdated(Position position) async {
    final newDriverPosition = LatLng(position.latitude, position.longitude);
    emit(state.copyWith(driverPosition: newDriverPosition));
    await _fetchRoute(force: false);
    await _updateMapOverlays();
  }

  Future<void> _updateMapOverlays() async {
    final markers = await _buildMarkers();
    final polylines = _buildPolylines();
    debugPrint(
      'DeliveryMapCubit: Updated overlays with ${markers.length} markers and ${polylines.length} polylines',
    );
    emit(state.copyWith(markers: markers, polylines: polylines));
  }

  Future<Set<Marker>> _buildMarkers() async {
    final destination = state.destinationLatLng;
    final isPickup = state.target.isPickup;

    final driverIcon = await MapMarkerGenerator.createPillMarker(
      label: 'Your location',
      icon: Icons.navigation_rounded,
    );

    final destIcon = await MapMarkerGenerator.createPillMarker(
      label: isPickup ? 'Flowery' : 'User',
      icon: isPickup ? Icons.local_florist_rounded : Icons.person_rounded,
    );

    return <Marker>{
      Marker(
        markerId: const MarkerId('driver_marker'),
        position: state.driverPosition,
        icon: driverIcon,
        infoWindow: const InfoWindow(title: 'Your location'),
        anchor: const Offset(0.5, 0.5),
      ),
      Marker(
        markerId: MarkerId(isPickup ? 'pickup_marker' : 'user_marker'),
        position: destination,
        icon: destIcon,
        infoWindow: InfoWindow(
          title: isPickup ? state.pickupAddress.title : state.userAddress.title,
        ),
        anchor: const Offset(0.5, 0.5),
      ),
    };
  }

  Set<Polyline> _buildPolylines() {
    final routePoints = state.route?.points;
    final polyline = PolylineHelper.buildRoutePolyline(
      id: 'active_delivery_route',
      points: routePoints,
      start: state.driverPosition,
      end: state.destinationLatLng,
    );

    return <Polyline>{polyline};
  }

  Future<void> _callPhone(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return;

    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        emitEvent(DeliveryMapLaunchUrlFailed(uri.toString()));
      }
    } catch (_) {
      emitEvent(DeliveryMapLaunchUrlFailed(uri.toString()));
    }
  }

  Future<void> _openWhatsApp(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return;

    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$digitsOnly');

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        emitEvent(DeliveryMapLaunchUrlFailed(uri.toString()));
      }
    } catch (_) {
      emitEvent(DeliveryMapLaunchUrlFailed(uri.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _driverLocationSubscription?.cancel();
    return super.close();
  }
}
