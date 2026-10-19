import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_order_status_response_dto.g.dart';

/// Response of `PATCH /order/orders/{orderId}/status`.
///
/// The API only documents `200 OK` for this route (no body schema) while the
/// rest of the service answers with a `{success, message, data, error}`
/// envelope, so every field stays nullable and [fromJson] unwraps `data` when
/// it is present. A successful update must never be reported as a failure just
/// because the body carries fewer fields than expected - the screen re-reads
/// the order after a successful update anyway.
@JsonSerializable()
class UpdateOrderStatusResponseDto {
  @JsonKey(name: 'orderId')
  final String? orderId;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  UpdateOrderStatusResponseDto({this.orderId, this.status, this.updatedAt});

  factory UpdateOrderStatusResponseDto.fromJson(Map<String, dynamic> json) {
    final responseData = json['data'];

    if (responseData is Map) {
      return _$UpdateOrderStatusResponseDtoFromJson(
        Map<String, dynamic>.from(responseData),
      );
    }

    return _$UpdateOrderStatusResponseDtoFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UpdateOrderStatusResponseDtoToJson(this);

  UpdateOrderStatusEntity toDomain() => UpdateOrderStatusEntity(
    orderId: orderId ?? '',
    status: status ?? '',
    updatedAt: updatedAt ?? '',
  );
}
