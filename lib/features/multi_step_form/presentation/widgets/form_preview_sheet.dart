import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/form_providers.dart';

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
