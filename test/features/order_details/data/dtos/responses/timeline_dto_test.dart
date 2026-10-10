import 'package:driver_app/features/order_details/data/dtos/responses/timeline_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fixtures.dart';

void main() {
  Map<String, dynamic> json() => <String, dynamic>{
    'status': 'Placed',
    'timestamp': '2026-09-19T17:00:00Z',
  };

  group('fromJson', () {
    test('parses all fields', () {
      final dto = TimelineDto.fromJson(json());

      expect(dto.status, 'Placed');
      expect(dto.timestamp, '2026-09-19T17:00:00Z');
    });

    test('keeps the timestamp as an opaque string', () {
      final dto = TimelineDto.fromJson(json()..['timestamp'] = 'not-a-date');

      expect(dto.timestamp, 'not-a-date');
    });
  });

  group('toJson', () {
    test('emits the expected keys', () {
      expect(
        buildTimelineDto().toJson().keys.toSet(),
        {'status', 'timestamp'},
      );
    });

    test('round-trips through fromJson', () {
      final original = buildTimelineDto();

      expect(TimelineDto.fromJson(original.toJson()).toJson(), original.toJson());
    });
  });

  group('toDomain', () {
    test('maps every field onto the entity', () {
      final entity = buildTimelineDto().toDomain();

      expect(entity.status, 'Placed');
      expect(entity.timestamp, '2026-09-19T17:00:00Z');
    });

    test('honours the fixture builder overrides', () {
      final entity = buildTimelineDto(
        status: 'Delivered',
        timestamp: '2026-09-19T19:00:00Z',
      ).toDomain();

      expect(entity.status, 'Delivered');
      expect(entity.timestamp, '2026-09-19T19:00:00Z');
    });
  });
}