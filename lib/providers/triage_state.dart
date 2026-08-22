import 'package:flutter/foundation.dart';
import '../models/vital_test_type.dart';

export '../models/vital_test_type.dart';

/// Lightweight app state for modular hardware triage.
/// Tracks all 5 vitals + voice status independently: Empty -> Loading -> Completed.
class TriageState extends ChangeNotifier {
  final Map<VitalTestType, TestCardStatus> _cardStatuses = {
    VitalTestType.spo2: TestCardStatus.empty,
    VitalTestType.hr: TestCardStatus.empty,
    VitalTestType.temp: TestCardStatus.empty,
    VitalTestType.urine: TestCardStatus.empty,
    VitalTestType.stethoscope: TestCardStatus.empty,
    VitalTestType.voice: TestCardStatus.empty,
  };

  // Optional measured value store
  final Map<VitalTestType, String> _readings = {
    VitalTestType.spo2: '98%',
    VitalTestType.hr: '72 BPM',
    VitalTestType.temp: '98.6°F',
    VitalTestType.urine: 'NORMAL',
    VitalTestType.stethoscope: 'CLEAR',
    VitalTestType.voice: 'RECORDED',
  };

  // ── STATUS GETTERS ─────────────────────────────────────────────────────────

  TestCardStatus getStatus(VitalTestType type) =>
      _cardStatuses[type] ?? TestCardStatus.empty;

  bool isCompleted(VitalTestType type) =>
      _cardStatuses[type] == TestCardStatus.completed;

  bool isLoading(VitalTestType type) =>
      _cardStatuses[type] == TestCardStatus.loading;

  String getReading(VitalTestType type) => _readings[type] ?? '--';

  // Legacy boolean getters for backwards compatibility
  bool get isSpo2Done => _cardStatuses[VitalTestType.spo2] == TestCardStatus.completed;
  bool get isEcgDone => _cardStatuses[VitalTestType.hr] == TestCardStatus.completed;
  bool get isTempDone => _cardStatuses[VitalTestType.temp] == TestCardStatus.completed;
  bool get isUrineDone => _cardStatuses[VitalTestType.urine] == TestCardStatus.completed;
  bool get isStethoscopeDone => _cardStatuses[VitalTestType.stethoscope] == TestCardStatus.completed;

  /// Returns true when all 5 required hardware vital tests are completed.
  /// Note: Voice input is tracked independently and does not block AI triage.
  bool get isReadyForAI {
    const requiredVitals = [
      VitalTestType.spo2,
      VitalTestType.hr,
      VitalTestType.temp,
      VitalTestType.urine,
      VitalTestType.stethoscope,
    ];
    return requiredVitals.every((type) => _cardStatuses[type] == TestCardStatus.completed);
  }

  // ── STATE MODIFIERS ────────────────────────────────────────────────────────

  void setStatus(VitalTestType type, TestCardStatus status) {
    _cardStatuses[type] = status;
    notifyListeners();
  }

  void markCompleted(VitalTestType type, {String? reading}) {
    _cardStatuses[type] = TestCardStatus.completed;
    if (reading != null) {
      _readings[type] = reading;
    }
    notifyListeners();
  }

  void markLoading(VitalTestType type) {
    _cardStatuses[type] = TestCardStatus.loading;
    notifyListeners();
  }

  void markEmpty(VitalTestType type) {
    _cardStatuses[type] = TestCardStatus.empty;
    notifyListeners();
  }

  // Legacy mark functions
  void markSpo2Done() => markCompleted(VitalTestType.spo2);
  void markEcgDone() => markCompleted(VitalTestType.hr);
  void markTempDone() => markCompleted(VitalTestType.temp);
  void markUrineDone() => markCompleted(VitalTestType.urine);
  void markStethoscopeDone() => markCompleted(VitalTestType.stethoscope);

  /// Resets all test completion flags to empty for a new triage session.
  void reset() {
    for (final type in VitalTestType.values) {
      _cardStatuses[type] = TestCardStatus.empty;
    }
    notifyListeners();
  }
}
