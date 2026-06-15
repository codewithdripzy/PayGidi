import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl => dotenv.get(
        'BASE_URL',
        fallback: 'https://api.paygidi.site/api/v1',
      );

  static String get apiKey => dotenv.get('API_KEY', fallback: '');

  static String get googleMapsApiKey =>
      dotenv.get('GOOGLE_MAPS_API_KEY', fallback: '');

  // Add other config variables here
}
