import 'dart:math';

import 'package:flutter/material.dart';
import '../services/api_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// ENUMS
// ──────────────────────────────────────────────────────────────────────────────

/// Shared scan-status enum used by every test step.
enum ScanStatus {
  /// Screen just loaded — no measurement taken yet.
  initial,

  /// Measurement taken and within safe clinical thresholds.
  clean,

  /// Measurement taken and outside safe clinical thresholds.
  abnormal,
}

// ──────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ──────────────────────────────────────────────────────────────────────────────

/// Stethoscope auscultation result.
class StethResult {
  final double heartRate; // BPM
  final String lungSound; // e.g. "Clear", "Wheezing", "Crackles"

  const StethResult({required this.heartRate, required this.lungSound});
}

/// 12-lead ECG result.
class EcgResult {
  final double heartRate; // BPM
  final String rhythm; // e.g. "Normal Sinus", "Atrial Fibrillation"
  final double qtInterval; // ms

  const EcgResult({
    required this.heartRate,
    required this.rhythm,
    required this.qtInterval,
  });
}

/// Blood Pressure result.
class BpResult {
  final int systolic; // mmHg
  final int diastolic; // mmHg
  final int pulseRate; // BPM

  const BpResult({
    required this.systolic,
    required this.diastolic,
    required this.pulseRate,
  });

  /// Formatted reading, e.g. "120/80".
  String get formatted => '$systolic/$diastolic';
}

/// SpO2 + Temperature result.
class Spo2TempResult {
  final int spo2; // %
  final int heartRate; // BPM
  final double temperature; // °C

  const Spo2TempResult({
    required this.spo2,
    required this.heartRate,
    required this.temperature,
  });
}

/// Urine strip analysis result.
class UrineResult {
  final String color; // e.g. "Yellow", "Red", "Dark Brown"
  final double ph;
  final String protein; // "Negative", "Trace", "Positive"
  final String glucose; // "Negative", "Trace", "Positive"

  const UrineResult({
    required this.color,
    required this.ph,
    required this.protein,
    required this.glucose,
  });
}

/// Patient registration data captured at Step 1 (Registration).
class PatientInfo {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String? village;

  const PatientInfo({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    this.village,
  });

  factory PatientInfo.placeholder() => PatientInfo(
        id: 'PT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        name: '',
        age: 0,
        gender: '',
        phone: '',
      );
}

// ──────────────────────────────────────────────────────────────────────────────
// TRIAGE PROVIDER — Central State & Navigation Vault
// ──────────────────────────────────────────────────────────────────────────────

class TriageProvider extends ChangeNotifier {
  // ── Page Navigation ──────────────────────────────────────────────────────

  final PageController pageController = PageController();

  int _currentPage = 0;
  int get currentPage => _currentPage;

  static const int totalPages = 8;

  static const int pageBase = 0;
  static const int pageRegister = 1;
  static const int pageSteth = 2;
  static const int pageEcg = 3;
  static const int pageBp = 4;
  static const int pageSpo2Temp = 5;
  static const int pageUrine = 6;
  static const int pageResult = 7;

  // ── Patient Info ─────────────────────────────────────────────────────────

  PatientInfo _patientInfo = PatientInfo.placeholder();
  PatientInfo get patientInfo => _patientInfo;

  void setPatientInfo(PatientInfo info) {
    _patientInfo = info;
    notifyListeners();
  }

  void setGender(String? gender) {
    if (gender == null || gender.isEmpty) return;
    _patientInfo = PatientInfo(
      id: _patientInfo.id,
      name: _patientInfo.name,
      age: _patientInfo.age,
      gender: gender,
      phone: _patientInfo.phone,
      village: _patientInfo.village,
    );
    notifyListeners();
  }

  // ── Step States ──────────────────────────────────────────────────────────

  ScanStatus _stethStatus = ScanStatus.initial;
  ScanStatus get stethStatus => _stethStatus;

  ScanStatus _ecgStatus = ScanStatus.initial;
  ScanStatus get ecgStatus => _ecgStatus;

  ScanStatus _bpStatus = ScanStatus.initial;
  ScanStatus get bpStatus => _bpStatus;

  ScanStatus _spo2TempStatus = ScanStatus.initial;
  ScanStatus get spo2TempStatus => _spo2TempStatus;

  ScanStatus _urineStatus = ScanStatus.initial;
  ScanStatus get urineStatus => _urineStatus;

  // ── Step Results ─────────────────────────────────────────────────────────

  StethResult? _stethResult;
  StethResult? get stethResult => _stethResult;

  EcgResult? _ecgResult;
  EcgResult? get ecgResult => _ecgResult;

  BpResult? _bpResult;
  BpResult? get bpResult => _bpResult;

  Spo2TempResult? _spo2TempResult;
  Spo2TempResult? get spo2TempResult => _spo2TempResult;

  UrineResult? _urineResult;
  UrineResult? get urineResult => _urineResult;

  final Random _rng = Random();

  // ════════════════════════════════════════════════════════════════════════
  // CLINICAL EVALUATION FUNCTIONS (MEWS Rules)
  // ════════════════════════════════════════════════════════════════════════

  /// Weighted condition selector (60% GREEN Normal, 20% YELLOW Warning, 20% RED Critical)
  String _selectWeightedCondition() {
    final double r = _rng.nextDouble();
    if (r < 0.60) {
      return "GREEN"; // 60% Normal
    } else if (r < 0.80) {
      return "YELLOW"; // 20% Warning
    } else {
      return "RED"; // 20% Critical
    }
  }

  // ── 1. Stethoscope (Dataset Bounds: HR 65 - 160) ────────────────────────
  void runStethScan() {
    final String condition = _selectWeightedCondition();
    double hr;
    String lung;
    ScanStatus status;

    if (condition == "GREEN") {
      // Normal (60%): HR 65-90, Clear lungs
      hr = 65.0 + _rng.nextDouble() * 25.0;
      lung = 'Clear';
      status = ScanStatus.clean;
    } else if (condition == "YELLOW") {
      // Warning (20%): HR 91-115, Clear lungs
      hr = 91.0 + _rng.nextDouble() * 24.0;
      lung = 'Clear';
      status = ScanStatus.clean;
    } else {
      // Critical (20%): HR 125-155, Abnormal lung sounds
      hr = 125.0 + _rng.nextDouble() * 30.0;
      final abnormalLungs = ['Wheezing', 'Crackles'];
      lung = abnormalLungs[_rng.nextInt(abnormalLungs.length)];
      status = ScanStatus.abnormal;
    }

    _stethResult = StethResult(
      heartRate: double.parse(hr.toStringAsFixed(1)),
      lungSound: lung,
    );
    _stethStatus = status;
    notifyListeners();
  }

  void resetStethScan() {
    _stethStatus = ScanStatus.initial;
    _stethResult = null;
    notifyListeners();
  }

  // ── 2. ECG (Dataset Bounds: HR 65 - 160) ────────────────────────────────
  void runEcgScan() {
    final String condition = _selectWeightedCondition();
    double hr;
    String rhythm;
    double qt;
    ScanStatus status;

    if (condition == "GREEN") {
      // Normal (60%): HR 65-90, Normal Sinus, QT 360-410
      hr = 65.0 + _rng.nextDouble() * 25.0;
      rhythm = 'Normal Sinus';
      qt = 360.0 + _rng.nextDouble() * 50.0;
      status = ScanStatus.clean;
    } else if (condition == "YELLOW") {
      // Warning (20%): HR 91-115, Normal Sinus, QT 411-445
      hr = 91.0 + _rng.nextDouble() * 24.0;
      rhythm = 'Normal Sinus';
      qt = 411.0 + _rng.nextDouble() * 34.0;
      status = ScanStatus.clean;
    } else {
      // Critical (20%): HR 125-155, Arrhythmia, QT 460-480
      hr = 125.0 + _rng.nextDouble() * 30.0;
      final abnormalRhythms = ['Atrial Fibrillation', 'Sinus Tachycardia'];
      rhythm = abnormalRhythms[_rng.nextInt(abnormalRhythms.length)];
      qt = 460.0 + _rng.nextDouble() * 20.0;
      status = ScanStatus.abnormal;
    }

    _ecgResult = EcgResult(
      heartRate: double.parse(hr.toStringAsFixed(1)),
      rhythm: rhythm,
      qtInterval: double.parse(qt.toStringAsFixed(1)),
    );
    _ecgStatus = status;
    notifyListeners();
  }

  void resetEcgScan() {
    _ecgStatus = ScanStatus.initial;
    _ecgResult = null;
    notifyListeners();
  }

  // ── 3. BP (Dataset Bounds: Systolic 110 - 155) ─────────────────────────
  void runBpScan() {
    final String condition = _selectWeightedCondition();
    int systolic;
    int diastolic;
    int pulse;
    ScanStatus status;

    if (condition == "GREEN") {
      // Normal (60%): Systolic 115-125, Diastolic 75-85
      systolic = 115 + _rng.nextInt(11);
      diastolic = 75 + _rng.nextInt(11);
      pulse = 65 + _rng.nextInt(26);
      status = ScanStatus.clean;
    } else if (condition == "YELLOW") {
      // Warning (20%): Systolic 126-139, Diastolic 86-89
      systolic = 126 + _rng.nextInt(14);
      diastolic = 86 + _rng.nextInt(4);
      pulse = 91 + _rng.nextInt(25);
      status = ScanStatus.clean;
    } else {
      // Critical (20%): Systolic 142-155, Diastolic 92-98
      systolic = 142 + _rng.nextInt(14);
      diastolic = 92 + _rng.nextInt(7);
      pulse = 120 + _rng.nextInt(35);
      status = ScanStatus.abnormal;
    }

    _bpResult = BpResult(
      systolic: systolic,
      diastolic: diastolic,
      pulseRate: pulse,
    );
    _bpStatus = status;
    notifyListeners();
  }

  void resetBpScan() {
    _bpStatus = ScanStatus.initial;
    _bpResult = null;
    notifyListeners();
  }

  // ── 4. SpO2 + Temp (Dataset Bounds: SpO2 70-100, HR 65-160, Temp 36.5-38.8) ──
  void runSpo2TempScan() {
    final String condition = _selectWeightedCondition();
    int spo2;
    int hr;
    double temp;
    ScanStatus status;

    if (condition == "GREEN") {
      // Normal (60%): SpO2 96-100, HR 65-90, Temp 36.5-37.5
      spo2 = 96 + _rng.nextInt(5);
      hr = 65 + _rng.nextInt(26);
      temp = 36.5 + _rng.nextDouble() * 1.0;
      status = ScanStatus.clean;
    } else if (condition == "YELLOW") {
      // Warning (20%): SpO2 92-95, HR 91-115, Temp 37.6-38.2
      spo2 = 92 + _rng.nextInt(4);
      hr = 91 + _rng.nextInt(25);
      temp = 37.6 + _rng.nextDouble() * 0.6;
      status = ScanStatus.clean;
    } else {
      // Critical (20%): Split 50/50 between HR anomaly (10%) and SpO2 anomaly (10%)
      final bool isHrAnomaly = _rng.nextBool();
      if (isHrAnomaly) {
        // HR Anomaly (10% overall): HR 125-155
        spo2 = 95 + _rng.nextInt(4);
        hr = 125 + _rng.nextInt(31);
        temp = 38.3 + _rng.nextDouble() * 0.5;
      } else {
        // SpO2 Anomaly (10% overall): SpO2 75-89
        spo2 = 75 + _rng.nextInt(15);
        hr = 70 + _rng.nextInt(21);
        temp = 36.8 + _rng.nextDouble() * 0.7;
      }
      status = ScanStatus.abnormal;
    }

    _spo2TempResult = Spo2TempResult(
      spo2: spo2,
      heartRate: hr,
      temperature: double.parse(temp.toStringAsFixed(1)),
    );
    _spo2TempStatus = status;
    notifyListeners();
  }

  void resetSpo2TempScan() {
    _spo2TempStatus = ScanStatus.initial;
    _spo2TempResult = null;
    notifyListeners();
  }

  // ── 5. Urine Scan (Weighted: 60% Green, 20% Amber, 20% Red/Dark Brown) ──
  void runUrineScan() {
    final String condition = _selectWeightedCondition();
    String color;
    ScanStatus status;

    if (condition == "GREEN") {
      final normalColors = ['Yellow', 'Yellow', 'Pale Yellow'];
      color = normalColors[_rng.nextInt(normalColors.length)];
      status = ScanStatus.clean;
    } else if (condition == "YELLOW") {
      color = 'Amber';
      status = ScanStatus.clean;
    } else {
      final abnormalColors = ['Red', 'Dark Brown'];
      color = abnormalColors[_rng.nextInt(abnormalColors.length)];
      status = ScanStatus.abnormal;
    }

    final ph = 5.0 + _rng.nextDouble() * 2.5;
    final proteins = ['Negative', 'Negative', 'Trace', 'Positive'];
    final glucoses = ['Negative', 'Negative', 'Trace', 'Positive'];

    _urineResult = UrineResult(
      color: color,
      ph: double.parse(ph.toStringAsFixed(1)),
      protein: proteins[_rng.nextInt(proteins.length)],
      glucose: glucoses[_rng.nextInt(glucoses.length)],
    );
    _urineStatus = status;
    notifyListeners();
  }

  void resetUrineScan() {
    _urineStatus = ScanStatus.initial;
    _urineResult = null;
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════════════════
  // AGGREGATE EVALUATION & NAVIGATION
  // ════════════════════════════════════════════════════════════════════════

  bool get hasAnyAbnormal =>
      _stethStatus == ScanStatus.abnormal ||
      _ecgStatus == ScanStatus.abnormal ||
      _bpStatus == ScanStatus.abnormal ||
      _spo2TempStatus == ScanStatus.abnormal ||
      _urineStatus == ScanStatus.abnormal;

  bool get allTestsComplete =>
      _stethStatus != ScanStatus.initial &&
      _ecgStatus != ScanStatus.initial &&
      _bpStatus != ScanStatus.initial &&
      _spo2TempStatus != ScanStatus.initial &&
      _urineStatus != ScanStatus.initial;

  // ════════════════════════════════════════════════════════════════════════
  // JSON PAYLOAD GENERATOR (For API Sync)
  // ════════════════════════════════════════════════════════════════════════

  List<double> _getUrineRgb(String? color) {
    switch (color?.toLowerCase()) {
      case 'red':
        return [255.0, 0.0, 0.0];
      case 'dark brown':
        return [101.0, 67.0, 33.0];
      case 'amber':
        return [255.0, 191.0, 0.0];
      case 'pale yellow':
        return [255.0, 255.0, 224.0];
      default:
        return [255.0, 255.0, 0.0];
    }
  }

  Map<String, dynamic> generateVitalsJsonPayload() {
    final String activeId = (_patientInfo.id.isEmpty || _patientInfo.id == 'PT-0000' || _patientInfo.id == 'PT-0001')
        ? 'PT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'
        : _patientInfo.id;
    return {
      "patient_id": activeId,
      "timestamp": DateTime.now().toIso8601String(),
      "stethoscope_status": _stethStatus.name,
      "ecg_hr": (_ecgResult?.heartRate ?? _stethResult?.heartRate ?? 72.0).toDouble(),
      "bp_sys": (_bpResult?.systolic ?? 120).toDouble(),
      "bp_dia": (_bpResult?.diastolic ?? 80).toDouble(),
      "spo2": (_spo2TempResult?.spo2 ?? 98).toDouble(),
      "temperature": (_spo2TempResult?.temperature ?? 36.8).toDouble(),
      "urine_rgb": _getUrineRgb(_urineResult?.color),
      "patient_speech_text":
          "Auscultation: ${_stethResult?.lungSound ?? 'Clear'}. ECG Rhythm: ${_ecgResult?.rhythm ?? 'Normal Sinus'}.",
    };
  }

  Map<String, dynamic> generateTriageJsonPayload() {
    final String activeId = (_patientInfo.id.isEmpty || _patientInfo.id == 'PT-0000' || _patientInfo.id == 'PT-0001')
        ? 'PT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'
        : _patientInfo.id;
    return {
      "patient_id": activeId,
      "timestamp": DateTime.now().toIso8601String(),
      "triage": hasAnyAbnormal ? "RED" : "GREEN",
      "confidence": hasAnyAbnormal ? 0.88 : 0.96,
    };
  }

  Map<String, dynamic> generateJsonPayload() {
    return {
      "vitals": generateVitalsJsonPayload(),
      "triage": generateTriageJsonPayload(),
    };
  }

  /// Enforces hard validation rules matching AI training dataset bounds:
  /// - SpO2: 70 to 100
  /// - Heart Rate: 65 to 160
  /// - Systolic BP: 110 to 155
  /// - Temperature: 36.5 to 38.8
  ///
  /// Returns validation error string if out of bounds, or null if valid.
  static String? validateDatasetBounds({
    num? spo2,
    num? heartRate,
    num? systolicBp,
    num? temperature,
  }) {
    if (spo2 != null && (spo2 < 70 || spo2 > 100)) {
      return "SpO2 ($spo2%) out of dataset bounds (70 - 100)";
    }
    if (heartRate != null && (heartRate < 65 || heartRate > 160)) {
      return "Heart Rate ($heartRate BPM) out of dataset bounds (65 - 160)";
    }
    if (systolicBp != null && (systolicBp < 110 || systolicBp > 155)) {
      return "Systolic BP ($systolicBp mmHg) out of dataset bounds (110 - 155)";
    }
    if (temperature != null && (temperature < 36.5 || temperature > 38.8)) {
      return "Temperature ($temperature°C) out of dataset bounds (36.5 - 38.8)";
    }
    return null;
  }

  /// Sends triage data to cloud API. Ensures a fresh dynamic ID is generated right before sync.
  Future<bool> syncDataToCloud() async {
    if (_patientInfo.id.isEmpty || _patientInfo.id == 'PT-0000' || _patientInfo.id == 'PT-0001') {
      final String freshId = 'PT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      _patientInfo = PatientInfo(
        id: freshId,
        name: _patientInfo.name,
        age: _patientInfo.age,
        gender: _patientInfo.gender,
        phone: _patientInfo.phone,
        village: _patientInfo.village,
      );
    }

    // Validate hard dataset bounds
    final String? boundsError = validateDatasetBounds(
      spo2: _spo2TempResult?.spo2,
      heartRate: _stethResult?.heartRate ?? _ecgResult?.heartRate ?? _spo2TempResult?.heartRate,
      systolicBp: _bpResult?.systolic,
      temperature: _spo2TempResult?.temperature,
    );

    if (boundsError != null) {
      debugPrint("⛔ [VALIDATION_ERR] Submission blocked: $boundsError");
      return false;
    }

    final payload = generateJsonPayload();
    return await ApiService.pushTriageData(payload);
  }

  void goToNextStep() {
    if (_currentPage < totalPages - 1) {
      _currentPage++;
      pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  void goToPreviousStep() {
    if (_currentPage > 0) {
      _currentPage--;
      pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  void goToPage(int index) {
    if (index >= 0 && index < totalPages) {
      _currentPage = index;
      pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  void resetAll() {
    _currentPage = 0;
    _patientInfo = PatientInfo.placeholder();

    _stethStatus = ScanStatus.initial;
    _ecgStatus = ScanStatus.initial;
    _bpStatus = ScanStatus.initial;
    _spo2TempStatus = ScanStatus.initial;
    _urineStatus = ScanStatus.initial;

    _stethResult = null;
    _ecgResult = null;
    _bpResult = null;
    _spo2TempResult = null;
    _urineResult = null;

    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
