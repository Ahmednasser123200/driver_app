import 'package:driver_app/features/order_details/domain/entities/order_status.dart';
import 'package:driver_app/features/order_details/presentation/utils/order_status_helper.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('OrderStatusExtension', () {
    test('step returns correct step for each status', () {
      expect(OrderStatus.pending.step, 1);
      expect(OrderStatus.accepted.step, 2);
      expect(OrderStatus.assigned.step, 2);
      expect(OrderStatus.onTheWay.step, 3);
      expect(OrderStatus.outForDelivery.step, 3);
      expect(OrderStatus.inProgress.step, 3);
      expect(OrderStatus.pickedUp.step, 4);
      expect(OrderStatus.picked.step, 4);
      expect(OrderStatus.arrived.step, 4);
    });

    test('getLocalizedStatus returns localized string for each status', () {
      expect(OrderStatus.pending.getLocalizedStatus(l10n), l10n.pending);
      expect(OrderStatus.accepted.getLocalizedStatus(l10n), l10n.accepted);
      expect(OrderStatus.assigned.getLocalizedStatus(l10n), l10n.accepted);
      expect(OrderStatus.pickedUp.getLocalizedStatus(l10n), l10n.picked);
      expect(OrderStatus.picked.getLocalizedStatus(l10n), l10n.picked);
      expect(
        OrderStatus.onTheWay.getLocalizedStatus(l10n),
        l10n.outForDelivery,
      );
      expect(
        OrderStatus.outForDelivery.getLocalizedStatus(l10n),
        l10n.outForDelivery,
      );
      expect(
        OrderStatus.inProgress.getLocalizedStatus(l10n),
        l10n.outForDelivery,
      );
      expect(OrderStatus.arrived.getLocalizedStatus(l10n), l10n.arrived);
    });

    test('nextStatus returns expected transition', () {
      expect(OrderStatus.pending.nextStatus, 'accepted');
      expect(OrderStatus.accepted.nextStatus, 'on_the_way');
      expect(OrderStatus.assigned.nextStatus, 'on_the_way');
      expect(OrderStatus.onTheWay.nextStatus, 'arrived');
      expect(OrderStatus.outForDelivery.nextStatus, 'arrived');
      expect(OrderStatus.inProgress.nextStatus, 'arrived');
      expect(OrderStatus.pickedUp.nextStatus, 'on_the_way');
      expect(OrderStatus.picked.nextStatus, 'on_the_way');
      expect(OrderStatus.arrived.nextStatus, 'on_the_way');
    });

    test('getNextStatusLabel returns correct localized label', () {
      expect(OrderStatus.pending.getNextStatusLabel(l10n), l10n.accepted);
      expect(OrderStatus.accepted.getNextStatusLabel(l10n), l10n.outForDelivery);
      expect(OrderStatus.assigned.getNextStatusLabel(l10n), l10n.outForDelivery);
      expect(OrderStatus.onTheWay.getNextStatusLabel(l10n), l10n.arrived);
      expect(OrderStatus.outForDelivery.getNextStatusLabel(l10n), l10n.arrived);
      expect(OrderStatus.inProgress.getNextStatusLabel(l10n), l10n.arrived);
      expect(OrderStatus.pickedUp.getNextStatusLabel(l10n), l10n.startDeliver);
      expect(OrderStatus.picked.getNextStatusLabel(l10n), l10n.startDeliver);
      expect(OrderStatus.arrived.getNextStatusLabel(l10n), l10n.startDeliver);
    });

    test('shouldTrackLocation correctly flags active delivery statuses', () {
      expect(OrderStatus.pickedUp.shouldTrackLocation, isTrue);
      expect(OrderStatus.picked.shouldTrackLocation, isTrue);
      expect(OrderStatus.onTheWay.shouldTrackLocation, isTrue);
      expect(OrderStatus.outForDelivery.shouldTrackLocation, isTrue);
      expect(OrderStatus.inProgress.shouldTrackLocation, isTrue);

      expect(OrderStatus.pending.shouldTrackLocation, isFalse);
      expect(OrderStatus.accepted.shouldTrackLocation, isFalse);
      expect(OrderStatus.assigned.shouldTrackLocation, isFalse);
      expect(OrderStatus.arrived.shouldTrackLocation, isFalse);
    });
  });

  group('OrderStatusStringExtension', () {
    test('isTerminalStatus identifies terminal statuses with normalization', () {
      expect('arrived'.isTerminalStatus, isTrue);
      expect('Arrived'.isTerminalStatus, isTrue);
      expect('delivered'.isTerminalStatus, isTrue);
      expect('Delivered'.isTerminalStatus, isTrue);
      expect('awaiting_delivery_confirmation'.isTerminalStatus, isTrue);
      expect('awaiting-delivery-confirmation'.isTerminalStatus, isTrue);
      expect('cancelled'.isTerminalStatus, isTrue);

      expect('on_the_way'.isTerminalStatus, isFalse);
      expect('pending'.isTerminalStatus, isFalse);
      expect('accepted'.isTerminalStatus, isFalse);
    });

    test('isInTransitStatus identifies in-transit statuses with normalization', () {
      expect('ontheway'.isInTransitStatus, isTrue);
      expect('on_the_way'.isInTransitStatus, isTrue);
      expect('On-The-Way'.isInTransitStatus, isTrue);
      expect('out_for_delivery'.isInTransitStatus, isTrue);
      expect('picked_up'.isInTransitStatus, isTrue);
      expect('in_progress'.isInTransitStatus, isTrue);

      expect('arrived'.isInTransitStatus, isFalse);
      expect('delivered'.isInTransitStatus, isFalse);
      expect('cancelled'.isInTransitStatus, isFalse);
      expect('pending'.isInTransitStatus, isFalse);
    });
  });
}
