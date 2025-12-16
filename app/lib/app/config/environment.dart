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
    // For Android Emulator: use 10.0.2.2
    // For iOS Simulator: use localhost
    // For Physical Device: use your computer's IP or server IP
    apiBaseUrl: 'http://10.0.2.2:8000',  // Android Emulator
    // apiBaseUrl: 'http://172.105.41.86',
    enableLogging: true,
    enableDebugMode: true,
    apiTimeout: 30,
    appName: 'JMI (Dev)',
  );

  /// Staging configuration
  static const AppConfig staging = AppConfig(
    environment: Environment.staging,
    apiBaseUrl: 'http://10.0.2.2:8000',  // Android Emulator
    // apiBaseUrl: 'http://172.105.41.86',
    enableLogging: true,
    enableDebugMode: false,
    apiTimeout: 20,
    appName: 'JMI (Staging)',
  );

  /// Production configuration (Server IP)
  static const AppConfig production = AppConfig(
    environment: Environment.production,
    apiBaseUrl: 'http://172.105.41.86',  // Production Server
    enableLogging: false,
    enableDebugMode: false,
    apiTimeout: 15,
    appName: 'JMI',
  );

  /// Get current environment config
  /// Change this to switch environments
  static AppConfig get current {
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
