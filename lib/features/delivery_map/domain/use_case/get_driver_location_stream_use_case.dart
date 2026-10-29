import 'package:driver_app/core/services/location/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetDriverLocationStreamUseCase {
  final LocationService _locationService;

  const GetDriverLocationStreamUseCase(this._locationService);

  Stream<Position> call() => _locationService.locationStream;
}
