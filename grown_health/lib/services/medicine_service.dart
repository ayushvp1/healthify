import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class MedicineService {
  final String token;

  MedicineService(this.token);

  Future<List<Map<String, dynamic>>> getUserMedicines() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/user-medicines'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to load medicines: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> addUserMedicine(
    Map<String, dynamic> medicineData,
  ) async {
    // Map frontend data to backend structure
    final body = {
      'name': medicineData['name'],
      'dosage': medicineData['dosage'],
      'instructions': medicineData['instructions'],
      'frequency': medicineData['frequency']?.toLowerCase() ?? 'daily',
      'startDate': (medicineData['startDate'] as DateTime).toIso8601String(),
      'endDate': medicineData['endDate'] != null
          ? (medicineData['endDate'] as DateTime).toIso8601String()
          : null,
      'reminderTimes': (medicineData['times'] as List<TimeOfDay>)
          .map(
            (t) => {
              'time':
                  '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
              'enabled': true,
              'label': 'Reminder',
            },
          )
          .toList(),
    };

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/user-medicines'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to add medicine: ${response.body}');
    }
  }

  Future<void> deleteUserMedicine(String id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/user-medicines/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete medicine: ${response.body}');
    }
  }
}
