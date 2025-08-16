// pubspec.yaml dependencies:
// flutter_riverpod: ^2.4.0
// shared_preferences: ^2.2.0

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final errors = <String>[];
    final fieldErrors = <String, String>{};

    if (data.firstName.isEmpty) {
      fieldErrors['firstName'] = 'First name is required';
    }
    if (data.lastName.isEmpty) {
      fieldErrors['lastName'] = 'Last name is required';
    }
    if (data.email.isEmpty) {
      fieldErrors['email'] = 'Email is required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(data.email)) {
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

// ============================================================================
// STEP CONFIGURATION & REGISTRY
// ============================================================================

@immutable
class StepConfig {
  final FormStep step;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool requiresValidation;
  final List<FormStep> dependencies;

  const StepConfig({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.requiresValidation = true,
    this.dependencies = const [],
  });
}

class StepRegistry {
  static const Map<FormStep, StepConfig> _steps = {
    FormStep.personal: StepConfig(
      step: FormStep.personal,
      title: 'Personal Information',
      subtitle: 'Tell us about yourself',
      icon: Icons.person,
    ),
    FormStep.address: StepConfig(
      step: FormStep.address,
      title: 'Address',
      subtitle: 'Where can we reach you?',
      icon: Icons.home,
      dependencies: [FormStep.personal],
    ),
    FormStep.preferences: StepConfig(
      step: FormStep.preferences,
      title: 'Preferences',
      subtitle: 'Customize your experience',
      icon: Icons.settings,
      dependencies: [FormStep.personal, FormStep.address],
    ),
  };

  static StepConfig getConfig(FormStep step) => _steps[step]!;
  static List<StepConfig> getAllSteps() => FormStep.values.map(getConfig).toList();
  static int getStepIndex(FormStep step) => FormStep.values.indexOf(step);
  static FormStep? getNextStep(FormStep current) {
    final currentIndex = getStepIndex(current);
    return currentIndex < FormStep.values.length - 1
        ? FormStep.values[currentIndex + 1]
        : null;
  }
  static FormStep? getPreviousStep(FormStep current) {
    final currentIndex = getStepIndex(current);
    return currentIndex > 0 ? FormStep.values[currentIndex - 1] : null;
  }
}

// ============================================================================
// FORM STATE MANAGEMENT
// ============================================================================

@immutable
class FormState {
  final FormStep currentStep;
  final FormData data;
  final Map<FormStep, ValidationResult> validationResults;
  final Set<FormStep> completedSteps;
  final bool isSubmitting;
  final String? submitError;
  final bool isAutoSaving;

  const FormState({
    required this.currentStep,
    required this.data,
    this.validationResults = const {},
    this.completedSteps = const {},
    this.isSubmitting = false,
    this.submitError,
    this.isAutoSaving = false,
  });

  FormState copyWith({
    FormStep? currentStep,
    FormData? data,
    Map<FormStep, ValidationResult>? validationResults,
    Set<FormStep>? completedSteps,
    bool? isSubmitting,
    String? submitError,
    bool? isAutoSaving,
  }) =>
      FormState(
        currentStep: currentStep ?? this.currentStep,
        data: data ?? this.data,
        validationResults: validationResults ?? this.validationResults,
        completedSteps: completedSteps ?? this.completedSteps,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        submitError: submitError ?? this.submitError,
        isAutoSaving: isAutoSaving ?? this.isAutoSaving,
      );

  bool isStepValid(FormStep step) =>
      validationResults[step]?.isValid ?? false;

  bool canNavigateToStep(FormStep targetStep) {
    final config = StepRegistry.getConfig(targetStep);
    return config.dependencies.every((dep) => completedSteps.contains(dep));
  }

  double get progress {
    final totalSteps = FormStep.values.length;
    final currentIndex = StepRegistry.getStepIndex(currentStep);
    return (currentIndex + 1) / totalSteps;
  }
}

// ============================================================================
// SERVICES
// ============================================================================

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

// ============================================================================
// PROVIDERS
// ============================================================================

final formPersistenceServiceProvider = Provider((ref) => FormPersistenceService());
final formSubmissionServiceProvider = Provider((ref) => FormSubmissionService());

final personalValidatorProvider = Provider((ref) => PersonalDataValidator());
final addressValidatorProvider = Provider((ref) => AddressDataValidator());
final preferencesValidatorProvider = Provider((ref) => PreferencesDataValidator());

final formStateProvider = StateNotifierProvider<FormNotifier, FormState>((ref) {
  return FormNotifier(
    persistenceService: ref.watch(formPersistenceServiceProvider),
    submissionService: ref.watch(formSubmissionServiceProvider),
    personalValidator: ref.watch(personalValidatorProvider),
    addressValidator: ref.watch(addressValidatorProvider),
    preferencesValidator: ref.watch(preferencesValidatorProvider),
  );
});

// ============================================================================
// FORM NOTIFIER (Main Controller)
// ============================================================================

class FormNotifier extends StateNotifier<FormState> {
  final FormPersistenceService persistenceService;
  final FormSubmissionService submissionService;
  final PersonalDataValidator personalValidator;
  final AddressDataValidator addressValidator;
  final PreferencesDataValidator preferencesValidator;

  Timer? _autoSaveTimer;

  FormNotifier({
    required this.persistenceService,
    required this.submissionService,
    required this.personalValidator,
    required this.addressValidator,
    required this.preferencesValidator,
  }) : super(FormState(
          currentStep: FormStep.personal,
          data: FormData.empty(),
        )) {
    _loadSavedData();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final (data, step) = await persistenceService.loadFormData();
    if (data != null) {
      state = state.copyWith(
        data: data,
        currentStep: step ?? FormStep.personal,
      );
      await _validateCurrentStep();
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () async {
      state = state.copyWith(isAutoSaving: true);
      await persistenceService.saveFormData(state.data, state.currentStep);
      if (mounted) {
        state = state.copyWith(isAutoSaving: false);
      }
    });
  }

  // Data Updates
  void updatePersonalData(PersonalData personal) {
    state = state.copyWith(data: state.data.copyWith(personal: personal));
    _scheduleAutoSave();
    _validateStep(FormStep.personal);
  }

  void updateAddressData(AddressData address) {
    state = state.copyWith(data: state.data.copyWith(address: address));
    _scheduleAutoSave();
    _validateStep(FormStep.address);
  }

  void updatePreferencesData(PreferencesData preferences) {
    state = state.copyWith(data: state.data.copyWith(preferences: preferences));
    _scheduleAutoSave();
    _validateStep(FormStep.preferences);
  }

  // Navigation
  Future<bool> goToNextStep() async {
    final isValid = await _validateCurrentStep();
    if (!isValid) return false;

    final nextStep = StepRegistry.getNextStep(state.currentStep);
    if (nextStep != null) {
      final newCompletedSteps = Set<FormStep>.from(state.completedSteps)
        ..add(state.currentStep);
      
      state = state.copyWith(
        currentStep: nextStep,
        completedSteps: newCompletedSteps,
      );
      return true;
    }
    return false;
  }

  void goToPreviousStep() {
    final previousStep = StepRegistry.getPreviousStep(state.currentStep);
    if (previousStep != null) {
      state = state.copyWith(currentStep: previousStep);
    }
  }

  void goToStep(FormStep step) {
    if (state.canNavigateToStep(step)) {
      state = state.copyWith(currentStep: step);
    }
  }

  // Validation
  Future<bool> _validateCurrentStep() async {
    return await _validateStep(state.currentStep);
  }

  Future<bool> _validateStep(FormStep step) async {
    ValidationResult result;
    
    switch (step) {
      case FormStep.personal:
        result = await personalValidator.validateAsync(state.data.personal);
        break;
      case FormStep.address:
        result = addressValidator.validate(state.data.address);
        break;
      case FormStep.preferences:
        result = preferencesValidator.validate(state.data.preferences);
        break;
    }

    final newResults = Map<FormStep, ValidationResult>.from(state.validationResults);
    newResults[step] = result;

    state = state.copyWith(validationResults: newResults);
    return result.isValid;
  }

  // Submission
  Future<void> submitForm() async {
    state = state.copyWith(isSubmitting: true, submitError: null);

    try {
      // Validate all steps
      final allValid = await Future.wait([
        _validateStep(FormStep.personal),
        _validateStep(FormStep.address),
        _validateStep(FormStep.preferences),
      ]).then((results) => results.every((r) => r));

      if (!allValid) {
        state = state.copyWith(
          isSubmitting: false,
          submitError: 'Please fix validation errors',
        );
        return;
      }

      await submissionService.submitForm(state.data);
      await persistenceService.clearFormData();
      
      // Success handled by UI
      state = state.copyWith(isSubmitting: false);
      
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(submitError: null);
  }
}

// ============================================================================
// STEP WIDGETS
// ============================================================================

class PersonalInfoStep extends ConsumerStatefulWidget {
  const PersonalInfoStep({super.key});

  @override
  ConsumerState<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends ConsumerState<PersonalInfoStep> {
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    final personal = ref.read(formStateProvider).data.personal;
    firstNameController = TextEditingController(text: personal.firstName);
    lastNameController = TextEditingController(text: personal.lastName);
    emailController = TextEditingController(text: personal.email);
    phoneController = TextEditingController(text: personal.phone);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _updateData() {
    final notifier = ref.read(formStateProvider.notifier);
    notifier.updatePersonalData(PersonalData(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      phone: phoneController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(formStateProvider);
    final validation = formState.validationResults[FormStep.personal];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: firstNameController,
            decoration: InputDecoration(
              labelText: 'First Name *',
              errorText: validation?.fieldErrors['firstName'],
            ),
            onChanged: (_) => _updateData(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: lastNameController,
            decoration: InputDecoration(
              labelText: 'Last Name *',
              errorText: validation?.fieldErrors['lastName'],
            ),
            onChanged: (_) => _updateData(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email *',
              errorText: validation?.fieldErrors['email'],
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => _updateData(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: 'Phone *',
              errorText: validation?.fieldErrors['phone'],
            ),
            keyboardType: TextInputType.phone,
            onChanged: (_) => _updateData(),
          ),
        ],
      ),
    );
  }
}

class AddressStep extends ConsumerStatefulWidget {
  const AddressStep({super.key});

  @override
  ConsumerState<AddressStep> createState() => _AddressStepState();
}

class _AddressStepState extends ConsumerState<AddressStep> {
  late final TextEditingController streetController;
  late final TextEditingController cityController;
  late final TextEditingController zipController;
  late final TextEditingController countryController;

  @override
  void initState() {
    super.initState();
    final address = ref.read(formStateProvider).data.address;
    streetController = TextEditingController(text: address.street);
    cityController = TextEditingController(text: address.city);
    zipController = TextEditingController(text: address.zipCode);
    countryController = TextEditingController(text: address.country);
  }

  @override
  void dispose() {
    streetController.dispose();
    cityController.dispose();
    zipController.dispose();
    countryController.dispose();
    super.dispose();
  }

  void _updateData() {
    final notifier = ref.read(formStateProvider.notifier);
    notifier.updateAddressData(AddressData(
      street: streetController.text,
      city: cityController.text,
      zipCode: zipController.text,
      country: countryController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(formStateProvider);
    final validation = formState.validationResults[FormStep.address];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: streetController,
            decoration: InputDecoration(
              labelText: 'Street Address *',
              errorText: validation?.fieldErrors['street'],
            ),
            onChanged: (_) => _updateData(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: cityController,
            decoration: InputDecoration(
              labelText: 'City *',
              errorText: validation?.fieldErrors['city'],
            ),
            onChanged: (_) => _updateData(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: zipController,
            decoration: InputDecoration(
              labelText: 'ZIP Code *',
              errorText: validation?.fieldErrors['zipCode'],
            ),
            onChanged: (_) => _updateData(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: countryController,
            decoration: InputDecoration(
              labelText: 'Country *',
              errorText: validation?.fieldErrors['country'],
            ),
            onChanged: (_) => _updateData(),
          ),
        ],
      ),
    );
  }
}

class PreferencesStep extends ConsumerWidget {
  const PreferencesStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(formStateProvider);
    final notifier = ref.watch(formStateProvider.notifier);
    final preferences = formState.data.preferences;
    final validation = formState.validationResults[FormStep.preferences];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            title: const Text('Subscribe to Newsletter'),
            value: preferences.newsletter,
            onChanged: (value) {
              notifier.updatePreferencesData(
                preferences.copyWith(newsletter: value),
              );
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: preferences.communicationMethod.isEmpty
                ? null
                : preferences.communicationMethod,
            decoration: InputDecoration(
              labelText: 'Preferred Communication *',
              errorText: validation?.fieldErrors['communicationMethod'],
            ),
            items: const [
              DropdownMenuItem(value: 'email', child: Text('Email')),
              DropdownMenuItem(value: 'sms', child: Text('SMS')),
              DropdownMenuItem(value: 'phone', child: Text('Phone')),
            ],
            onChanged: (value) {
              if (value != null) {
                notifier.updatePreferencesData(
                  preferences.copyWith(communicationMethod: value),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          const Text('Interests:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Technology', 'Sports', 'Travel', 'Food', 'Music']
                .map((interest) => FilterChip(
                      label: Text(interest),
                      selected: preferences.interests.contains(interest),
                      onSelected: (selected) {
                        final newInterests = List<String>.from(preferences.interests);
                        if (selected) {
                          newInterests.add(interest);
                        } else {
                          newInterests.remove(interest);
                        }
                        notifier.updatePreferencesData(
                          preferences.copyWith(interests: newInterests),
                        );
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MAIN FORM WIDGET
// ============================================================================

class MultiStepForm extends ConsumerWidget {
  const MultiStepForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(formStateProvider);
    final notifier = ref.watch(formStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Step Form'),
        actions: [
          if (formState.isAutoSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          LinearProgressIndicator(value: formState.progress),
          
          // Step Indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: FormStep.values.map((step) {
                final config = StepRegistry.getConfig(step);
                final isActive = step == formState.currentStep;
                final isCompleted = formState.completedSteps.contains(step);
                final canNavigate = formState.canNavigateToStep(step);

                return Expanded(
                  child: GestureDetector(
                    onTap: canNavigate ? () => notifier.goToStep(step) : null,
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: isActive
                              ? Theme.of(context).primaryColor
                              : isCompleted
                                  ? Colors.green
                                  : Colors.grey,
                          child: Icon(
                            isCompleted ? Icons.check : config.icon,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          config.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            color: canNavigate ? null : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Current Step Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Step Title and Subtitle
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StepRegistry.getConfig(formState.currentStep).title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          StepRegistry.getConfig(formState.currentStep).subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Step Content
                  _buildStepContent(formState.currentStep),

                  // Error Display
                  if (formState.submitError != null)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              formState.submitError!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: notifier.clearError,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Previous Button
                if (StepRegistry.getPreviousStep(formState.currentStep) != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: formState.isSubmitting ? null : notifier.goToPreviousStep,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                  ),

                if (StepRegistry.getPreviousStep(formState.currentStep) != null)
                  const SizedBox(width: 16),

                // Next/Submit Button
                Expanded(
                  flex: 2,
                  child: _buildActionButton(context, formState, notifier),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(FormStep step) {
    switch (step) {
      case FormStep.personal:
        return const PersonalInfoStep();
      case FormStep.address:
        return const AddressStep();
      case FormStep.preferences:
        return const PreferencesStep();
    }
  }

  Widget _buildActionButton(BuildContext context, FormState formState, FormNotifier notifier) {
    final isLastStep = StepRegistry.getNextStep(formState.currentStep) == null;
    
    if (isLastStep) {
      // Submit Button
      return ElevatedButton.icon(
        onPressed: formState.isSubmitting ? null : () async {
          await notifier.submitForm();
          if (context.mounted && formState.submitError == null && !formState.isSubmitting) {
            _showSuccessDialog(context);
          }
        },
        icon: formState.isSubmitting 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.check),
        label: Text(formState.isSubmitting ? 'Submitting...' : 'Submit'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      );
    } else {
      // Next Button
      return ElevatedButton.icon(
        onPressed: formState.isSubmitting ? null : () => notifier.goToNextStep(),
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Next'),
      );
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Success!'),
          ],
        ),
        content: const Text('Your form has been submitted successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Close the form
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PREVIEW WIDGET (Bonus Feature)
// ============================================================================

class FormPreviewSheet extends ConsumerWidget {
  const FormPreviewSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(formStateProvider).data;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.preview),
                  const SizedBox(width: 8),
                  const Text(
                    'Form Preview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildPreviewSection('Personal Information', [
                    'Name: ${formData.personal.firstName} ${formData.personal.lastName}',
                    'Email: ${formData.personal.email}',
                    'Phone: ${formData.personal.phone}',
                  ]),
                  
                  _buildPreviewSection('Address', [
                    'Street: ${formData.address.street}',
                    'City: ${formData.address.city}',
                    'ZIP: ${formData.address.zipCode}',
                    'Country: ${formData.address.country}',
                  ]),
                  
                  _buildPreviewSection('Preferences', [
                    'Newsletter: ${formData.preferences.newsletter ? "Yes" : "No"}',
                    'Communication: ${formData.preferences.communicationMethod}',
                    'Interests: ${formData.preferences.interests.join(", ")}',
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(item),
            )),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MAIN APP
// ============================================================================



class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Step Form Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.description,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Multi-Step Form Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'A comprehensive multi-step form with validation,\nauto-save, and state management.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MultiStepForm()),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Start Form'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const FormPreviewSheet(),
                );
              },
              icon: const Icon(Icons.preview),
              label: const Text('Preview Data'),
            ),
          ],
        ),
      ),
    );
  }
}