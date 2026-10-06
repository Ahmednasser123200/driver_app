import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiStrings {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  static const String driverApplications = '/api/drivers/applications';
  static const String vehicleTypes = '/api/v1/vehicle-types';
  static const String countries = '/api/v1/countries';
}
