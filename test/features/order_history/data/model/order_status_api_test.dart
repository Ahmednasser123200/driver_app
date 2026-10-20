import 'package:driver_app/features/order_history/data/model/order_status_api.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('orderStatusFromApi', () {
    test('returns OrderStatus.completed when status is delivered (case insensitive)', () {
      expect(orderStatusFromApi('delivered'), OrderStatus.completed);
      expect(orderStatusFromApi('DELIVERED'), OrderStatus.completed);
      expect(orderStatusFromApi('Delivered'), OrderStatus.completed);
    });

    test('returns OrderStatus.cancelled when status is cancelled (case insensitive)', () {
      expect(orderStatusFromApi('cancelled'), OrderStatus.cancelled);
      expect(orderStatusFromApi('CANCELLED'), OrderStatus.cancelled);
      expect(orderStatusFromApi('Cancelled'), OrderStatus.cancelled);
    });

    test('returns null for active or unknown statuses', () {
      expect(orderStatusFromApi('pending'), isNull);
      expect(orderStatusFromApi('accepted'), isNull);
      expect(orderStatusFromApi('out_for_delivery'), isNull);
      expect(orderStatusFromApi('unknown'), isNull);
      expect(orderStatusFromApi(''), isNull);
    });
  });
}
