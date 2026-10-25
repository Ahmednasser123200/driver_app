import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReportDriverLocationEntity', () {
    test('supports value equality', () {
      const e1 = ReportDriverLocationEntity(
        success: true,
        recordedAt: '2026-09-19T18:00:00Z',
      );
      const e2 = ReportDriverLocationEntity(
        success: true,
        recordedAt: '2026-09-19T18:00:00Z',
      );
      const e3 = ReportDriverLocationEntity(
        success: false,
        recordedAt: '2026-09-19T18:00:00Z',
      );

      expect(e1, equals(e2));
      expect(e1, isNot(equals(e3)));
      expect(e1.props, [true, '2026-09-19T18:00:00Z']);
    });
  });
}
