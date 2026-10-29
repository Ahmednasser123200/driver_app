import 'package:json_annotation/json_annotation.dart';

import 'driving_route_dto.dart';

part 'driving_route_response_dto.g.dart';

/// The response returned by the routing service.
@JsonSerializable()
class DrivingRouteResponseDto {
  const DrivingRouteResponseDto({this.code, this.routes, this.message});

  @JsonKey(name: 'code')
  final String? code;

  @JsonKey(name: 'routes')
  final List<DrivingRouteDto>? routes;

  @JsonKey(name: 'message')
  final String? message;

  factory DrivingRouteResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DrivingRouteResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DrivingRouteResponseDtoToJson(this);

  /// `true` when the routing service answered with a valid route.
  bool get isOk => code == 'Ok';

  List<DrivingRouteDto> get routeList => routes ?? const [];
}
