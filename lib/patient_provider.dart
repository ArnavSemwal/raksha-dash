import 'package:flutter/foundation.dart';

class PatientProvider extends ChangeNotifier {
  // 1. Patient Details State
  String patientId = 'PT-8492';
  String patientName = '';
  int age = 0;
  String gender = 'Male';

  // 2. Vitals State (Dummy Data Defaults)
  double heartRate = 75.0;
  double spo2 = 98.0;
  double temperature = 36.8;
  int systolicBP = 120;
  int diastolicBP = 80;

  // 3. Update Vitals function
  void updateVitals({double? hr, double? s, double? temp, int? sys, int? dia}) {
    if (hr != null) heartRate = hr;
    if (s != null) spo2 = s;
    if (temp != null) temperature = temp;
    if (sys != null) systolicBP = sys;
    if (dia != null) diastolicBP = dia;
    notifyListeners(); // UI ko batayega ki data change ho gaya hai, refresh maro!
  }

  // 4. Vaibhavi's MEWS Rule Engine (Translated from Python to Dart)
  Map<String, dynamic> evaluateMews() {
    List<String> reasons = [];
    String status = "NONE";

    // Check Heart Rate
    if (heartRate < 40 || heartRate > 130) {
      reasons.add("Critical Heart Rate (${heartRate.toInt()} bpm)");
      status = "RED";
    }

    // Check SpO2 (Oxygen)
    if (spo2 < 90) {
      reasons.add("Critical SpO2 (${spo2.toInt()}%)");
      status = "RED";
    }

    // Check Temperature
    if (temperature > 39.0 || temperature < 35.0) {
      reasons.add("Abnormal Temperature ($temperature°C)");
      if (status != "RED") {
        status = "YELLOW";
      }
    }

    // Compile result
    if (reasons.isNotEmpty) {
      return {
        "override": true,
        "status": status,
        "reason": reasons.join(" | "),
      };
    }

    return {
      "override": false,
      "status": "NONE",
      "reason": "Vitals within normal range",
    };
  }
}
