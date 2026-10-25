import 'dart:async';

import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/pickup_location/domain/entities/driving_route.dart';
import 'package:driver_app/features/pickup_location/domain/params/driving_route_params.dart';
import 'package:driver_app/features/pickup_location/domain/usecases/get_driving_route_use_case.dart';
import 'package:driver_app/features/pickup_location/presentation/manager/cubit/pickup_location_state.dart';
import 'package:injectable/injectable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';

@injectable
class PickupLocationCubit extends BaseCubit<PickupLocationState, BaseUiEvent> {
  PickupLocationCubit(this._getDrivingRouteUseCase)
    : super(const PickupLocationState());

  final GetDrivingRouteUseCase _getDrivingRouteUseCase;

  Future<void> loadCurrentLocation() async {
    emit(
      state.copyWith(
        currentLocation: state.currentLocation.copyWith(
          isLoading: true,
          errorMessage: null,
        ),
      ),
    );

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _emitLocationFailure(const LocationServiceDisabledFailure());
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _emitLocationFailure(const LocationPermissionFailure());
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      emit(
        state.copyWith(
          currentLocation: state.currentLocation.copyWith(
            isLoading: false,
            data: LatLng(position.latitude, position.longitude),
            errorMessage: null,
          ),
        ),
      );
    } on LocationServiceDisabledException {
      _emitLocationFailure(const LocationServiceDisabledFailure());
    } on PermissionDeniedException {
      _emitLocationFailure(const LocationPermissionFailure());
    } on PermissionDefinitionsNotFoundException {
      _emitLocationFailure(const LocationPermissionFailure());
    } on TimeoutException {
      _emitLocationFailure(const LocationUnavailableFailure());
    } on PlatformException {
      _emitLocationFailure(const UnknownFailure());
    }
  }

  void _emitLocationFailure(AppFailure failure) {
    emit(
      state.copyWith(
        currentLocation: state.currentLocation.copyWith(
          isLoading: false,
          data: null,
          errorMessage: failure,
        ),
      ),
    );
    emitEvent(ShowFailureMessage(failure));
  }

  /// Loads the driving route between the pickup and the customer location.
  Future<void> loadDrivingRoute(DrivingRouteParams params) async {
    emit(
      state.copyWith(
        drivingRoute: state.drivingRoute.copyWith(
          isLoading: true,
          errorMessage: null,
        ),
      ),
    );

    final result = await _getDrivingRouteUseCase.execute(params);

    switch (result) {
      case Success<DrivingRoute>():
        emit(
          state.copyWith(
            drivingRoute: state.drivingRoute.copyWith(
              isLoading: false,
              data: result.data,
              errorMessage: null,
            ),
          ),
        );

      case Error<DrivingRoute>():
        emit(
          state.copyWith(
            drivingRoute: state.drivingRoute.copyWith(
              isLoading: false,
              errorMessage: result.failure,
            ),
          ),
        );

        emitEvent(ShowFailureMessage(result.failure));
    }
  }
}
