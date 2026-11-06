import 'package:dio/dio.dart';
import 'package:driver_app/core/constants/api_strings/api_strings.dart';
import 'package:driver_app/features/delivery_map/api/client/routing_api_client.dart';
import 'package:injectable/injectable.dart';

@module
abstract class RoutingApiModule {
  @Named('googleRoutes')
  @lazySingleton
  Dio googleRoutesDio() => Dio(
    BaseOptions(
      baseUrl: RoutingApiClient.routingBaseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: <String, dynamic>{
        'X-Goog-Api-Key': ApiStrings.googleMapsApiKey,
        'X-Goog-FieldMask': RoutingApiClient.defaultFieldMask,
        'Content-Type': 'application/json',
      },
    ),
  );
}
