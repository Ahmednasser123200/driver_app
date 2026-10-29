import 'package:dio/dio.dart';
import 'package:driver_app/features/pickup_location/api/client/pickup_location_api_client.dart';
import 'package:injectable/injectable.dart';


@module
abstract class PickupLocationApiModule {
  @Named('osrm')
  @lazySingleton
  Dio osrmDio() => Dio(
    BaseOptions(
      baseUrl: PickupLocationApiClient.routingBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
}
