import 'package:pfaiassistant/core/config/app_config.dart';

class ApiConstants {
  static String get geminiApiKey => AppConfig.instance.geminiApiKey;

  static String get apiBaseUrl => AppConfig.instance.apiBaseUrl;

  static bool get useNodeApi => AppConfig.instance.useNodeApi;
}
