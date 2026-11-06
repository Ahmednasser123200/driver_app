import 'dart:async';

import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/core/services/url_launcher/url_launcher_service.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/check_location_permission_use_case.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_current_driver_location_use_case.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_driver_location_stream_use_case.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_route_use_case.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_event.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_state.dart';
import 'package:driver_app/features/order_details/domain/entities/user_location_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeliveryMapCubit extends BaseCubit<DeliveryMapState, DeliveryMapUiEvent> {
  DeliveryMapCubit({
    required this.getDriverLocationStreamUseCase,
    required this.checkLocationPermissionUseCase,
    required this.getCurrentDriverLocationUseCase,
    required this.getRouteUseCase,
    required this.urlLauncherService,
  }) : super(const DeliveryMapState());

  final GetDriverLocationStreamUseCase getDriverLocationStreamUseCase;
  final CheckLocationPermissionUseCase checkLocationPermissionUseCase;
  final GetCurrentDriverLocationUseCase getCurrentDriverLocationUseCase;
  final GetRouteUseCase getRouteUseCase;
  final UrlLauncherService urlLauncherService;

  StreamSubscription<BaseResponse<UserLocationEntity>>?
      _driverLocationSubscription;
  GeoPoint? _lastRoutedDriverPosition;

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
        driverPosition: event.initialDriverPosition ?? state.driverPosition,
        isLoading: true,
      ),
    );

    await _startLocationTracking(fetchRouteOnFix: false);
    await _fetchRoute(force: true);

    emit(state.copyWith(isLoading: false));
    emitEvent(const DeliveryMapFitBounds());
  }

  Future<void> _onSwitchTarget(DeliveryMapTarget target) async {
    if (state.target == target) return;

    emit(state.copyWith(target: target));
    await _fetchRoute(force: true);
    emitEvent(const DeliveryMapFitBounds());
  }

  Future<void> _fetchRoute({bool force = false}) async {
    final origin = state.driverPosition;
    final destination = state.destinationPosition;

    if (origin == null || destination == null) {
      return;
    }

    if (!force && _lastRoutedDriverPosition != null) {
      final distance = _lastRoutedDriverPosition!.distanceTo(origin);
      if (distance < 40.0 && state.route != null) {
        return;
      }
    }

    emit(state.copyWith(isRouteLoading: true, clearRouteFailure: true));

    final result = await getRouteUseCase(
      origin: origin,
      destination: destination,
    );

    switch (result) {
      case Success<RouteModel>(:final data):
        _lastRoutedDriverPosition = origin;
        emit(
          state.copyWith(
            route: data,
            isRouteLoading: false,
            clearRouteFailure: true,
          ),
        );
      case Error<RouteModel>(:final failure):
        emit(
          state.copyWith(
            isRouteLoading: false,
            routeFailure: failure,
            clearRoute: true,
          ),
        );
    }
  }

  Future<void> _startLocationTracking({bool fetchRouteOnFix = true}) async {
    final hasPermission = await checkLocationPermissionUseCase();

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

    final currentLocationResult = await getCurrentDriverLocationUseCase();
    if (currentLocationResult is Success<UserLocationEntity?> &&
        currentLocationResult.data != null) {
      final currentLocation = currentLocationResult.data!;
      final newDriverPosition = GeoPoint(
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      );
      emit(state.copyWith(driverPosition: newDriverPosition));
      if (fetchRouteOnFix) {
        await _fetchRoute(force: false);
        emitEvent(const DeliveryMapFitBounds());
      }
    }

    await _driverLocationSubscription?.cancel();
    _driverLocationSubscription = getDriverLocationStreamUseCase().listen(
      (response) {
        switch (response) {
          case Success<UserLocationEntity>(:final data):
            doEvent(
              DriverPositionUpdatedEvent(
                GeoPoint(
                  latitude: data.latitude,
                  longitude: data.longitude,
                ),
              ),
            );
          case Error<UserLocationEntity>(:final failure):
            if (failure is LocationServiceDisabledFailure) {
              emitEvent(const DeliveryMapLocationServiceDisabled());
            } else if (failure is LocationPermissionFailure) {
              emitEvent(const DeliveryMapLocationPermissionDenied());
            }
        }
      },
    );
  }

  Future<void> _stopLocationTracking() async {
    await _driverLocationSubscription?.cancel();
    _driverLocationSubscription = null;
    emit(state.copyWith(isTrackingLocation: false));
  }

  Future<void> _onDriverPositionUpdated(GeoPoint position) async {
    emit(state.copyWith(driverPosition: position));
    await _fetchRoute(force: false);
    emitEvent(const DeliveryMapFitBounds());
  }

  Future<void> _callPhone(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return;

    final launched = await urlLauncherService.callPhone(phoneNumber);
    if (!launched) {
      emitEvent(DeliveryMapLaunchUrlFailed(phoneNumber));
    }
  }

  Future<void> _openWhatsApp(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return;

    final launched = await urlLauncherService.openWhatsApp(phoneNumber);
    if (!launched) {
      emitEvent(DeliveryMapLaunchUrlFailed(phoneNumber));
    }
  }

  @override
  Future<void> close() async {
    await _driverLocationSubscription?.cancel();
    return super.close();
  }
}
