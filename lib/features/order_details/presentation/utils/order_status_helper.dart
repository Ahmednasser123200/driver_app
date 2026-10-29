import 'package:driver_app/features/order_details/domain/entities/order_status.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';

extension OrderStatusExtension on OrderStatus {
  int get step {
    switch (this) {
      case OrderStatus.pending:
        return 1;

      case OrderStatus.accepted:
      case OrderStatus.assigned:
        return 2;

      case OrderStatus.onTheWay:
      case OrderStatus.outForDelivery:
      case OrderStatus.inProgress:
        return 3;

      case OrderStatus.pickedUp:
      case OrderStatus.picked:
      case OrderStatus.arrived:
        return 4;
    }
  }

  String getLocalizedStatus(AppLocalizations l10n) {
    switch (this) {
      case OrderStatus.pending:
        return l10n.pending;

      case OrderStatus.accepted:
      case OrderStatus.assigned:
        return l10n.accepted;

      case OrderStatus.pickedUp:
      case OrderStatus.picked:
        return l10n.picked;

      case OrderStatus.onTheWay:
      case OrderStatus.outForDelivery:
      case OrderStatus.inProgress:
        return l10n.outForDelivery;

      case OrderStatus.arrived:
        return l10n.arrived;
    }
  }

  String? get nextStatus {
    switch (this) {
      case OrderStatus.pending:
        return 'accepted';

      case OrderStatus.accepted:
      case OrderStatus.assigned:
        return 'on_the_way';

      case OrderStatus.onTheWay:
      case OrderStatus.outForDelivery:
      case OrderStatus.inProgress:
        return 'arrived';

      case OrderStatus.pickedUp:
      case OrderStatus.picked:
      case OrderStatus.arrived:
        return 'on_the_way';
    }
  }

  String getNextStatusLabel(AppLocalizations l10n) {
    switch (this) {
      case OrderStatus.pending:
        return l10n.accepted;

      case OrderStatus.accepted:
      case OrderStatus.assigned:
        return l10n.outForDelivery;

      case OrderStatus.onTheWay:
      case OrderStatus.outForDelivery:
      case OrderStatus.inProgress:
        return l10n.arrived;

      case OrderStatus.pickedUp:
      case OrderStatus.picked:
      case OrderStatus.arrived:
        return l10n.startDeliver;
    }
  }

  bool get shouldTrackLocation {
    switch (this) {
      case OrderStatus.pickedUp:
      case OrderStatus.picked:
      case OrderStatus.onTheWay:
      case OrderStatus.outForDelivery:
      case OrderStatus.inProgress:
        return true;
      case OrderStatus.pending:
      case OrderStatus.accepted:
      case OrderStatus.assigned:
      case OrderStatus.arrived:
        return false;
    }
  }
}

extension OrderStatusStringExtension on String {
  String get _normalizedStatus =>
      replaceAll(RegExp(r'[\s_-]+'), '').toLowerCase();

  bool get isTerminalStatus {
    final normalized = _normalizedStatus;
    return normalized == 'arrived' ||
        normalized == 'delivered' ||
        normalized == 'awaitingdeliveryconfirmation' ||
        normalized == 'cancelled';
  }

  bool get isInTransitStatus {
    final normalized = _normalizedStatus;
    return normalized == 'ontheway' ||
        normalized == 'outfordelivery' ||
        normalized == 'pickedup' ||
        normalized == 'inprogress';
  }
}
