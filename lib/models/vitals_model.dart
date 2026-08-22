// DATA_SOURCE: https://raksha-sim-1.onrender.com
/// Strongly typed model representing complete patient vitals and triage results.
class VitalsModel {
  final String patientId;
  final String timestamp;
  final String stethoscopeStatus;
  final double ecgHr;
  final double spo2;
  final double temperature;
  final List<double> urineRgb;
  final String patientSpeechText;
  final String triage;
  final double confidence;

  VitalsModel({
    required this.patientId,
    required this.timestamp,
    required this.stethoscopeStatus,
    required this.ecgHr,
    required this.spo2,
    required this.temperature,
    required this.urineRgb,
    required this.patientSpeechText,
    required this.triage,
    required this.confidence,
  });

  /// Factory constructor to decode full JSON payload returned from cloud server.
  factory VitalsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json.containsKey('vitals') && json['vitals'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['vitals'])
            : json;

    final List<dynamic> rawRgb =
        data['urine_rgb'] ?? json['urine_rgb'] ?? [255.0, 255.0, 0.0];
    final List<double> parsedRgb =
        rawRgb.map((e) => (e as num).toDouble()).toList();

    return VitalsModel(
      patientId: (data['patient_id'] ?? json['patient_id'] ?? '').toString(),
      timestamp: (data['timestamp'] ??
              json['timestamp'] ??
              DateTime.now().toIso8601String())
          .toString(),
      stethoscopeStatus:
          (data['stethoscope_status'] ?? json['stethoscope_status'] ?? 'clean')
              .toString(),
      ecgHr: ((data['ecg_hr'] ?? json['ecg_hr'] ?? 72.0) as num).toDouble(),
      spo2: ((data['spo2'] ?? json['spo2'] ?? 98.0) as num).toDouble(),
      temperature:
          ((data['temperature'] ?? json['temperature'] ?? 36.8) as num)
              .toDouble(),
      urineRgb: parsedRgb,
      patientSpeechText:
          (data['patient_speech_text'] ?? json['patient_speech_text'] ?? '')
              .toString(),
      triage: (json['triage'] ?? data['triage'] ?? 'GREEN').toString(),
      confidence:
          ((json['confidence'] ?? data['confidence'] ?? 0.95) as num)
              .toDouble(),
    );
  }

  /// Serializes VitalsModel back to JSON format.
  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'timestamp': timestamp,
      'stethoscope_status': stethoscopeStatus,
      'ecg_hr': ecgHr,
      'spo2': spo2,
      'temperature': temperature,
      'urine_rgb': urineRgb,
      'patient_speech_text': patientSpeechText,
      'triage': triage,
      'confidence': confidence,
    };
  }
}
