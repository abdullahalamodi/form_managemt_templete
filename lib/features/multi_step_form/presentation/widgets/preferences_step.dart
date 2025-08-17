import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/form_providers.dart';
import '../../data/form_data.dart';

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
