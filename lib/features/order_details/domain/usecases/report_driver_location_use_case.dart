
import 'dart:async';

import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/core/services/location/geolocator_wrapper.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_location.dart';
import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:driver_app/features/order_details/domain/repo/order_details_repo.dart';
import 'package:injectable/injectable.dart';

import '../params/report_driver_location_params.dart';

@injectable
class ReportDriverLocationUseCase {
  ReportDriverLocationUseCase(this._repository, this._geolocatorWrapper);

  final OrderDetailsRepo _repository;
  final GeolocatorWrapper _geolocatorWrapper;

  Future<BaseResponse<ReportDriverLocationEntity>> execute(
    ReportDriverLocationParams params,
  ) => _repository.reportDriverLocation(params);

  StreamSubscription<BaseResponse<DriverLocation>> start({
    required void Function(BaseResponse<ReportDriverLocationEntity> result)
        onReportResult,
    required void Function(AppFailure failure) onLocationError,
    double minDisplacementMeters = 50.0,
  }) {
    DriverLocation? lastReportedPosition;

    return _repository.driverLocationStream.listen((locationResult) async {
      switch (locationResult) {
        case Success<DriverLocation>(data: final position):
          final shouldReport =
              lastReportedPosition == null ||
              _geolocatorWrapper.distanceBetween(
                    lastReportedPosition!.latitude,
                    lastReportedPosition!.longitude,
                    position.latitude,
                    position.longitude,
                  ) >=
                  minDisplacementMeters;

          if (shouldReport) {
            lastReportedPosition = position;
            final recordedAt = DateTime.now().toUtc().toIso8601String();

            final result = await _repository.reportDriverLocation(
              ReportDriverLocationParams(
                lat: position.latitude,
                lng: position.longitude,
                recordedAt: recordedAt,
              ),
            );

            onReportResult(result);
          }

        case Error<DriverLocation>(failure: final failure):
          onLocationError(failure);
      }
    });
  }
}
