import 'package:dio/dio.dart';
import 'package:driver_app/features/pickup_location/api/client/pickup_location_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the OSRM base URL with the shared Dio client', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
    Uri? requestedUri;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestedUri = options.uri;
          handler.reject(DioException(requestOptions: options));
        },
      ),
    );
    final apiClient = PickupLocationApiClient(dio);

    await expectLater(
      apiClient.getDrivingRoute(
        '31.2357,30.0444;31.2302,30.0398',
        overview: 'full',
        geometries: 'geojson',
      ),
      throwsA(isA<DioException>()),
    );

    expect(requestedUri?.origin, 'https://router.project-osrm.org');
  });
}
