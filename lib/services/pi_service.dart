import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Handles local Wi-Fi HTTP calls to the ESP32 / Raspberry Pi hardware controller.
/// Enforces per-sensor timeouts and lightweight boolean status responses.
class PiService {
  final String baseUrl;
  final http.Client _client;

  PiService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? AppConfig.hardwareBaseUrl,
        _client = client ?? http.Client();

  /// Internal helper to execute HTTP calls with a sensor-specific timeout.
  /// Returns `true` if response is HTTP 200/201 or contains `{ "status": "ok" }`.
  /// On any error or timeout, catches the exception and returns `false`.
  Future<bool> _safeTrigger(
    String endpoint, {
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('🚀 [PiService] Sending hardware trigger to: $uri (timeout: ${timeout.inSeconds}s)');

      final response = body != null
          ? await _client
              .post(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(body),
              )
              .timeout(timeout)
          : await _client
              .get(uri)
              .timeout(timeout);

      debugPrint(
        '📥 [PiService] Response ($endpoint) -> Code: ${response.statusCode}, Body: ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic> && decoded['status'] == 'ok') {
            return true;
          }
        } catch (_) {
          // If body is plain text or raw OK, fall through to status code success
        }
        return true;
      }
      return false;
    } on TimeoutException catch (e) {
      debugPrint(
        '⏰ [PiService] Timeout on $endpoint (${timeout.inSeconds}s limit exceeded): $e',
      );
      return false;
    } on SocketException catch (e) {
      debugPrint(
        '🔌 [PiService] SocketException on $endpoint (Hardware unreachable): $e',
      );
      return false;
    } catch (e, stack) {
      debugPrint('❌ [PiService] Error on $endpoint: $e\n$stack');
      return false;
    }
  }

  /// Notifies the hardware controller that a new patient session is initialized.
  Future<bool> initSession({String? patientId}) async {
    return await _safeTrigger(
      '/init_session',
      body: {
        'patient_id': patientId ?? 'PT-${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().toIso8601String(),
      },
      timeout: const Duration(seconds: 5),
    );
  }

  /// Triggers local ECG reading (AD8232 - 5s timeout).
  Future<bool> triggerEcg() async {
    return await _safeTrigger('/trigger/ecg', timeout: AppConfig.ecgTimeout);
  }

  /// Triggers local Body Temperature reading (MLX90614 - 2s timeout).
  Future<bool> triggerTemp() async {
    return await _safeTrigger('/trigger/temp', timeout: AppConfig.temperatureTimeout);
  }

  /// Triggers local Urine Analysis strip reading (TCS3200 - 3s timeout).
  Future<bool> triggerUrine() async {
    return await _safeTrigger('/trigger/urine', timeout: AppConfig.urineTimeout);
  }

  /// Triggers local Stethoscope auscultation (MAX4466 - 5s timeout).
  Future<bool> triggerStethoscope() async {
    return await _safeTrigger('/trigger/stethoscope', timeout: AppConfig.stethoscopeTimeout);
  }

  /// Triggers local SpO2 reading (MAX30102 - 12s timeout).
  Future<bool> triggerSpo2() async {
    return await _safeTrigger('/trigger/spo2', timeout: AppConfig.pulseOximeterTimeout);
  }

  /// Commands the hardware controller to upload its aggregated local sensor payload.
  Future<bool> finalizeTriage({String? patientId}) async {
    final Map<String, dynamic> payload = {
      'timestamp': DateTime.now().toIso8601String(),
    };
    if (patientId != null) {
      payload['patient_id'] = patientId;
    }
    return await _safeTrigger(
      '/finalize_triage',
      body: payload,
      timeout: const Duration(seconds: 15),
    );
  }
}
