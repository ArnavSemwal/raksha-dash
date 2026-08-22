/// Enumeration of sequential vital test types including voice input.
enum VitalTestType {
  spo2,
  hr,
  temp,
  urine,
  stethoscope,
  voice,
}

/// Status of each test item on the dashboard.
enum TestCardStatus {
  empty,
  loading,
  completed,
}
