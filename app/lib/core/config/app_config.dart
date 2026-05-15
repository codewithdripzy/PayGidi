class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.paygidi.site/api/v1',
  );

  static const String apiKey = String.fromEnvironment('API_KEY');
  
  // Add other config variables here
}
