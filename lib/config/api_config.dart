import '../utils/constant.dart';
class ApiConfig {
  static const String baseUrl = "$backendUrl/api";
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}