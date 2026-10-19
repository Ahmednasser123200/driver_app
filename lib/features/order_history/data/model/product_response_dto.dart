import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order_history_entities.dart';

part 'product_response_dto.g.dart';

@JsonSerializable()
class ProductResponseDto {
  final String id;
  final String name;
  final String imageUrl;
  final String currency;
  final double price;
  final double originalPrice;
  final double discountPercentage;
  final String status;
  final List<String> images;
  final String description;
  final List<ProductIncludeDto> includes;

  const ProductResponseDto({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.currency,
    required this.price,
    required this.originalPrice,
    required this.discountPercentage,
    required this.status,
    required this.images,
    required this.description,
    required this.includes,
  });

  factory ProductResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProductResponseDtoToJson(this);

  OrderProductEntity toEntity() {
    return OrderProductEntity(
      id: id,
      name: name,
      imageUrl: imageUrl,
      currency: currency,
      price: price,
    );
  }
}

@JsonSerializable()
class ProductIncludeDto {
  final String name;

  const ProductIncludeDto({required this.name});

  factory ProductIncludeDto.fromJson(Map<String, dynamic> json) =>
      _$ProductIncludeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProductIncludeDtoToJson(this);
}