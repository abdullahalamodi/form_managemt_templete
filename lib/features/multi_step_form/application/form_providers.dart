import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/form_services.dart';
import 'form_notifier.dart';
import 'form_state.dart';
import 'form_validator.dart';

final formPersistenceServiceProvider =
    Provider((ref) => FormPersistenceService());
final formSubmissionServiceProvider =
    Provider((ref) => FormSubmissionService());

final personalValidatorProvider = Provider((ref) => PersonalDataValidator());
final addressValidatorProvider = Provider((ref) => AddressDataValidator());
final preferencesValidatorProvider =
    Provider((ref) => PreferencesDataValidator());

final formStateProvider =
    StateNotifierProvider<FormNotifier, FormStateModel>((ref) {
  return FormNotifier(
    persistenceService: ref.watch(formPersistenceServiceProvider),
    submissionService: ref.watch(formSubmissionServiceProvider),
    personalValidator: ref.watch(personalValidatorProvider),
    addressValidator: ref.watch(addressValidatorProvider),
    preferencesValidator: ref.watch(preferencesValidatorProvider),
  );
});
