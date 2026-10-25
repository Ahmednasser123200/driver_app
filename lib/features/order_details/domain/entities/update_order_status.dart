import 'package:equatable/equatable.dart';

class UpdateOrderStatusEntity extends Equatable {
  final String orderId;
  final String status;
  final String updatedAt;

  const UpdateOrderStatusEntity({
    required this.orderId,
    required this.status,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [orderId, status, updatedAt];
}
