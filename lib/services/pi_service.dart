import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Handles local Wi-Fi HTTP calls to the Raspberry Pi hardware controller.
/// Enforces lightweight boolean status responses and strict 15-second timeouts.
class PiService {
  final String baseUrl;
  final http.Client _client;

  /// Strict 15-second timeout duration for local hardware network calls.
  static const Duration timeoutDuration = Duration(seconds: 15);

  PiService({
    this.baseUrl = 'http://192.168.4.1:5000',
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Internal helper to execute HTTP calls with a 15-second timeout.
  /// Returns `true` if response is HTTP 200/201 or contains `{ "status": "ok" }`.
  /// On any error or timeout, catches the exception and returns `false`.
  Future<bool> _safeTrigger(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('🚀 [PiService] Sending hardware trigger to: $uri');

      final response = body != null
          ? await _client
              .post(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(body),
              )
              .timeout(timeoutDuration)
          : await _client
              .get(uri)
              .timeout(timeoutDuration);

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
        '⏰ [PiService] Timeout on $endpoint (15s limit exceeded): $e',
      );
      return false;
    } on SocketException catch (e) {
      debugPrint(
        '🔌 [PiService] SocketException on $endpoint (Pi unreachable): $e',
      );
      return false;
    } catch (e, stack) {
      debugPrint('❌ [PiService] Error on $endpoint: $e\n$stack');
      return false;
    }
  }

  /// Notifies the Pi that a new patient session is initialized.
  Future<bool> initSession({String? patientId}) async {
    return await _safeTrigger(
      '/init_session',
      body: {
        'patient_id': patientId ?? 'PT-${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Triggers local ECG reading on the Pi.
  Future<bool> triggerEcg() async {
    return await _safeTrigger('/trigger/ecg');
  }

  /// Triggers local Body Temperature reading on the Pi.
  Future<bool> triggerTemp() async {
    return await _safeTrigger('/trigger/temp');
  }

  /// Triggers local Urine Analysis strip reading on the Pi.
  Future<bool> triggerUrine() async {
    return await _safeTrigger('/trigger/urine');
  }

  /// Triggers local Stethoscope auscultation on the Pi.
  Future<bool> triggerStethoscope() async {
    return await _safeTrigger('/trigger/stethoscope');
  }

  /// Triggers local SpO2 reading on the Pi.
  Future<bool> triggerSpo2() async {
    return await _safeTrigger('/trigger/spo2');
  }

  /// Commands the Pi to upload its aggregated local sensor payload to Render cloud.
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
    );
  }
}
