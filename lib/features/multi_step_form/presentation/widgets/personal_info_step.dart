import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_managemt_templete/features/multi_step_form/application/form_providers.dart';
import 'package:form_managemt_templete/features/multi_step_form/data/form_data.dart';

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
