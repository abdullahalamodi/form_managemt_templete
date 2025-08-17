import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_managemt_templete/features/multi_step_form/application/form_notifier.dart';
import 'package:form_managemt_templete/features/multi_step_form/application/form_providers.dart';
import 'package:form_managemt_templete/features/multi_step_form/application/form_state.dart';
import 'package:form_managemt_templete/features/multi_step_form/application/step_registry.dart';
import 'package:form_managemt_templete/features/multi_step_form/data/form_data.dart';

import 'widgets/address_step.dart';
import 'widgets/personal_info_step.dart';
import 'widgets/preferences_step.dart';

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
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
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
                          StepRegistry.getConfig(formState.currentStep)
                              .subtitle,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                      onPressed: formState.isSubmitting
                          ? null
                          : notifier.goToPreviousStep,
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

  Widget _buildActionButton(
      BuildContext context, FormStateModel formState, FormNotifier notifier) {
    final isLastStep = StepRegistry.getNextStep(formState.currentStep) == null;
    final isCurrentStepValid = formState.isStepValid(formState.currentStep);

    if (isLastStep) {
      // Submit Button
      return ElevatedButton.icon(
        onPressed: formState.isSubmitting || !isCurrentStepValid
            ? null
            : () async {
                await notifier.submitForm();
                if (context.mounted &&
                    formState.submitError == null &&
                    !formState.isSubmitting) {
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
        onPressed:
            formState.isSubmitting ? null : () => notifier.goToNextStep(),
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
