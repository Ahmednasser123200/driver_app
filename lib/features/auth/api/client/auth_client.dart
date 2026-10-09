import 'dart:io';

import 'package:dio/dio.dart';
import 'package:driver_app/core/constants/api_strings/api_strings.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/model/response/apply_response/application_response_dto.dart';
import '../../data/model/response/apply_response/country_dto.dart';
import '../../data/model/response/apply_response/vehicle_types_response_dto.dart';

part 'auth_client.g.dart';

@singleton
@RestApi()
abstract class AuthClient {
  @factoryMethod
  factory AuthClient(Dio dio) = _AuthClient;

  @GET(ApiStrings.countries)
  Future<List<CountryDto>> getCountries();

  @GET(ApiStrings.vehicleTypes)
  Future<VehicleTypesResponseDto> getVehicleTypes();

  @POST(ApiStrings.driverApplications)
  @MultiPart()
  Future<ApplicationResponseDto> addApplication(
    @PartMap() Map<String, dynamic> body,
    @Part(name: ApiStrings.vehicleLicenceFile) File? vehicleLicenceFile,
    @Part(name: ApiStrings.idImage) File? idImage,
  );
}
