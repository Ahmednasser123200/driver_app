import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:equatable/equatable.dart';

class OrderDetailsState extends Equatable {
  final BaseState<DriverOrderDetailsEntity> orderDetails;
  final BaseState<UpdateOrderStatusEntity> updateOrderStatus;
  final BaseState<ReportDriverLocationEntity> reportDriverLocation;

  const OrderDetailsState({
    this.orderDetails = const BaseState(),
    this.updateOrderStatus = const BaseState(),
    this.reportDriverLocation = const BaseState(),
  });

  OrderDetailsState copyWith({
    BaseState<DriverOrderDetailsEntity>? orderDetails,
    BaseState<UpdateOrderStatusEntity>? updateOrderStatus,
    BaseState<ReportDriverLocationEntity>? reportDriverLocation,
  }) {
    return OrderDetailsState(
      orderDetails: orderDetails ?? this.orderDetails,
      updateOrderStatus: updateOrderStatus ?? this.updateOrderStatus,
      reportDriverLocation:
          reportDriverLocation ?? this.reportDriverLocation,
    );
  }

  @override
  List<Object?> get props => [
        orderDetails,
        updateOrderStatus,
        reportDriverLocation,
      ];
}