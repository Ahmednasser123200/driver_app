import 'package:json_annotation/json_annotation.dart';

part 'order_history_request_dto.g.dart';

@JsonSerializable()
class OrderHistoryRequestDto {
  final int page;
  final int pageSize;

  const OrderHistoryRequestDto({
    required this.page,
    required this.pageSize,
  });

  factory OrderHistoryRequestDto.fromJson(Map<String, dynamic> json) =>
      _$OrderHistoryRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderHistoryRequestDtoToJson(this);
}