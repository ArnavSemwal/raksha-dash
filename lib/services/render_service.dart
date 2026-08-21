import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/vitals_model.dart';

export '../models/vitals_model.dart';

/// Cloud fetcher service specifically for retrieving final aggregated triage data
/// from the Render cloud deployment (https://raksha-sim.onrender.com).
class RenderService {
  static const String defaultCloudUrl = 'https://raksha-sim.onrender.com';
  static const Duration requestTimeout = Duration(seconds: 35);

  final String cloudUrl;
  final http.Client _client;

  RenderService({
    this.cloudUrl = defaultCloudUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Fetches final triage payload from Render cloud and decodes it into a VitalsModel.
  /// Handles cold starts, network timeouts, and JSON parsing exceptions gracefully.
  Future<VitalsModel?> fetchFinalTriageData({String? patientId}) async {
    try {
      final String endpoint = (patientId != null && patientId.isNotEmpty)
          ? '$cloudUrl/fetch_final_triage?patient_id=$patientId'
          : '$cloudUrl/fetch_final_triage';

      final uri = Uri.parse(endpoint);
      debugPrint('🚀 [RenderService] Requesting final triage data -> $uri');

      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(requestTimeout);

      debugPrint(
        '📥 [RenderService] Response Status: ${response.statusCode}',
      );
      debugPrint('📥 [RenderService] Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final vitalsModel = VitalsModel.fromJson(decoded);
          debugPrint(
            '✅ [RenderService] Successfully fetched and parsed VitalsModel for patient: ${vitalsModel.patientId}',
          );
          return vitalsModel;
        } else {
          debugPrint(
            '⚠️ [RenderService] JSON response is not a valid Map object.',
          );
          return null;
        }
      } else {
        debugPrint(
          '⚠️ [RenderService] Render cloud returned error status ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } on TimeoutException catch (e) {
      debugPrint(
        '⏰ [RenderService] Timeout fetching final triage data (${requestTimeout.inSeconds}s limit): $e',
      );
      return null;
    } on SocketException catch (e) {
      debugPrint(
        '🔌 [RenderService] Network/Socket error connecting to Render cloud: $e',
      );
      return null;
    } on FormatException catch (e) {
      debugPrint('📄 [RenderService] Failed to parse JSON response: $e');
      return null;
    } catch (e, stack) {
      debugPrint(
        '❌ [RenderService] Unexpected exception fetching final triage data: $e\n$stack',
      );
      return null;
    }
  }
}
