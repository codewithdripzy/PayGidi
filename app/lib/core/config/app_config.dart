class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.paygidi.site/api/v1',
  );

  static const String mapsApiKey = String.fromEnvironment('MAPS_API_KEY');
}
