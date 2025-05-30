// TODO: 1. Create the implementation class of BiometricRepository.
// TODO: 2. Add BiometricDataSource as the dependency.
// TODO: 3. Complete each method implementation.

abstract class BiometricRepository {
  Future<bool> checkAvailability();
  Future<bool> authenticate({String? password});
}
