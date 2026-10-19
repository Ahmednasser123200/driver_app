
import 'package:equatable/equatable.dart';

/// The prices the driver details payload does not carry. They come from the
/// customer order endpoint (`GET /order/orders/{orderId}`) and are merged onto
/// [DriverOrderDetailsEntity] without ever inventing a value.
class OrderPricingEntity extends Equatable {
  const OrderPricingEntity({
    this.total,
    this.currency = '',
    this.unitPriceByProductId = const {},
  });

  /// Authoritative order total, or null when the backend did not return one.
  final double? total;

  /// Currency code/symbol (`EGP`, `$`, ...), or an empty string when unknown.
  final String currency;

  /// Unit price per `productId`. Empty when no per-item price is available.
  final Map<String, double> unitPriceByProductId;

  @override
  List<Object?> get props => [total, currency, unitPriceByProductId];
}
