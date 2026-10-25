import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/features/pickup_location/domain/entities/driving_route.dart';
import 'package:equatable/equatable.dart';

class PickupLocationState extends Equatable {
  const PickupLocationState({this.drivingRoute = const BaseState()});

  final BaseState<DrivingRoute> drivingRoute;

  PickupLocationState copyWith({BaseState<DrivingRoute>? drivingRoute}) {
    return PickupLocationState(drivingRoute: drivingRoute ?? this.drivingRoute);
  }

  @override
  List<Object?> get props => [drivingRoute];
}
