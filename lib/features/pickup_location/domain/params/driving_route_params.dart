import 'package:equatable/equatable.dart';

import '../entities/map_location.dart';

class DrivingRouteParams extends Equatable {
  const DrivingRouteParams({required this.origin, required this.destination});

  final MapLocation origin;
  final MapLocation destination;

  @override
  List<Object?> get props => [origin, destination];
}
