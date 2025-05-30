// TODO: 1. Add usecase classes for each repository's functionality.

import 'package:h8_fli_biometric_starter/domain/repositories/biometric_repository.dart';

class BiometricCheckAvailabilityUseCase {
  final BiometricRepository repository;
  BiometricCheckAvailabilityUseCase({required this.repository});

  Future<bool> execute() {
    return repository.checkAvailability();
  }
}

class BiometricAuthenticateUseCase {
  final BiometricRepository repository;
  BiometricAuthenticateUseCase({required this.repository});

  Future<bool> execute({required password}) {
    return repository.authenticate();
  }
}
