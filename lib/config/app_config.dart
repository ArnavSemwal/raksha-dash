/// Global Application Configuration for Raksha
class AppConfig {
  /// Base URL for local ESP32 / Raspberry Pi Hardware Controller.
  /// PLACEHOLDER: Replace with the actual hardware IP once the device is live on the network.
  static const String hardwareBaseUrl = 'http://192.168.x.x:5000';

  // ── SENSOR SPECIFIC HARDWARE TIMEOUTS ──────────────────────────────────
  /// Temperature (MLX90614): 2 seconds
  static const Duration temperatureTimeout = Duration(seconds: 2);

  /// Urine/Color (TCS3200): 3 seconds
  static const Duration urineTimeout = Duration(seconds: 3);

  /// ECG (AD8232): 5 seconds
  static const Duration ecgTimeout = Duration(seconds: 5);

  /// Stethoscope (MAX4466): 5 seconds
  static const Duration stethoscopeTimeout = Duration(seconds: 5);

  /// Pulse Oximeter (MAX30102): Fixed strictly at 12 seconds
  static const Duration pulseOximeterTimeout = Duration(seconds: 12);

  /// Voice recording / auscultation stream: 5 seconds
  static const Duration voiceTimeout = Duration(seconds: 5);
}
