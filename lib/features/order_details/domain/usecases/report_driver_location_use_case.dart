import 'dart:async';

import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/core/services/location/geolocator_wrapper.dart';
import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:driver_app/features/order_details/domain/entities/user_location_entity.dart';
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

  StreamSubscription<BaseResponse<UserLocationEntity>> start({
    required void Function(BaseResponse<ReportDriverLocationEntity> result)
    onReportResult,
    double minDisplacementMeters = 50.0,
  }) {
    UserLocationEntity? lastReportedLocation;

    return _repository.driverLocationStream.listen((response) async {
      switch (response) {
        case Success<UserLocationEntity>(data: final location):
          final shouldReport =
              lastReportedLocation == null ||
              _geolocatorWrapper.distanceBetween(
                    lastReportedLocation!.latitude,
                    lastReportedLocation!.longitude,
                    location.latitude,
                    location.longitude,
                  ) >=
                  minDisplacementMeters;

          if (shouldReport) {
            lastReportedLocation = location;
            final recordedAt = DateTime.now().toUtc().toIso8601String();

            final result = await _repository.reportDriverLocation(
              ReportDriverLocationParams(
                lat: location.latitude,
                lng: location.longitude,
                recordedAt: recordedAt,
              ),
            );

            onReportResult(result);
          }

        case Error<UserLocationEntity>(failure: final failure):
          onReportResult(Error(failure));
      }
    });
  }
}
