import 'package:flutter/material.dart';

// ============================================================================
// MODELS & DATA STRUCTURES
// ============================================================================

enum FormStep { personal, address, preferences }

@immutable
class FormData {
  final PersonalData personal;
  final AddressData address;
  final PreferencesData preferences;

  const FormData({
    required this.personal,
    required this.address,
    required this.preferences,
  });

  FormData copyWith({
    PersonalData? personal,
    AddressData? address,
    PreferencesData? preferences,
  }) {
    return FormData(
      personal: personal ?? this.personal,
      address: address ?? this.address,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toJson() => {
        'personal': personal.toJson(),
        'address': address.toJson(),
        'preferences': preferences.toJson(),
      };

  factory FormData.fromJson(Map<String, dynamic> json) => FormData(
        personal: PersonalData.fromJson(json['personal'] ?? {}),
        address: AddressData.fromJson(json['address'] ?? {}),
        preferences: PreferencesData.fromJson(json['preferences'] ?? {}),
      );

  factory FormData.empty() => const FormData(
        personal: PersonalData.empty(),
        address: AddressData.empty(),
        preferences: PreferencesData.empty(),
      );
}

@immutable
class PersonalData {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const PersonalData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  const PersonalData.empty()
      : firstName = '',
        lastName = '',
        email = '',
        phone = '';

  PersonalData copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) =>
      PersonalData(
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
      );

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
      };

  factory PersonalData.fromJson(Map<String, dynamic> json) => PersonalData(
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
      );

  bool get isValid =>
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      email.isNotEmpty &&
      phone.isNotEmpty;
}

@immutable
class AddressData {
  final String street;
  final String city;
  final String zipCode;
  final String country;

  const AddressData({
    required this.street,
    required this.city,
    required this.zipCode,
    required this.country,
  });

  const AddressData.empty()
      : street = '',
        city = '',
        zipCode = '',
        country = '';

  AddressData copyWith({
    String? street,
    String? city,
    String? zipCode,
    String? country,
  }) =>
      AddressData(
        street: street ?? this.street,
        city: city ?? this.city,
        zipCode: zipCode ?? this.zipCode,
        country: country ?? this.country,
      );

  Map<String, dynamic> toJson() => {
        'street': street,
        'city': city,
        'zipCode': zipCode,
        'country': country,
      };

  factory AddressData.fromJson(Map<String, dynamic> json) => AddressData(
        street: json['street'] ?? '',
        city: json['city'] ?? '',
        zipCode: json['zipCode'] ?? '',
        country: json['country'] ?? '',
      );

  bool get isValid =>
      street.isNotEmpty &&
      city.isNotEmpty &&
      zipCode.isNotEmpty &&
      country.isNotEmpty;
}

@immutable
class PreferencesData {
  final bool newsletter;
  final String communicationMethod;
  final List<String> interests;

  const PreferencesData({
    required this.newsletter,
    required this.communicationMethod,
    required this.interests,
  });

  const PreferencesData.empty()
      : newsletter = false,
        communicationMethod = '',
        interests = const [];

  PreferencesData copyWith({
    bool? newsletter,
    String? communicationMethod,
    List<String>? interests,
  }) =>
      PreferencesData(
        newsletter: newsletter ?? this.newsletter,
        communicationMethod: communicationMethod ?? this.communicationMethod,
        interests: interests ?? this.interests,
      );

  Map<String, dynamic> toJson() => {
        'newsletter': newsletter,
        'communicationMethod': communicationMethod,
        'interests': interests,
      };

  factory PreferencesData.fromJson(Map<String, dynamic> json) =>
      PreferencesData(
        newsletter: json['newsletter'] ?? false,
        communicationMethod: json['communicationMethod'] ?? '',
        interests: List<String>.from(json['interests'] ?? []),
      );

  bool get isValid => communicationMethod.isNotEmpty;
}
