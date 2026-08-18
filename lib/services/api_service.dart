import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  // Anushka jab actual Render URL degi, toh bas ye link change karna padega
  static const String baseUrl =
      'https://raksha-backend-mock.onrender.com/api/v1/triage';

  static Future<bool> pushTriageData(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      // 200 ya 201 HTTP status code matlab data successfully cloud pe chala gaya
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Data synced successfully vibe check passed: ${response.body}");
        return true;
      } else {
        print("Server error, kalesh ho gaya: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Network error aagaya bhai: $e");
      return false;
    }
  }
}
