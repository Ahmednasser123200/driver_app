import 'package:driver_app/features/order_details/domain/entities/order_pricing.dart';

/// Response of `GET /order/orders/{orderId}` — the customer order details
/// endpoint, which is the only one that exposes per-item `unitPrice` and the
/// authoritative `total`.
///
/// The payload is wrapped in a `{success, message, data, error}` envelope and
/// every price is optional, so the parser stays tolerant and never throws on a
/// missing field. Written by hand (rather than generated) because the JSON shape
/// is tiny and the repo's code generator cannot run here.
class OrderPricingDto {
  const OrderPricingDto({
    this.subtotal,
    this.deliveryFee,
    this.total,
    this.currency,
    this.items,
  });

  final double? subtotal;
  final double? deliveryFee;
  final double? total;
  final String? currency;
  final List<OrderPricingItemDto>? items;

  factory OrderPricingDto.fromJson(Map<String, dynamic> json) {
    final responseData = json['data'];
    final source = responseData is Map
        ? Map<String, dynamic>.from(responseData)
        : Map<String, dynamic>.from(json);

    return OrderPricingDto(
      subtotal: _toDouble(source['subtotal']),
      deliveryFee: _toDouble(source['deliveryFee']),
      total: _toDouble(source['total']),
      currency: source['currency'] as String?,
      items: (source['items'] as List<dynamic>?)
          ?.whereType<Map>()
          .map(
            (item) => OrderPricingItemDto.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }

  OrderPricingEntity toDomain() {
    final prices = <String, double>{};
    for (final item in items ?? const <OrderPricingItemDto>[]) {
      final productId = item.productId;
      final unitPrice = item.unitPrice;
      if (productId != null && productId.isNotEmpty && unitPrice != null) {
        prices[productId] = unitPrice;
      }
    }

    return OrderPricingEntity(
      total: total,
      currency: currency ?? '',
      unitPriceByProductId: prices,
    );
  }
}

class OrderPricingItemDto {
  const OrderPricingItemDto({this.productId, this.unitPrice});

  final String? productId;
  final double? unitPrice;

  factory OrderPricingItemDto.fromJson(Map<String, dynamic> json) =>
      OrderPricingItemDto(
        productId: json['productId'] as String?,
        unitPrice: _toDouble(json['unitPrice']),
      );
}

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}
