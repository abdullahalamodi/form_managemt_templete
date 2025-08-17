import 'package:flutter/material.dart';

import '../application/step_registry.dart';
import '../data/form_data.dart';
import 'form_validator.dart';

@immutable
class FormStateModel {
  final FormStep currentStep;
  final FormData data;
  final Map<FormStep, ValidationResult> validationResults;
  final Set<FormStep> completedSteps;
  final bool isSubmitting;
  final String? submitError;
  final bool isAutoSaving;

  const FormStateModel({
    required this.currentStep,
    required this.data,
    this.validationResults = const {},
    this.completedSteps = const {},
    this.isSubmitting = false,
    this.submitError,
    this.isAutoSaving = false,
  });

  FormStateModel copyWith({
    FormStep? currentStep,
    FormData? data,
    Map<FormStep, ValidationResult>? validationResults,
    Set<FormStep>? completedSteps,
    bool? isSubmitting,
    String? submitError,
    bool? isAutoSaving,
  }) =>
      FormStateModel(
        currentStep: currentStep ?? this.currentStep,
        data: data ?? this.data,
        validationResults: validationResults ?? this.validationResults,
        completedSteps: completedSteps ?? this.completedSteps,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        submitError: submitError ?? this.submitError,
        isAutoSaving: isAutoSaving ?? this.isAutoSaving,
      );

  bool isStepValid(FormStep step) => validationResults[step]?.isValid ?? false;

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
