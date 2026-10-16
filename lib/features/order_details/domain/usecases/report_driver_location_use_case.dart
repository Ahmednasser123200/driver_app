import 'dart:async';

import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/core/services/location/geolocator_wrapper.dart';
import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:driver_app/features/order_details/domain/repo/order_details_repo.dart';
import 'package:geolocator/geolocator.dart';
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

  StreamSubscription<Position> start({
    required void Function(BaseResponse<ReportDriverLocationEntity> result)
    onReportResult,
    double minDisplacementMeters = 50.0,
  }) {
    Position? lastReportedPosition;

    return _repository.driverLocationStream.listen((position) async {
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
    });
  }
}
