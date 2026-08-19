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

  // ── 1. Stethoscope (Dataset Bounds: HR 65 - 160) ────────────────────────
  void runStethScan() {
    // Generate Heart Rate strictly between 65.0 and 160.0
    final hr = (65.0 + _rng.nextDouble() * 95.0).clamp(65.0, 160.0);
    final lungSounds = ['Clear', 'Clear', 'Clear', 'Wheezing', 'Crackles'];
    final lung = lungSounds[_rng.nextInt(lungSounds.length)];

    _stethResult = StethResult(
      heartRate: double.parse(hr.toStringAsFixed(1)),
      lungSound: lung,
    );

    final bool isAbnormal =
        hr < 70 || hr > 120 || lung == 'Crackles' || lung == 'Wheezing';

    _stethStatus = isAbnormal ? ScanStatus.abnormal : ScanStatus.clean;
    notifyListeners();
  }

  void resetStethScan() {
    _stethStatus = ScanStatus.initial;
    _stethResult = null;
    notifyListeners();
  }

  // ── 2. ECG (Dataset Bounds: HR 65 - 160) ────────────────────────────────
  void runEcgScan() {
    // Generate Heart Rate strictly between 65.0 and 160.0
    final hr = (65.0 + _rng.nextDouble() * 95.0).clamp(65.0, 160.0);
    final rhythms = [
      'Normal Sinus',
      'Normal Sinus',
      'Normal Sinus',
      'Atrial Fibrillation',
      'Sinus Tachycardia',
    ];
    final rhythm = rhythms[_rng.nextInt(rhythms.length)];
    final qt = 350.0 + _rng.nextDouble() * 130;

    _ecgResult = EcgResult(
      heartRate: double.parse(hr.toStringAsFixed(1)),
      rhythm: rhythm,
      qtInterval: double.parse(qt.toStringAsFixed(1)),
    );

    final bool isAbnormal =
        hr < 70 || hr > 120 || rhythm != 'Normal Sinus' || qt > 460;

    _ecgStatus = isAbnormal ? ScanStatus.abnormal : ScanStatus.clean;
    notifyListeners();
  }

  void resetEcgScan() {
    _ecgStatus = ScanStatus.initial;
    _ecgResult = null;
    notifyListeners();
  }

  // ── 3. BP (Dataset Bounds: Systolic 110 - 155) ─────────────────────────
  void runBpScan() {
    // Generate Systolic BP strictly between 110 and 155
    final systolic = (110 + _rng.nextInt(46)).clamp(110, 155);
    final diastolic = (65 + _rng.nextInt(31)).clamp(65, 95);
    final pulse = (65 + _rng.nextInt(76)).clamp(65, 140);

    _bpResult = BpResult(
      systolic: systolic,
      diastolic: diastolic,
      pulseRate: pulse,
    );

    final bool isAbnormal =
        systolic > 140 || systolic < 115 || diastolic > 90 || diastolic < 60;

    _bpStatus = isAbnormal ? ScanStatus.abnormal : ScanStatus.clean;
    notifyListeners();
  }

  void resetBpScan() {
    _bpStatus = ScanStatus.initial;
    _bpResult = null;
    notifyListeners();
  }

  // ── 4. SpO2 + Temp (Dataset Bounds: SpO2 70-100, HR 65-160, Temp 36.5-38.8) ──
  void runSpo2TempScan() {
    // SpO2: 70 to 100
    final spo2 = (70 + _rng.nextInt(31)).clamp(70, 100);
    // HR: 65 to 160
    final hr = (65 + _rng.nextInt(96)).clamp(65, 160);
    // Temp: 36.5 to 38.8
    final temp = (36.5 + _rng.nextDouble() * 2.3).clamp(36.5, 38.8);

    _spo2TempResult = Spo2TempResult(
      spo2: spo2,
      heartRate: hr,
      temperature: double.parse(temp.toStringAsFixed(1)),
    );

    final bool isAbnormal =
        spo2 < 92 || hr < 65 || hr > 120 || temp > 37.8 || temp < 36.5;

    _spo2TempStatus = isAbnormal ? ScanStatus.abnormal : ScanStatus.clean;
    notifyListeners();
  }

  void resetSpo2TempScan() {
    _spo2TempStatus = ScanStatus.initial;
    _spo2TempResult = null;
    notifyListeners();
  }

  // ── 5. Urine Scan (Strict MEWS: Color = "Red" or "Dark Brown") ──
  void runUrineScan() {
    final colors = [
      'Yellow',
      'Yellow',
      'Pale Yellow',
      'Amber',
      'Red',
      'Dark Brown',
    ];
    final color = colors[_rng.nextInt(colors.length)];
    final ph = 4.5 + _rng.nextDouble() * 4.5;
    final proteins = ['Negative', 'Negative', 'Trace', 'Positive'];
    final glucoses = ['Negative', 'Negative', 'Trace', 'Positive'];

    _urineResult = UrineResult(
      color: color,
      ph: double.parse(ph.toStringAsFixed(1)),
      protein: proteins[_rng.nextInt(proteins.length)],
      glucose: glucoses[_rng.nextInt(glucoses.length)],
    );

    final bool isAbnormal = color == 'Red' || color == 'Dark Brown';

    _urineStatus = isAbnormal ? ScanStatus.abnormal : ScanStatus.clean;
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
