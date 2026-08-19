import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, SocketException;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ApiService with smart environment resolution, automatic CORS fallback,
/// pre-flight JSON audit, typed exception logging, and offline fail-safe caching.
class ApiService {
  // ── ENVIRONMENT CONFIGURATION ──────────────────────────────────────────────
  // Set to false = PRODUCTION MODE → all traffic routed to Render cloud
  // Set to true  = LOCAL MODE       → traffic routed to 127.0.0.1:8000
  static const bool useLocalServer = false;

  // ── PRODUCTION URLS (no trailing slash — prevents double-slash on endpoint append)
  static const String _productionUrl = 'https://raksha-api-71a6.onrender.com';
  static const String mlEngineUrl    = 'https://raksha-sim.onrender.com';

  // Request timeout — 35s accounts for Render free-tier cold starts
  static const Duration requestTimeout = Duration(seconds: 35);

  /// Primary Base URL — resolves to production or local depending on flag
  static String get baseUrl {
    if (!useLocalServer) return _productionUrl;
    return _localUrl;
  }

  /// Local Base URL resolver
  static String get _localUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000'; // Android Emulator host alias
      }
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  /// Caches failed sync payloads to shared preferences for safe offline recovery.
  static Future<void> cacheFailedPayload(Map<String, dynamic> payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> offlineData = prefs.getStringList('unsynced_patients') ?? [];

      final String serialized = jsonEncode(payload);

      if (!offlineData.contains(serialized)) {
        offlineData.add(serialized);
        await prefs.setStringList('unsynced_patients', offlineData);
        debugPrint(
          "💾 [OFFLINE_CACHE] Patient data securely cached locally. Total unsynced: ${offlineData.length}",
        );
      } else {
        debugPrint(
          "💾 [OFFLINE_CACHE] Payload already present in local cache. Skipping duplicate.",
        );
      }
    } catch (e, stack) {
      debugPrint(
        "❌ [OFFLINE_CACHE_ERR] Failed to write to SharedPreferences: $e",
      );
      debugPrint("Stacktrace: $stack");
    }
  }

  /// Internal helper to post to an endpoint with timeout and headers
  static Future<http.Response> _safePost(Uri uri, String body) async {
    return await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: body,
        )
        .timeout(requestTimeout);
  }

  /// Pushes both Vitals (/vitals) and Triage (/triage) payloads to backend.
  /// Features automatic endpoint fallback (Render -> Local), pre-flight JSON validation,
  /// verbose diagnostic logging, and single-point fallback caching.
  static Future<bool> pushTriageData(Map<String, dynamic> payload) async {
    bool vitalsSuccess = false;
    bool triageSuccess = false;

    debugPrint("════════════════════════════════════════════════════");
    debugPrint(
      "🌐 STARTING CLOUD SYNC TO: $baseUrl (LocalServer: $useLocalServer)",
    );

    // ── PRE-FLIGHT JSON SERIALIZATION AUDIT ──────────────────────────────────
    Map<String, dynamic> vitalsPayload;
    Map<String, dynamic> triagePayload;
    String vitalsJson = "";
    String triageJson = "";

    try {
      vitalsPayload =
          payload.containsKey("vitals") && payload["vitals"] is Map
              ? Map<String, dynamic>.from(payload["vitals"])
              : payload;

      triagePayload =
          payload.containsKey("triage") && payload["triage"] is Map
              ? Map<String, dynamic>.from(payload["triage"])
              : {
                "patient_id": payload["patient_id"] ??
                    'PT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                "timestamp": DateTime.now().toIso8601String(),
                "triage": payload["overall_status"] ?? "GREEN",
                "confidence": 0.95,
              };

      vitalsJson = jsonEncode(vitalsPayload);
      triageJson = jsonEncode(triagePayload);
      debugPrint(
        "✅ [PREFLIGHT] JSON payload serialization verified successfully.",
      );
    } catch (e, stack) {
      debugPrint(
        "❌ [PREFLIGHT_ERR] Serialization failed before HTTP dispatch: Type=${e.runtimeType}, Error=$e",
      );
      debugPrint("Stacktrace: $stack");
      await cacheFailedPayload(payload);
      return false;
    }

    // ── 1. POST /vitals ──────────────────────────────────────────────────────
    try {
      Uri vitalsUri = Uri.parse('$baseUrl/vitals');
      debugPrint("🚀 [HTTP_POST] -> $vitalsUri");
      debugPrint("📦 Vitals Body: $vitalsJson");

      http.Response vitalsResponse;
      try {
        vitalsResponse = await _safePost(vitalsUri, vitalsJson);
      } catch (firstErr) {
        // If primary URL failed (e.g. Render CORS block on web), try local fallback URL
        if (baseUrl != _localUrl) {
          debugPrint("⚠️ Primary endpoint failed ($firstErr). Attempting local fallback: $_localUrl/vitals");
          vitalsUri = Uri.parse('$_localUrl/vitals');
          vitalsResponse = await _safePost(vitalsUri, vitalsJson);
        } else {
          rethrow;
        }
      }

      debugPrint(
        "📥 [HTTP_RESP] /vitals StatusCode: ${vitalsResponse.statusCode}",
      );
      debugPrint("📥 [HTTP_RESP] /vitals Body: ${vitalsResponse.body}");

      if (vitalsResponse.statusCode == 200 ||
          vitalsResponse.statusCode == 201) {
        vitalsSuccess = true;
        debugPrint("✅ [SUCCESS] /vitals sync acknowledged by backend.");
      } else {
        debugPrint(
          "⚠️ [HTTP_WARN] /vitals rejected with Status ${vitalsResponse.statusCode}: ${vitalsResponse.body}",
        );
      }
    } on TimeoutException catch (e) {
      debugPrint(
        "⏰ [TIMEOUT_ERR] /vitals request timed out after ${requestTimeout.inSeconds}s: $e",
      );
    } on SocketException catch (e) {
      debugPrint(
        "🔌 [NET_ERR] /vitals SocketException (No connection/DNS failure): $e",
      );
    } on FormatException catch (e) {
      debugPrint("📄 [FORMAT_ERR] /vitals Bad response format: $e");
    } catch (e, stack) {
      debugPrint(
        "❌ [CORS/HTTP_ERR] /vitals Exception (${e.runtimeType}): $e",
      );
      debugPrint("Stacktrace: $stack");
    }

    // ── 2. POST /triage ──────────────────────────────────────────────────────
    try {
      Uri triageUri = Uri.parse('$baseUrl/triage');
      debugPrint("🚀 [HTTP_POST] -> $triageUri");
      debugPrint("📦 Triage Body: $triageJson");

      http.Response triageResponse;
      try {
        triageResponse = await _safePost(triageUri, triageJson);
      } catch (firstErr) {
        if (baseUrl != _localUrl) {
          debugPrint("⚠️ Primary endpoint failed ($firstErr). Attempting local fallback: $_localUrl/triage");
          triageUri = Uri.parse('$_localUrl/triage');
          triageResponse = await _safePost(triageUri, triageJson);
        } else {
          rethrow;
        }
      }

      debugPrint(
        "📥 [HTTP_RESP] /triage StatusCode: ${triageResponse.statusCode}",
      );
      debugPrint("📥 [Response] /triage Body: ${triageResponse.body}");

      if (triageResponse.statusCode == 200 ||
          triageResponse.statusCode == 201) {
        triageSuccess = true;
        debugPrint("✅ [SUCCESS] /triage sync acknowledged by backend.");
      } else {
        debugPrint(
          "⚠️ [HTTP_WARN] /triage rejected with Status ${triageResponse.statusCode}: ${triageResponse.body}",
        );
      }
    } on TimeoutException catch (e) {
      debugPrint(
        "⏰ [TIMEOUT_ERR] /triage request timed out after ${requestTimeout.inSeconds}s: $e",
      );
    } on SocketException catch (e) {
      debugPrint("🔌 [NET_ERR] /triage SocketException: $e");
    } on FormatException catch (e) {
      debugPrint("📄 [FORMAT_ERR] /triage Bad response format: $e");
    } catch (e, stack) {
      debugPrint(
        "❌ [CORS/HTTP_ERR] /triage Exception (${e.runtimeType}): $e",
      );
      debugPrint("Stacktrace: $stack");
    }

    final bool overallSuccess = vitalsSuccess && triageSuccess;

    // ── SINGLE-SOURCE OFFLINE CACHING FALLBACK ───────────────────────────────
    if (!overallSuccess) {
      debugPrint(
        "⚠️ [SYNC_FAILED] Overall sync incomplete (vitals: $vitalsSuccess, triage: $triageSuccess). Caching payload locally.",
      );
      await cacheFailedPayload(payload);
    } else {
      debugPrint(
        "🎉 [SYNC_COMPLETE] Both /vitals and /triage successfully synced to backend.",
      );
    }

    debugPrint("════════════════════════════════════════════════════");
    return overallSuccess;
  }
}
