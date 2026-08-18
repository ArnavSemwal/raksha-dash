import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Live Render backend base endpoint
  static const String baseUrl = 'https://raksha-api-71a6.onrender.com';

  /// Pushes both Vitals (/vitals) and Triage (/triage) payloads to backend.
  static Future<bool> pushTriageData(Map<String, dynamic> payload) async {
    try {
      debugPrint("════════════════════════════════════════════════════");
      debugPrint("🌐 STARTING CLOUD SYNC TO: $baseUrl");

      // Extract or construct vitals and triage payloads
      final Map<String, dynamic> vitalsPayload =
          payload.containsKey("vitals") && payload["vitals"] is Map
              ? Map<String, dynamic>.from(payload["vitals"])
              : payload;

      final Map<String, dynamic> triagePayload =
          payload.containsKey("triage") && payload["triage"] is Map
              ? Map<String, dynamic>.from(payload["triage"])
              : {
                  "patient_id": payload["patient_id"] ?? "PT-0000",
                  "timestamp": DateTime.now().toIso8601String(),
                  "triage": payload["overall_status"] ?? "GREEN",
                  "confidence": 0.95,
                };

      // 1. POST /vitals
      final vitalsUri = Uri.parse('$baseUrl/vitals');
      final vitalsJson = jsonEncode(vitalsPayload);
      debugPrint("🚀 [POST] -> $vitalsUri");
      debugPrint("📦 Vitals Payload: $vitalsJson");

      final vitalsResponse = await http.post(
        vitalsUri,
        headers: {'Content-Type': 'application/json'},
        body: vitalsJson,
      );

      debugPrint("📥 [Response] Status: ${vitalsResponse.statusCode}");
      debugPrint("📥 [Response] Body: ${vitalsResponse.body}");

      // 2. POST /triage
      final triageUri = Uri.parse('$baseUrl/triage');
      final triageJson = jsonEncode(triagePayload);
      debugPrint("🚀 [POST] -> $triageUri");
      debugPrint("📦 Triage Payload: $triageJson");

      final triageResponse = await http.post(
        triageUri,
        headers: {'Content-Type': 'application/json'},
        body: triageJson,
      );

      debugPrint("📥 [Response] Status: ${triageResponse.statusCode}");
      debugPrint("📥 [Response] Body: ${triageResponse.body}");
      debugPrint("════════════════════════════════════════════════════");

      bool vitalsSuccess =
          vitalsResponse.statusCode == 200 || vitalsResponse.statusCode == 201;
      bool triageSuccess =
          triageResponse.statusCode == 200 || triageResponse.statusCode == 201;

      return vitalsSuccess && triageSuccess;
    } catch (e, stack) {
      debugPrint("❌ [API ERROR] Network or Sync Exception: $e");
      debugPrint("StackTrace: $stack");
      print("Network error aagaya bhai: $e");
      return false;
    }
  }
}
