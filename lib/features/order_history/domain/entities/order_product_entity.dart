import 'package:equatable/equatable.dart';

class OrderProductEntity extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String currency;
  final double price;

  const OrderProductEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.currency,
    required this.price,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, currency, price];
}
