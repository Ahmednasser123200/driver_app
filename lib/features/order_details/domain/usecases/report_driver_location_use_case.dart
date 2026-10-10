import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:driver_app/features/order_details/domain/repo/order_details_repo.dart';
import 'package:injectable/injectable.dart';

import '../params/report_driver_location_params.dart';

@lazySingleton
class ReportDriverLocationUseCase {
  ReportDriverLocationUseCase(this._repository);

  final OrderDetailsRepo _repository;

  Future<BaseResponse<ReportDriverLocationEntity>> execute(
  ReportDriverLocationParams params,
  ) => _repository.reportDriverLocation(params);
}
