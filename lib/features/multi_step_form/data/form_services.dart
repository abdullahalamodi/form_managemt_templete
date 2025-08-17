import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'form_data.dart';

class FormPersistenceService {
  static const String _formDataKey = 'multi_step_form_data';
  static const String _currentStepKey = 'multi_step_form_current_step';

  Future<void> saveFormData(FormData data, FormStep currentStep) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_formDataKey, jsonEncode(data.toJson()));
    await prefs.setString(_currentStepKey, currentStep.name);
  }

  Future<(FormData?, FormStep?)> loadFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataJson = prefs.getString(_formDataKey);
      final stepName = prefs.getString(_currentStepKey);

      FormData? data;
      FormStep? step;

      if (dataJson != null) {
        data = FormData.fromJson(jsonDecode(dataJson));
      }

      if (stepName != null) {
        step = FormStep.values.firstWhere((s) => s.name == stepName);
      }

      return (data, step);
    } catch (e) {
      return (null, null);
    }
  }

  Future<void> clearFormData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_formDataKey);
    await prefs.remove(_currentStepKey);
  }
}

class FormSubmissionService {
  Future<bool> submitForm(FormData data) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock submission logic
    if (data.personal.email == 'error@example.com') {
      throw Exception('Submission failed: Invalid email');
    }
    
    return true;
  }
}
