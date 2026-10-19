import 'package:equatable/equatable.dart';

import '../entities/driver_status_update.dart';

class UpdateOrderStatusParams extends Equatable {
  final String orderId;
  final DriverStatusUpdate newStatus;

  const UpdateOrderStatusParams({
    required this.orderId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [orderId, newStatus];
}
