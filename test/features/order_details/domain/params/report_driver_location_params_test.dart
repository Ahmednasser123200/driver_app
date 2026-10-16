import 'package:driver_app/features/order_details/domain/params/report_driver_location_params.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReportDriverLocationParams', () {
    test('supports value equality', () {
      const p1 = ReportDriverLocationParams(
        lat: 30.0444,
        lng: 31.2357,
        recordedAt: '2026-09-19T18:00:00Z',
      );
      const p2 = ReportDriverLocationParams(
        lat: 30.0444,
        lng: 31.2357,
        recordedAt: '2026-09-19T18:00:00Z',
      );
      const p3 = ReportDriverLocationParams(
        lat: 30.0500,
        lng: 31.2357,
        recordedAt: '2026-09-19T18:00:00Z',
      );

      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
      expect(p1.props, [30.0444, 31.2357, '2026-09-19T18:00:00Z']);
    });
  });
}
