import 'package:equatable/equatable.dart';

class OrderStoreEntity extends Equatable {
  final String name;
  final String address;
  final String? imageUrl;

  const OrderStoreEntity({
    required this.name,
    required this.address,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, address, imageUrl];
}
