
import 'package:equatable/equatable.dart';

class UpdateOrderStatusParams extends Equatable {
  final String orderId;
  final String newStatus;

  const UpdateOrderStatusParams({
    required this.orderId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [
        orderId,
        newStatus,
      ];
}
