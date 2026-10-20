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

 
Future<void>? _startingListening;

Future<void> _startListening() {
  if (_geolocatorSubscription != null) {
    return Future<void>.value();
  }

  if (_startingListening != null) {
    return _startingListening!;
  }

  final future = _startListeningInternal();
  _startingListening = future;

  return future.whenComplete(() {
    _startingListening = null;
  });
}

Future<void> _startListeningInternal() async {

}


  void _stopListening() {
    _geolocatorSubscription?.cancel();
    _geolocatorSubscription = null;
  }
  @disposeMethod
  @override
  Future<void> dispose() async {
    _stopListening();
    if (!_locationController.isClosed) {
      await _locationController.close();
    }
  }
}
