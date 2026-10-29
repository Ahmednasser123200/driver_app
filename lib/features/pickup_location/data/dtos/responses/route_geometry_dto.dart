import 'package:driver_app/features/pickup_location/domain/entities/map_location.dart';
import 'package:json_annotation/json_annotation.dart';

part 'route_geometry_dto.g.dart';

/// The GeoJSON geometry returned by the routing service.
@JsonSerializable()
class RouteGeometryDto {
  const RouteGeometryDto({this.type, this.coordinates});

  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'coordinates')
  final List<List<double>>? coordinates;

  factory RouteGeometryDto.fromJson(Map<String, dynamic> json) =>
      _$RouteGeometryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RouteGeometryDtoToJson(this);

  /// Converts the GeoJSON coordinates into domain locations.
  ///
  /// GeoJSON orders every coordinate as `[longitude, latitude]`.
  List<MapLocation> toDomainPoints() => (coordinates ?? const <List<double>>[])
      .where((coordinate) => coordinate.length >= 2)
      .map(
        (coordinate) =>
            MapLocation(latitude: coordinate[1], longitude: coordinate[0]),
      )
      .toList();
}
