import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiStrings {
  static final String baseUrl = dotenv.env['BASE_URL'] ??'';
}
