import 'package:equatable/equatable.dart';

import 'map_location.dart';

/// The driving route between the pickup location and the customer location.
class DrivingRoute extends Equatable {
  const DrivingRoute({
    required this.points,
    this.distanceMeters = 0,
    this.durationSeconds = 0,
  });

  /// The ordered list of coordinates that follow the road network.
  final List<MapLocation> points;

  final double distanceMeters;
  final double durationSeconds;

  bool get isEmpty => points.isEmpty;

  @override
  List<Object?> get props => [points, distanceMeters, durationSeconds];
}
