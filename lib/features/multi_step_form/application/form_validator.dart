import 'package:flutter/material.dart';

import '../data/form_data.dart';

// ============================================================================
// VALIDATION SYSTEM
// ============================================================================

@immutable
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final Map<String, String> fieldErrors;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.fieldErrors = const {},
  });

  const ValidationResult.valid() : this(isValid: true);

  const ValidationResult.invalid({
    List<String>? errors,
    Map<String, String>? fieldErrors,
  }) : this(
          isValid: false,
          errors: errors ?? const [],
          fieldErrors: fieldErrors ?? const {},
        );
}

abstract class FormValidator<T> {
  ValidationResult validate(T data);
  Future<ValidationResult> validateAsync(T data) async => validate(data);
}

class PersonalDataValidator extends FormValidator<PersonalData> {
  @override
  ValidationResult validate(PersonalData data) {
    final fieldErrors = <String, String>{};

    if (data.firstName.isEmpty) {
      fieldErrors['firstName'] = 'First name is required';
    }
    if (data.lastName.isEmpty) {
      fieldErrors['lastName'] = 'Last name is required';
    }
    if (data.email.isEmpty) {
      fieldErrors['email'] = 'Email is required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(data.email)) {
      fieldErrors['email'] = 'Invalid email format';
    }
    if (data.phone.isEmpty) {
      fieldErrors['phone'] = 'Phone is required';
    }

    return fieldErrors.isEmpty
        ? const ValidationResult.valid()
        : ValidationResult.invalid(fieldErrors: fieldErrors);
  }

  @override
  Future<ValidationResult> validateAsync(PersonalData data) async {
    final basicValidation = validate(data);
    if (!basicValidation.isValid) return basicValidation;

    // Simulate async email validation
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock email uniqueness check
    if (data.email == 'taken@example.com') {
      return const ValidationResult.invalid(
        fieldErrors: {'email': 'Email already exists'},
      );
    }

    return const ValidationResult.valid();
  }
}

class AddressDataValidator extends FormValidator<AddressData> {
  @override
  ValidationResult validate(AddressData data) {
    final fieldErrors = <String, String>{};

    if (data.street.isEmpty) fieldErrors['street'] = 'Street is required';
    if (data.city.isEmpty) fieldErrors['city'] = 'City is required';
    if (data.zipCode.isEmpty) fieldErrors['zipCode'] = 'ZIP code is required';
    if (data.country.isEmpty) fieldErrors['country'] = 'Country is required';

    return fieldErrors.isEmpty
        ? const ValidationResult.valid()
        : ValidationResult.invalid(fieldErrors: fieldErrors);
  }
}

class PreferencesDataValidator extends FormValidator<PreferencesData> {
  @override
  ValidationResult validate(PreferencesData data) {
    final fieldErrors = <String, String>{};

    if (data.communicationMethod.isEmpty) {
      fieldErrors['communicationMethod'] = 'Communication method is required';
    }

    return fieldErrors.isEmpty
        ? const ValidationResult.valid()
        : ValidationResult.invalid(fieldErrors: fieldErrors);
  }
}
