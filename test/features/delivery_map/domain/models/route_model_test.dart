import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('RouteModel', () {
    const samplePoints = <LatLng>[
      LatLng(30.0, 31.0),
      LatLng(30.1, 31.1),
    ];

    test('constructor assigns all fields correctly', () {
      const model = RouteModel(
        points: samplePoints,
        distanceMeters: 1500.0,
        durationSeconds: 300.0,
        encodedPolyline: 'sample_encoded',
      );

      expect(model.points, samplePoints);
      expect(model.distanceMeters, 1500.0);
      expect(model.durationSeconds, 300.0);
      expect(model.encodedPolyline, 'sample_encoded');
    });

    test('formattedDistance formats meters and kilometers accurately', () {
      const underOneKm = RouteModel(
        points: samplePoints,
        distanceMeters: 750.4,
        durationSeconds: 60.0,
      );
      expect(underOneKm.formattedDistance, '750 m');

      const overOneKm = RouteModel(
        points: samplePoints,
        distanceMeters: 4250.0,
        durationSeconds: 600.0,
      );
      expect(overOneKm.formattedDistance, '4.3 km');
    });

    test('formattedDuration formats minutes and hours accurately', () {
      const shortRoute = RouteModel(
        points: samplePoints,
        distanceMeters: 1000.0,
        durationSeconds: 720.0, // 12 mins
      );
      expect(shortRoute.formattedDuration, '12 min');

      const exactHoursRoute = RouteModel(
        points: samplePoints,
        distanceMeters: 1000.0,
        durationSeconds: 7200.0, // 2 hours
      );
      expect(exactHoursRoute.formattedDuration, '2 hr');

      const mixedHoursRoute = RouteModel(
        points: samplePoints,
        distanceMeters: 1000.0,
        durationSeconds: 4500.0, // 75 mins = 1 hr 15 min
      );
      expect(mixedHoursRoute.formattedDuration, '1 hr 15 min');
    });

    test('copyWith updates specified fields and preserves untouched ones', () {
      const original = RouteModel(
        points: samplePoints,
        distanceMeters: 1000.0,
        durationSeconds: 600.0,
        encodedPolyline: 'poly',
      );

      final updated = original.copyWith(
        distanceMeters: 2000.0,
        clearPolyline: true,
      );

      expect(updated.points, samplePoints);
      expect(updated.distanceMeters, 2000.0);
      expect(updated.durationSeconds, 600.0);
      expect(updated.encodedPolyline, isNull);

      final untouched = original.copyWith();
      expect(untouched, original);
    });

    test('equality and hashCode adhere to value semantics', () {
      const modelA = RouteModel(
        points: samplePoints,
        distanceMeters: 1000.0,
        durationSeconds: 600.0,
        encodedPolyline: 'poly',
      );

      const modelB = RouteModel(
        points: <LatLng>[
          LatLng(30.0, 31.0),
          LatLng(30.1, 31.1),
        ],
        distanceMeters: 1000.0,
        durationSeconds: 600.0,
        encodedPolyline: 'poly',
      );

      const modelDifferent = RouteModel(
        points: samplePoints,
        distanceMeters: 2000.0,
        durationSeconds: 600.0,
      );

      expect(modelA, equals(modelB));
      expect(modelA.hashCode, equals(modelB.hashCode));
      expect(modelA, isNot(equals(modelDifferent)));
      expect(modelA.toString(), contains('RouteModel'));
    });
  });
}
