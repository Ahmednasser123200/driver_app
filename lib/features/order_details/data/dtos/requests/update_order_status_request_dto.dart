import 'package:json_annotation/json_annotation.dart';

part 'update_order_status_request_dto.g.dart';

@JsonSerializable()
class UpdateOrderStatusRequestDto {
  @JsonKey(name: 'newStatus')
  final String newStatus;

  UpdateOrderStatusRequestDto({
    required this.newStatus,
  });

  factory UpdateOrderStatusRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateOrderStatusRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateOrderStatusRequestDtoToJson(this);
}