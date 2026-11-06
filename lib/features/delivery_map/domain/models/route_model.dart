import 'package:collection/collection.dart';
import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';

class RouteModel {
  final List<GeoPoint> points;
  final double distanceMeters;
  final double durationSeconds;
  final String? encodedPolyline;

  const RouteModel({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    this.encodedPolyline,
  });

  double get distanceKm => distanceMeters / 1000.0;

  int get durationMinutes => (durationSeconds / 60.0).ceil();

  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  String get formattedDuration {
    final mins = durationMinutes;
    if (mins < 60) {
      return '$mins min';
    }
    final hours = mins ~/ 60;
    final remMins = mins % 60;
    return remMins == 0 ? '$hours hr' : '$hours hr $remMins min';
  }

  RouteModel copyWith({
    List<GeoPoint>? points,
    double? distanceMeters,
    double? durationSeconds,
    String? encodedPolyline,
    bool clearPolyline = false,
  }) {
    return RouteModel(
      points: points ?? this.points,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      encodedPolyline: clearPolyline
          ? null
          : (encodedPolyline ?? this.encodedPolyline),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteModel &&
          runtimeType == other.runtimeType &&
          const ListEquality<GeoPoint>().equals(points, other.points) &&
          distanceMeters == other.distanceMeters &&
          durationSeconds == other.durationSeconds &&
          encodedPolyline == other.encodedPolyline;

  @override
  int get hashCode => Object.hash(
        const ListEquality<GeoPoint>().hash(points),
        distanceMeters,
        durationSeconds,
        encodedPolyline,
      );

  @override
  String toString() =>
      'RouteModel(points: ${points.length}, distance: $formattedDistance, duration: $formattedDuration)';
}
