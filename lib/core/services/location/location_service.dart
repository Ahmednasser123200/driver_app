import 'package:geolocator/geolocator.dart';

abstract interface class LocationService {
  Stream<Position> get locationStream;

  Future<bool> isLocationServiceEnabled();

  Future<LocationPermission> checkPermission();

  Future<LocationPermission> requestPermission();

  Future<bool> checkAndRequestPermission();

  Future<Position?> getCurrentPosition();

  Future<void> dispose();
}
