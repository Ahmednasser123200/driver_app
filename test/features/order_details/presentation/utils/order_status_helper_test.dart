import 'package:driver_app/features/order_details/domain/entities/driver_status_update.dart';
import 'package:driver_app/features/order_details/domain/entities/order_status.dart';
import 'package:driver_app/features/order_details/presentation/utils/order_status_helper.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('nextStatus', () {
    test('follows Preparing -> PickedUp -> OutForDelivery -> Awaiting', () {
      expect(OrderStatus.pending.nextStatus, DriverStatusUpdate.pickedUp);
      expect(
        OrderStatus.pickedUp.nextStatus,
        DriverStatusUpdate.outForDelivery,
      );
      expect(
        OrderStatus.outForDelivery.nextStatus,
        DriverStatusUpdate.awaitingDeliveryConfirmation,
      );
    });

    test('exposes no driver action once the order awaits the customer', () {
      expect(OrderStatus.arrived.nextStatus, isNull);
      expect(OrderStatus.delivered.nextStatus, isNull);
      expect(OrderStatus.cancelled.nextStatus, isNull);
    });

    test('never asks the backend to accept an order through this endpoint', () {
      for (final status in OrderStatus.values) {
        expect(status.nextStatus?.wireValue, isNot('accepted'));
        expect(status.nextStatus?.wireValue, isNot('Accepted'));
      }
    });

    test('keeps the legacy aliases on the same driver flow', () {
      expect(OrderStatus.accepted.nextStatus, DriverStatusUpdate.pickedUp);
      expect(OrderStatus.assigned.nextStatus, DriverStatusUpdate.pickedUp);
      expect(OrderStatus.picked.nextStatus, DriverStatusUpdate.outForDelivery);
      expect(
        OrderStatus.onTheWay.nextStatus,
        DriverStatusUpdate.awaitingDeliveryConfirmation,
      );
      expect(
        OrderStatus.inProgress.nextStatus,
        DriverStatusUpdate.awaitingDeliveryConfirmation,
      );
    });
  });

  group('getNextStatusLabel', () {
    test('names the status the action moves the order to', () {
      expect(OrderStatus.pending.getNextStatusLabel(l10n), l10n.picked);
      expect(
        OrderStatus.pickedUp.getNextStatusLabel(l10n),
        l10n.outForDelivery,
      );
      expect(OrderStatus.outForDelivery.getNextStatusLabel(l10n), l10n.arrived);
    });

    test('has a label for every status', () {
      for (final status in OrderStatus.values) {
        expect(status.getNextStatusLabel(l10n), isNotEmpty);
      }
    });
  });

  group('step', () {
    test('tracks the backend delivery flow', () {
      expect(OrderStatus.pending.step, 1);
      expect(OrderStatus.pickedUp.step, 2);
      expect(OrderStatus.outForDelivery.step, 3);
      expect(OrderStatus.arrived.step, 4);
      expect(OrderStatus.delivered.step, 5);
    });
  });
}
