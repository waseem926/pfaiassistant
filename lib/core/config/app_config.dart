import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration loaded from `.env` (see `.env.example`).
class AppConfig {
  AppConfig._({
    required this.geminiApiKey,
    required this.apiBaseUrl,
  });

  final String geminiApiKey;

  /// Node API base URL — used once the backend proxy is implemented.
  final String apiBaseUrl;

  static AppConfig? _instance;

  static AppConfig get instance {
    final config = _instance;
    if (config == null) {
      throw StateError('AppConfig not initialized. Call AppConfig.load() first.');
    }
    return config;
  }

  static Future<AppConfig> load() async {
    await dotenv.load(fileName: '.env');

    final geminiApiKey = dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
    final apiBaseUrl = dotenv.env['API_BASE_URL']?.trim() ?? '';

    if (geminiApiKey.isEmpty) {
      final message =
          'GEMINI_API_KEY is missing. Copy .env.example to .env and add your key.';
      if (kDebugMode) {
        debugPrint('⚠️ $message');
      } else {
        throw StateError(message);
      }
    }

    _instance = AppConfig._(
      geminiApiKey: geminiApiKey,
      apiBaseUrl: apiBaseUrl,
    );
    return _instance!;
  }

  /// True when the Node API URL is configured (post Day 3 migration).
  bool get useNodeApi => apiBaseUrl.isNotEmpty;
}
