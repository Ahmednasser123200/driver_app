import 'package:driver_app/features/order_details/data/dtos/responses/report_driver_location_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fixtures.dart';

void main() {
  Map<String, dynamic> json() => <String, dynamic>{
    'success': true,
    'recordedAt': '2026-09-19T18:00:00Z',
  };

  group('fromJson', () {
    test('parses all fields', () {
      final dto = ReportDriverLocationResponseDto.fromJson(json());

      expect(dto.success, isTrue);
      expect(dto.recordedAt, '2026-09-19T18:00:00Z');
    });

    test('parses a false success flag', () {
      expect(
        ReportDriverLocationResponseDto.fromJson(json()..['success'] = false)
            .success,
        isFalse,
      );
    });
  });

  group('toJson', () {
    test('emits the expected keys', () {
      expect(
        buildReportDriverLocationResponseDto().toJson().keys.toSet(),
        {'success', 'recordedAt'},
      );
    });

    test('round-trips through fromJson', () {
      final original = buildReportDriverLocationResponseDto();

      expect(
        ReportDriverLocationResponseDto.fromJson(original.toJson()).toJson(),
        original.toJson(),
      );
    });
  });

  group('toDomain', () {
    test('maps every field onto the entity', () {
      final entity = buildReportDriverLocationResponseDto().toDomain();

      expect(entity.success, isTrue);
      expect(entity.recordedAt, '2026-09-19T18:00:00Z');
    });

    test('keeps a false success flag on the entity', () {
      final entity = ReportDriverLocationResponseDto.fromJson(
        json()..['success'] = false,
      ).toDomain();

      expect(entity.success, isFalse);
    });
  });
}