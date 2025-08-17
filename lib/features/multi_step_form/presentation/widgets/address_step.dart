import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/form_providers.dart';
import '../../data/form_data.dart';

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
