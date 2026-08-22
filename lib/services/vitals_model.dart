/// Typed Data Model for Hardware Telemetry Data
class EcgData {
  final int heartRateBpm;
  final List<int> samples;

  const EcgData({
    this.heartRateBpm = 0,
    this.samples = const [],
  });

  factory EcgData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EcgData();
    return EcgData(
      heartRateBpm: (json['heart_rate_bpm'] as num?)?.toInt() ?? 0,
      samples: (json['samples'] as List<dynamic>?)
              ?.map((e) => (e as num?)?.toInt() ?? 0)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'heart_rate_bpm': heartRateBpm,
        'samples': samples,
      };
}

class UrineSensorData {
  final int red;
  final int green;
  final int blue;

  const UrineSensorData({
    this.red = 0,
    this.green = 0,
    this.blue = 0,
  });

  factory UrineSensorData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UrineSensorData();
    return UrineSensorData(
      red: (json['red'] as num?)?.toInt() ?? 0,
      green: (json['green'] as num?)?.toInt() ?? 0,
      blue: (json['blue'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'red': red,
        'green': green,
        'blue': blue,
      };
}

class StethoscopeData {
  /// Placeholder 0 values for stethoscope stats (rms/min/max/samples) until real DSP integration
  final int rms;
  final int min;
  final int max;
  final int samples;

  const StethoscopeData({
    this.rms = 0,
    this.min = 0,
    this.max = 0,
    this.samples = 0,
  });

  factory StethoscopeData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StethoscopeData();
    return StethoscopeData(
      rms: (json['rms'] as num?)?.toInt() ?? 0,
      min: (json['min'] as num?)?.toInt() ?? 0,
      max: (json['max'] as num?)?.toInt() ?? 0,
      samples: (json['samples'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'rms': rms,
        'min': min,
        'max': max,
        'samples': samples,
      };
}

class TemperatureData {
  final double bodyTempC;

  const TemperatureData({
    this.bodyTempC = 0.0,
  });

  factory TemperatureData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TemperatureData();
    return TemperatureData(
      bodyTempC: (json['body_temp_c'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'body_temp_c': bodyTempC,
      };
}

class PulseOximeterData {
  final int heartRateBpm;
  final int spo2Percent;
  final int irRaw;

  const PulseOximeterData({
    this.heartRateBpm = 0,
    this.spo2Percent = 0,
    this.irRaw = 0,
  });

  factory PulseOximeterData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PulseOximeterData();
    return PulseOximeterData(
      heartRateBpm: (json['heart_rate_bpm'] as num?)?.toInt() ?? 0,
      spo2Percent: (json['spo2_percent'] as num?)?.toInt() ?? 0,
      irRaw: (json['ir_raw'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'heart_rate_bpm': heartRateBpm,
        'spo2_percent': spo2Percent,
        'ir_raw': irRaw,
      };
}

/// Root Hardware Vitals Model mapping strictly to telemetry JSON schema
class VitalsModel {
  final String patientId;
  final String deviceId;
  final String timestamp;
  final String patientSpeechText;
  final EcgData ecg;
  final UrineSensorData urineSensor;
  final StethoscopeData stethoscope;
  final TemperatureData temperature;
  final PulseOximeterData pulseOximeter;
  final String status;

  const VitalsModel({
    this.patientId = '',
    this.deviceId = 'RASPI-001',
    this.timestamp = '',
    this.patientSpeechText = '',
    this.ecg = const EcgData(),
    this.urineSensor = const UrineSensorData(),
    this.stethoscope = const StethoscopeData(),
    this.temperature = const TemperatureData(),
    this.pulseOximeter = const PulseOximeterData(),
    this.status = '',
  });

  factory VitalsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const VitalsModel();
    return VitalsModel(
      patientId: json['patient_id']?.toString() ?? '',
      deviceId: json['device_id']?.toString() ?? 'RASPI-001',
      timestamp: json['timestamp']?.toString() ?? '',
      patientSpeechText: json['patient_speech_text']?.toString() ?? '',
      ecg: EcgData.fromJson(json['ecg'] as Map<String, dynamic>?),
      urineSensor:
          UrineSensorData.fromJson(json['urine_sensor'] as Map<String, dynamic>?),
      stethoscope:
          StethoscopeData.fromJson(json['stethoscope'] as Map<String, dynamic>?),
      temperature:
          TemperatureData.fromJson(json['temperature'] as Map<String, dynamic>?),
      pulseOximeter: PulseOximeterData.fromJson(
          json['pulse_oximeter'] as Map<String, dynamic>?),
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'patient_id': patientId,
        'device_id': deviceId,
        'timestamp': timestamp,
        'patient_speech_text': patientSpeechText,
        'ecg': ecg.toJson(),
        'urine_sensor': urineSensor.toJson(),
        'stethoscope': stethoscope.toJson(),
        'temperature': temperature.toJson(),
        'pulse_oximeter': pulseOximeter.toJson(),
        'status': status,
      };
}
