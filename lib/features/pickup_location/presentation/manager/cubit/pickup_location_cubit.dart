import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/features/pickup_location/domain/entities/driving_route.dart';
import 'package:driver_app/features/pickup_location/domain/params/driving_route_params.dart';
import 'package:driver_app/features/pickup_location/domain/usecases/get_driving_route_use_case.dart';
import 'package:driver_app/features/pickup_location/presentation/manager/cubit/pickup_location_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class PickupLocationCubit extends BaseCubit<PickupLocationState, BaseUiEvent> {
  PickupLocationCubit(this._getDrivingRouteUseCase)
    : super(const PickupLocationState());

  final GetDrivingRouteUseCase _getDrivingRouteUseCase;

  /// Loads the driving route between the pickup and the customer location.
  Future<void> loadDrivingRoute(DrivingRouteParams params) async {
    emit(
      state.copyWith(
        drivingRoute: state.drivingRoute.copyWith(
          isLoading: true,
          errorMessage: null,
        ),
      ),
    );

    final result = await _getDrivingRouteUseCase.execute(params);

    switch (result) {
      case Success<DrivingRoute>():
        emit(
          state.copyWith(
            drivingRoute: state.drivingRoute.copyWith(
              isLoading: false,
              data: result.data,
              errorMessage: null,
            ),
          ),
        );

      case Error<DrivingRoute>():
        emit(
          state.copyWith(
            drivingRoute: state.drivingRoute.copyWith(
              isLoading: false,
              errorMessage: result.failure,
            ),
          ),
        );

        emitEvent(ShowFailureMessage(result.failure));
    }
  }
}
