import 'package:equatable/equatable.dart';

/// A geographic coordinate used by the pickup location feature.
class MapLocation extends Equatable {
  const MapLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  /// `true` when the coordinate is inside the valid latitude/longitude
  /// ranges and is not the null island `(0, 0)` placeholder.
  bool get isValid {
    final isValidLatitude = latitude >= -90 && latitude <= 90;
    final isValidLongitude = longitude >= -180 && longitude <= 180;

    return isValidLatitude && isValidLongitude && !isNullIsland;
  }

  /// The `(0, 0)` coordinate is treated as "location unavailable".
  bool get isNullIsland => latitude == 0 && longitude == 0;

  @override
  List<Object?> get props => [latitude, longitude];
}
