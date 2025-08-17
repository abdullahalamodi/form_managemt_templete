import 'package:flutter/material.dart';

import '../data/form_data.dart';

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
