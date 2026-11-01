// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductResponseDto _$ProductResponseDtoFromJson(Map<String, dynamic> json) =>
    ProductResponseDto(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      currency: json['currency'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      status: json['status'] as String,
      images: (json['images'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      description: json['description'] as String,
      includes: (json['includes'] as List<dynamic>)
          .map((e) => ProductIncludeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProductResponseDtoToJson(ProductResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'currency': instance.currency,
      'price': instance.price,
      'originalPrice': instance.originalPrice,
      'discountPercentage': instance.discountPercentage,
      'status': instance.status,
      'images': instance.images,
      'description': instance.description,
      'includes': instance.includes,
    };

ProductIncludeDto _$ProductIncludeDtoFromJson(Map<String, dynamic> json) =>
    ProductIncludeDto(name: json['name'] as String);

Map<String, dynamic> _$ProductIncludeDtoToJson(ProductIncludeDto instance) =>
    <String, dynamic>{'name': instance.name};
