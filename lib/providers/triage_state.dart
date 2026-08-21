import 'package:flutter/foundation.dart';

/// Lightweight app state for modular hardware triage.
/// Uses simple boolean flags to track test completion during intermediate steps
/// without storing large JSON payloads in memory.
class TriageState extends ChangeNotifier {
  bool _isEcgDone = false;
  bool _isTempDone = false;
  bool _isUrineDone = false;
  bool _isStethoscopeDone = false;
  bool _isSpo2Done = false;

  // ── GETTERS ────────────────────────────────────────────────────────────────

  bool get isEcgDone => _isEcgDone;
  bool get isTempDone => _isTempDone;
  bool get isUrineDone => _isUrineDone;
  bool get isStethoscopeDone => _isStethoscopeDone;
  bool get isSpo2Done => _isSpo2Done;

  /// Returns true only when all required hardware tests are completed.
  bool get isReadyForAI =>
      _isEcgDone &&
      _isTempDone &&
      _isUrineDone &&
      _isStethoscopeDone &&
      _isSpo2Done;

  // ── TOGGLE / MARK FUNCTIONS ────────────────────────────────────────────────

  void markEcgDone() {
    _isEcgDone = true;
    notifyListeners();
  }

  void markTempDone() {
    _isTempDone = true;
    notifyListeners();
  }

  void markUrineDone() {
    _isUrineDone = true;
    notifyListeners();
  }

  void markStethoscopeDone() {
    _isStethoscopeDone = true;
    notifyListeners();
  }

  void markSpo2Done() {
    _isSpo2Done = true;
    notifyListeners();
  }

  /// Resets all test completion flags to false for a new triage session.
  void reset() {
    _isEcgDone = false;
    _isTempDone = false;
    _isUrineDone = false;
    _isStethoscopeDone = false;
    _isSpo2Done = false;
    notifyListeners();
  }
}
