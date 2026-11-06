import 'package:driver_app/features/delivery_map/data/utils/polyline_decoder.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compute_routes_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class ComputeRoutesResponseDto {
  @JsonKey(name: 'routes')
  final List<ComputedRouteDto>? routes;

  const ComputeRoutesResponseDto({this.routes});

  factory ComputeRoutesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ComputeRoutesResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ComputeRoutesResponseDtoToJson(this);

  RouteModel? toDomain() {
    final routeList = routes;
    if (routeList == null || routeList.isEmpty) {
      return null;
    }

    final firstRoute = routeList.first;
    final encoded = firstRoute.polyline?.encodedPolyline;
    if (encoded == null || encoded.isEmpty) {
      return null;
    }

    final points = PolylineDecoder.decode(encoded);
    if (points.isEmpty) {
      return null;
    }

    final distanceMeters = (firstRoute.distanceMeters ?? 0).toDouble();
    final durationStr = firstRoute.duration ?? '0s';
    final durationSeconds =
        double.tryParse(durationStr.replaceAll('s', '')) ?? 0.0;

    return RouteModel(
      points: points,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      encodedPolyline: encoded,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ComputedRouteDto {
  @JsonKey(name: 'distanceMeters')
  final num? distanceMeters;

  @JsonKey(name: 'duration')
  final String? duration;

  @JsonKey(name: 'polyline')
  final RoutePolylineDto? polyline;

  const ComputedRouteDto({
    this.distanceMeters,
    this.duration,
    this.polyline,
  });

  factory ComputedRouteDto.fromJson(Map<String, dynamic> json) =>
      _$ComputedRouteDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ComputedRouteDtoToJson(this);
}

@JsonSerializable()
class RoutePolylineDto {
  @JsonKey(name: 'encodedPolyline')
  final String? encodedPolyline;

  const RoutePolylineDto({this.encodedPolyline});

  factory RoutePolylineDto.fromJson(Map<String, dynamic> json) =>
      _$RoutePolylineDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RoutePolylineDtoToJson(this);
}
