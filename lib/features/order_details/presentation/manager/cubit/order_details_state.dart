
import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_location.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:driver_app/features/order_details/presentation/utils/location_reporting_status.dart';
import 'package:equatable/equatable.dart';



class OrderDetailsState extends Equatable {
  final BaseState<DriverOrderDetailsEntity> orderDetails;
  final BaseState<UpdateOrderStatusEntity> updateOrderStatus;
  final BaseState<ReportDriverLocationEntity> reportDriverLocation;
  final LocationReportingStatus locationReportingStatus;

  final DriverLocation? driverLocation;

  const OrderDetailsState({
    this.orderDetails = const BaseState(),
    this.updateOrderStatus = const BaseState(),
    this.reportDriverLocation = const BaseState(),
    this.locationReportingStatus = LocationReportingStatus.inactive,
    this.driverLocation,
  });

  OrderDetailsState copyWith({
    BaseState<DriverOrderDetailsEntity>? orderDetails,
    BaseState<UpdateOrderStatusEntity>? updateOrderStatus,
    BaseState<ReportDriverLocationEntity>? reportDriverLocation,
    LocationReportingStatus? locationReportingStatus,
    DriverLocation? driverLocation,
  }) {
    return OrderDetailsState(
      orderDetails: orderDetails ?? this.orderDetails,
      updateOrderStatus: updateOrderStatus ?? this.updateOrderStatus,
      reportDriverLocation:
          reportDriverLocation ?? this.reportDriverLocation,
      locationReportingStatus:
          locationReportingStatus ?? this.locationReportingStatus,
      driverLocation: driverLocation ?? this.driverLocation,
    );
  }

  @override
  List<Object?> get props => [
        orderDetails,
        updateOrderStatus,
        reportDriverLocation,
        locationReportingStatus,
        driverLocation,
      ];
}