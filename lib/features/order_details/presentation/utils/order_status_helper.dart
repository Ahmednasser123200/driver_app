import 'package:driver_app/features/order_details/domain/entities/driver_status_update.dart';
import 'package:driver_app/features/order_details/domain/entities/order_status.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';

extension OrderStatusExtension on OrderStatus {
  /// Step of the 5-step progress bar. The backend drives the order through
  /// `Preparing -> PickedUp -> OutForDelivery -> AwaitingDeliveryConfirmation
  /// -> Delivered`, so the steps follow that order.
  int get step {
    switch (this) {
      case OrderStatus.pending:
      case OrderStatus.cancelled:
        return 1;

      case OrderStatus.accepted:
      case OrderStatus.assigned:
      case OrderStatus.pickedUp:
      case OrderStatus.picked:
        return 2;

      case OrderStatus.onTheWay:
      case OrderStatus.outForDelivery:
      case OrderStatus.inProgress:
        return 3;

      case OrderStatus.arrived:
        return 4;

      case OrderStatus.delivered:
        return 5;
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

      case OrderStatus.delivered:
        return l10n.delivered;

      case OrderStatus.cancelled:
        return l10n.cancelled;
    }
  }

  /// The status sent to the backend when the driver taps the action, following
  /// the backend driver flow `PickedUp -> OutForDelivery ->
  /// AwaitingDeliveryConfirmation`. `null` means the order has no next driver
  /// action: it is either terminal or already awaiting the customer's
  /// confirmation (the order stays active for the driver until the customer
  /// confirms the delivery).
  DriverStatusUpdate? get nextStatus {
    switch (this) {
      case OrderStatus.pending:
      case OrderStatus.accepted:
      case OrderStatus.assigned:
        return DriverStatusUpdate.pickedUp;

      case OrderStatus.pickedUp:
      case OrderStatus.picked:
        return DriverStatusUpdate.outForDelivery;

      case OrderStatus.onTheWay:
      case OrderStatus.outForDelivery:
      case OrderStatus.inProgress:
        return DriverStatusUpdate.awaitingDeliveryConfirmation;

      case OrderStatus.arrived:
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return null;
    }
  }

  /// Label of the action button, i.e. the status the order moves to when it is
  /// tapped. Only meaningful while [nextStatus] is not `null`.
  String getNextStatusLabel(AppLocalizations l10n) {
    switch (this) {
      case OrderStatus.pending:
      case OrderStatus.accepted:
      case OrderStatus.assigned:
        return l10n.picked;

      case OrderStatus.pickedUp:
      case OrderStatus.picked:
        return l10n.outForDelivery;

      case OrderStatus.onTheWay:
      case OrderStatus.outForDelivery:
      case OrderStatus.inProgress:
        return l10n.arrived;

      case OrderStatus.arrived:
      case OrderStatus.delivered:
        return l10n.completed;

      case OrderStatus.cancelled:
        return l10n.cancelled;
    }
  }
}
