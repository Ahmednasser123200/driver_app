import 'package:driver_app/l10n/generated/app_localizations.dart';

class OrderStatusHelper {
  OrderStatusHelper._();

  static String _normalize(String? status) {
    return status?.replaceAll(RegExp(r'[\s_-]+'), '').toLowerCase() ?? '';
  }

  static int getStep(String? status) {
    switch (_normalize(status)) {
      case 'pending':
        return 1;

      case 'accepted':
      case 'assigned':
        return 2;

      case 'outfordelivery':
      case 'ontheway':
      case 'inprogress':
        return 3;

      case 'pickedup':
      case 'picked':
      case 'arrived':
        return 4;

      case 'delivered':
      case 'completed':
      case 'awaitingdeliveryconfirmation':
        return 5;

      default:
        return 1;
    }
  }

  static String getLocalizedStatus(String? status, AppLocalizations l10n) {
    switch (_normalize(status)) {
      case 'pending':
        return l10n.pending;

      case 'accepted':
      case 'assigned':
        return l10n.accepted;

      case 'pickedup':
      case 'picked':
        return l10n.picked;

      case 'outfordelivery':
      case 'ontheway':
      case 'inprogress':
        return l10n.outForDelivery;

      case 'arrived':
        return l10n.arrived;

      case 'delivered':
        return l10n.delivered;

      case 'completed':
        return l10n.completed;

      case 'cancelled':
        return l10n.cancelled;

      default:
        return status ?? l10n.accepted;
    }
  }

  static String? getNextStatus(String? status) {
    switch (_normalize(status)) {
      case 'pending':
        return 'Accepted';

      case 'accepted':
      case 'assigned':
        return 'OnTheWay';

      case 'outfordelivery':
      case 'ontheway':
      case 'inprogress':
        return 'Arrived';

      case 'pickedup':
      case 'picked':
      case 'arrived':
        return 'Delivered';

      default:
        return null;
    }
  }

  static String getNextStatusLabel(String? status, AppLocalizations l10n) {
    switch (_normalize(status)) {
      case 'pending':
        return l10n.accepted;

      case 'accepted':
      case 'assigned':
        return l10n.outForDelivery;

      case 'outfordelivery':
      case 'ontheway':
      case 'inprogress':
        return l10n.arrived;

      case 'pickedup':
      case 'picked':
      case 'arrived':
        return l10n.delivered;

      default:
        return l10n.startDeliver;
    }
  }
}
