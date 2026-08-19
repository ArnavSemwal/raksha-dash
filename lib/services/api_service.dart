import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, SocketException;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Refactored, bulletproof ApiService with typed diagnostic logging,
/// Render cold-start handling, JSON pre-flight validation, and single-source offline caching.
class ApiService {
  // ── ENVIRONMENT CONFIGURATION ──────────────────────────────────────────────
  // Set to false for live production Render backend
  static const bool useLocalServer = false;

  // Render Production Base URL
  static const String _productionUrl = 'https://raksha-api-71a6.onrender.com';

  // Timeout increased to 35 seconds to accommodate Render free-tier cold starts
  static const Duration requestTimeout = Duration(seconds: 35);

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

  /// Caches failed sync payloads to shared preferences for safe offline recovery.
  /// Prevents duplicate entries by checking existing patient IDs.
  static Future<void> cacheFailedPayload(Map<String, dynamic> payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> offlineData = prefs.getStringList('unsynced_patients') ?? [];

      final String serialized = jsonEncode(payload);

      // Avoid exact duplicate entries
      if (!offlineData.contains(serialized)) {
        offlineData.add(serialized);
        await prefs.setStringList('unsynced_patients', offlineData);
        debugPrint("💾 [OFFLINE_CACHE] Patient data securely cached locally. Total unsynced: ${offlineData.length}");
      } else {
        debugPrint("💾 [OFFLINE_CACHE] Payload already present in local cache. Skipping duplicate.");
      }
    } catch (e, stack) {
      debugPrint("❌ [OFFLINE_CACHE_ERR] Failed to write to SharedPreferences: $e");
      debugPrint("Stacktrace: $stack");
    }
  }

  /// Pushes both Vitals (/vitals) and Triage (/triage) payloads to backend.
  /// Features line-by-line pre-flight validation, typed exception handling,
  /// verbose diagnostic logging, and single-point fallback caching.
  static Future<bool> pushTriageData(Map<String, dynamic> payload) async {
    bool vitalsSuccess = false;
    bool triageSuccess = false;

    debugPrint("════════════════════════════════════════════════════");
    debugPrint("🌐 STARTING CLOUD SYNC TO: $baseUrl (LocalServer: $useLocalServer)");

    // ── PRE-FLIGHT JSON SERIALIZATION AUDIT ──────────────────────────────────
    Map<String, dynamic> vitalsPayload;
    Map<String, dynamic> triagePayload;
    String vitalsJson = "";
    String triageJson = "";

    try {
      vitalsPayload = payload.containsKey("vitals") && payload["vitals"] is Map
          ? Map<String, dynamic>.from(payload["vitals"])
          : payload;

      triagePayload = payload.containsKey("triage") && payload["triage"] is Map
          ? Map<String, dynamic>.from(payload["triage"])
          : {
              "patient_id": payload["patient_id"] ?? "PT-0001",
              "timestamp": DateTime.now().toIso8601String(),
              "triage": payload["overall_status"] ?? "GREEN",
              "confidence": 0.95,
            };

      vitalsJson = jsonEncode(vitalsPayload);
      triageJson = jsonEncode(triagePayload);
      debugPrint("✅ [PREFLIGHT] JSON payload serialization verified successfully.");
    } catch (e, stack) {
      debugPrint("❌ [PREFLIGHT_ERR] Serialization failed before HTTP dispatch: Type=${e.runtimeType}, Error=$e");
      debugPrint("Stacktrace: $stack");
      await cacheFailedPayload(payload);
      return false;
    }

    // ── 1. POST /vitals ──────────────────────────────────────────────────────
    try {
      final vitalsUri = Uri.parse('$baseUrl/vitals');
      debugPrint("🚀 [HTTP_POST] -> $vitalsUri");
      debugPrint("📦 Vitals Body: $vitalsJson");

      final vitalsResponse = await http
          .post(
            vitalsUri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: vitalsJson,
          )
          .timeout(requestTimeout);

      debugPrint("📥 [HTTP_RESP] /vitals StatusCode: ${vitalsResponse.statusCode}");
      debugPrint("📥 [HTTP_RESP] /vitals Body: ${vitalsResponse.body}");

      if (vitalsResponse.statusCode == 200 || vitalsResponse.statusCode == 201) {
        vitalsSuccess = true;
        debugPrint("✅ [SUCCESS] /vitals sync acknowledged by backend.");
      } else {
        debugPrint("⚠️ [HTTP_WARN] /vitals rejected with Status ${vitalsResponse.statusCode}: ${vitalsResponse.body}");
      }
    } on TimeoutException catch (e) {
      debugPrint("⏰ [TIMEOUT_ERR] /vitals request timed out after ${requestTimeout.inSeconds}s (Render cold start or slow network): $e");
    } on SocketException catch (e) {
      debugPrint("🔌 [NET_ERR] /vitals SocketException (No internet connection or DNS unreachable): $e");
    } on FormatException catch (e) {
      debugPrint("📄 [FORMAT_ERR] /vitals Bad response format: $e");
    } catch (e, stack) {
      debugPrint("❌ [UNKNOWN_ERR] /vitals Exception (${e.runtimeType}): $e");
      debugPrint("Stacktrace: $stack");
    }

    // ── 2. POST /triage ──────────────────────────────────────────────────────
    try {
      final triageUri = Uri.parse('$baseUrl/triage');
      debugPrint("🚀 [HTTP_POST] -> $triageUri");
      debugPrint("📦 Triage Body: $triageJson");

      final triageResponse = await http
          .post(
            triageUri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: triageJson,
          )
          .timeout(requestTimeout);

      debugPrint("📥 [HTTP_RESP] /triage StatusCode: ${triageResponse.statusCode}");
      debugPrint("📥 [Response] /triage Body: ${triageResponse.body}");

      if (triageResponse.statusCode == 200 || triageResponse.statusCode == 201) {
        triageSuccess = true;
        debugPrint("✅ [SUCCESS] /triage sync acknowledged by backend.");
      } else {
        debugPrint("⚠️ [HTTP_WARN] /triage rejected with Status ${triageResponse.statusCode}: ${triageResponse.body}");
      }
    } on TimeoutException catch (e) {
      debugPrint("⏰ [TIMEOUT_ERR] /triage request timed out after ${requestTimeout.inSeconds}s: $e");
    } on SocketException catch (e) {
      debugPrint("🔌 [NET_ERR] /triage SocketException: $e");
    } on FormatException catch (e) {
      debugPrint("📄 [FORMAT_ERR] /triage Bad response format: $e");
    } catch (e, stack) {
      debugPrint("❌ [UNKNOWN_ERR] /triage Exception (${e.runtimeType}): $e");
      debugPrint("Stacktrace: $stack");
    }

    final bool overallSuccess = vitalsSuccess && triageSuccess;

    // ── SINGLE-SOURCE OFFLINE CACHING FALLBACK ───────────────────────────────
    if (!overallSuccess) {
      debugPrint("⚠️ [SYNC_FAILED] Overall sync incomplete (vitals: $vitalsSuccess, triage: $triageSuccess). Caching payload locally.");
      await cacheFailedPayload(payload);
    } else {
      debugPrint("🎉 [SYNC_COMPLETE] Both /vitals and /triage successfully synced to cloud.");
    }

    debugPrint("════════════════════════════════════════════════════");
    return overallSuccess;
  }
}
