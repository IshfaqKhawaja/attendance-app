/// Environment configuration for the app
/// Handles different environments (dev, staging, production)
library;

enum Environment {
  development,
  staging,
  production,
}

class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final bool enableLogging;
  final bool enableDebugMode;
  final int apiTimeout; // in seconds
  final String appName;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.enableDebugMode,
    required this.apiTimeout,
    required this.appName,
  });

  /// Development configuration
  static const AppConfig development = AppConfig(
    environment: Environment.development,
    apiBaseUrl: 'http://localhost:8000',
    enableLogging: true,
    enableDebugMode: true,
    apiTimeout: 30,
    appName: 'Attendance App (Dev)',
  );

  /// Staging configuration
  static const AppConfig staging = AppConfig(
    environment: Environment.staging,
    apiBaseUrl: 'https://staging-api.yourdomain.com',
    enableLogging: true,
    enableDebugMode: false,
    apiTimeout: 20,
    appName: 'Attendance App (Staging)',
  );

  /// Production configuration
  static const AppConfig production = AppConfig(
    environment: Environment.production,
    apiBaseUrl: 'https://api.yourdomain.com',
    enableLogging: false,
    enableDebugMode: false,
    apiTimeout: 15,
    appName: 'Attendance App',
  );

  /// Get current environment config
  /// Change this to switch environments
  static AppConfig get current {
    // TODO: Set this based on build flavor
    const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'development');

    switch (flavor) {
      case 'production':
        return production;
      case 'staging':
        return staging;
      case 'development':
      default:
        return development;
    }
  }

  bool get isDevelopment => environment == Environment.development;
  bool get isStaging => environment == Environment.staging;
  bool get isProduction => environment == Environment.production;
}
