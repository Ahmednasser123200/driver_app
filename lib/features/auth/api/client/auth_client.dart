import 'dart:io';

import 'package:dio/dio.dart';
import 'package:driver_app/core/constants/api_strings/api_strings.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/model/response/apply_response/application_response_dto.dart';
import '../../data/model/response/apply_response/country_dto.dart';
import '../../data/model/response/apply_response/vehicle_type_dto.dart';

part 'auth_client.g.dart';

@singleton
@RestApi()
abstract class AuthClient {
  @factoryMethod
  factory AuthClient(Dio dio) = _AuthClient;

  @POST(ApiStrings.driverApplications)
  @GET(ApiStrings.countries)
  Future<List<CountryDto>> getCountries();

  @GET(ApiStrings.vehicleTypes)
  Future<List<VehicleTypeDto>> getVehicleTypes();
  @MultiPart()
  Future<ApplicationResponseDto> addApplication(
    @PartMap() Map<String, dynamic> body,
    @Part(name: ApiStrings.vehicleLicenceFile) File? vehicleLicenceFile,
    @Part(name: ApiStrings.idImage) File? idImage,
  );
}