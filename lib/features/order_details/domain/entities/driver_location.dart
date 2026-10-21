import 'package:equatable/equatable.dart';

class DriverLocation extends Equatable {
  final double latitude;
  final double longitude;

  const DriverLocation({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}