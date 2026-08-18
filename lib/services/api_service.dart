import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // ── ENVIRONMENT CONFIGURATION ──────────────────────────────────────────────
  // Set to true for local simulation (Port 8000 FastAPI -> Port 8001 ML Engine)
  // Set to false for live production Render backend
  static const bool useLocalServer = true;

  // Render Production Base URL
  static const String _productionUrl = 'https://raksha-api-71a6.onrender.com';

  /// Dynamically resolves the Base URL depending on environment:
  /// - Web / Desktop / Local: http://127.0.0.1:8000
  /// - Android Emulator: http://10.0.2.2:8000
  static String get baseUrl {
    if (!useLocalServer) return _productionUrl;

    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000'; // Android Emulator alias for host localhost
      }
    } catch (_) {}

    return 'http://127.0.0.1:8000';
  }

  /// Pushes both Vitals (/vitals) and Triage (/triage) payloads to backend.
  /// Includes robust error catching and detailed logging for debugging.
  static Future<bool> pushTriageData(Map<String, dynamic> payload) async {
    bool vitalsSuccess = false;
    bool triageSuccess = false;

    debugPrint("════════════════════════════════════════════════════");
    debugPrint("🌐 STARTING CLOUD SYNC TO: $baseUrl (LocalServer: $useLocalServer)");

    // Extract or construct vitals and triage payloads
    final Map<String, dynamic> vitalsPayload =
        payload.containsKey("vitals") && payload["vitals"] is Map
            ? Map<String, dynamic>.from(payload["vitals"])
            : payload;

    final Map<String, dynamic> triagePayload =
        payload.containsKey("triage") && payload["triage"] is Map
            ? Map<String, dynamic>.from(payload["triage"])
            : {
                "patient_id": payload["patient_id"] ?? "PT-0001",
                "timestamp": DateTime.now().toIso8601String(),
                "triage": payload["overall_status"] ?? "GREEN",
                "confidence": 0.95,
              };

    // ── 1. POST /vitals ──────────────────────────────────────────────────────
    try {
      final vitalsUri = Uri.parse('$baseUrl/vitals');
      final vitalsJson = jsonEncode(vitalsPayload);
      debugPrint("🚀 [POST] -> $vitalsUri");
      debugPrint("📦 Vitals Payload: $vitalsJson");

      final vitalsResponse = await http
          .post(
            vitalsUri,
            headers: {'Content-Type': 'application/json'},
            body: vitalsJson,
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("📥 [Response] /vitals StatusCode: ${vitalsResponse.statusCode}");
      debugPrint("📥 [Response] /vitals Body: ${vitalsResponse.body}");

      if (vitalsResponse.statusCode == 200 || vitalsResponse.statusCode == 201) {
        vitalsSuccess = true;
        debugPrint("✅ /vitals sync successful!");
      } else {
        debugPrint(
            "⚠️ /vitals failed with Status ${vitalsResponse.statusCode}: ${vitalsResponse.body}");
      }
    } catch (e, stack) {
      debugPrint("❌ /vitals Exception caught: $e");
      debugPrint("Stacktrace: $stack");
    }

    // ── 2. POST /triage ──────────────────────────────────────────────────────
    try {
      final triageUri = Uri.parse('$baseUrl/triage');
      final triageJson = jsonEncode(triagePayload);
      debugPrint("🚀 [POST] -> $triageUri");
      debugPrint("📦 Triage Payload: $triageJson");

      final triageResponse = await http
          .post(
            triageUri,
            headers: {'Content-Type': 'application/json'},
            body: triageJson,
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("📥 [Response] /triage StatusCode: ${triageResponse.statusCode}");
      debugPrint("📥 [Response] /triage Body: ${triageResponse.body}");

      if (triageResponse.statusCode == 200 || triageResponse.statusCode == 201) {
        triageSuccess = true;
        debugPrint("✅ /triage sync successful!");
      } else {
        debugPrint(
            "⚠️ /triage failed with Status ${triageResponse.statusCode}: ${triageResponse.body}");
      }
    } catch (e, stack) {
      debugPrint("❌ /triage Exception caught: $e");
      debugPrint("Stacktrace: $stack");
    }

    debugPrint("════════════════════════════════════════════════════");
    return vitalsSuccess && triageSuccess;
  }
}
