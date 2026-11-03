import 'package:collection/collection.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteModel {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final String? encodedPolyline;

  const RouteModel({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    this.encodedPolyline,
  });

  String get formattedDistance {
    if (distanceMeters >= 1000) {
      final km = distanceMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
    return '${distanceMeters.round()} m';
  }

  String get formattedDuration {
    final totalMinutes = (durationSeconds / 60).round();
    if (totalMinutes >= 60) {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      if (minutes == 0) return '$hours hr';
      return '$hours hr $minutes min';
    }
    return '$totalMinutes min';
  }

  RouteModel copyWith({
    List<LatLng>? points,
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
          const ListEquality<LatLng>().equals(points, other.points) &&
          distanceMeters == other.distanceMeters &&
          durationSeconds == other.durationSeconds &&
          encodedPolyline == other.encodedPolyline;

  @override
  int get hashCode => Object.hash(
        const ListEquality<LatLng>().hash(points),
        distanceMeters,
        durationSeconds,
        encodedPolyline,
      );

  @override
  String toString() =>
      'RouteModel(points: ${points.length}, distance: $formattedDistance, duration: $formattedDuration)';
}
