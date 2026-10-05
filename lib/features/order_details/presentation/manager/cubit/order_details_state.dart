import 'package:equatable/equatable.dart';

import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';

class OrderDetailsState extends Equatable {
  final bool isLoading;
  final String errorMessage;
  final DriverOrderDetailsEntity? data;
  final bool updateStatusSuccess;
  final bool reportLocationSuccess;

  const OrderDetailsState({
    this.isLoading = false,
    this.errorMessage = '',
    this.data,
    this.updateStatusSuccess = false,
    this.reportLocationSuccess = false,
  });

  OrderDetailsState copyWith({
    bool? isLoading,
    String? errorMessage,
    DriverOrderDetailsEntity? data,
    bool? updateStatusSuccess,
    bool? reportLocationSuccess,
  }) {
    return OrderDetailsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      updateStatusSuccess: updateStatusSuccess ?? this.updateStatusSuccess,
      reportLocationSuccess:
          reportLocationSuccess ?? this.reportLocationSuccess,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    data,
    updateStatusSuccess,
    reportLocationSuccess,
  ];
}
