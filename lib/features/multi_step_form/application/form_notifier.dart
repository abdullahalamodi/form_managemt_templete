import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/form_data.dart';
import '../data/form_services.dart';
import 'form_state.dart';
import 'form_validator.dart';
import 'step_registry.dart';

class FormNotifier extends StateNotifier<FormStateModel> {
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
  }) : super(FormStateModel(
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
      final currentStep = step ?? FormStep.personal;
      final completedSteps =
          FormStep.values.where((s) => s.index < currentStep.index).toSet();

      state = state.copyWith(
        data: data,
        currentStep: currentStep,
        completedSteps: completedSteps,
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

    final newResults =
        Map<FormStep, ValidationResult>.from(state.validationResults);
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
    state = state.copyWith(clearSubmitError: true);
  }
}
