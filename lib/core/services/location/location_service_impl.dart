import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

import 'geolocator_wrapper.dart';
import 'location_service.dart';

@LazySingleton(as: LocationService)
class LocationServiceImpl implements LocationService {
  LocationServiceImpl(this._geolocatorWrapper) {
    _locationController = StreamController<Position>.broadcast(
      onListen: _onStreamListen,
      onCancel: _onStreamCancel,
    );
  }

  final GeolocatorWrapper _geolocatorWrapper;
  late final StreamController<Position> _locationController;
  StreamSubscription<Position>? _geolocatorSubscription;

  @override
  Stream<Position> get locationStream => _locationController.stream;

  @override
  Future<bool> isLocationServiceEnabled() =>
      _geolocatorWrapper.isLocationServiceEnabled();

  @override
  Future<LocationPermission> checkPermission() =>
      _geolocatorWrapper.checkPermission();

  @override
  Future<LocationPermission> requestPermission() =>
      _geolocatorWrapper.requestPermission();

  @override
  Future<bool> checkAndRequestPermission() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    if (_locationController.hasListener && _geolocatorSubscription == null) {
      await _startListening();
    }

    return true;
  }

  @override
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) return null;

    try {
      return await _geolocatorWrapper.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  void _onStreamListen() {
    _startListening();
  }

  void _onStreamCancel() {
    if (!_locationController.hasListener) {
      _stopListening();
    }
  }

  Future<void> _startListening() async {
    if (_geolocatorSubscription != null) return;

    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) return;

    final permission = await checkPermission();
    final isAllowed =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    if (!isAllowed) return;

    _geolocatorSubscription = _geolocatorWrapper
        .getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        )
        .listen(_locationController.add, onError: _locationController.addError);
  }

  void _stopListening() {
    _geolocatorSubscription?.cancel();
    _geolocatorSubscription = null;
  }

  @override
  Future<void> dispose() async {
    _stopListening();
    if (!_locationController.isClosed) {
      await _locationController.close();
    }
  }
}
