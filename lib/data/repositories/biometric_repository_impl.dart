// TODO: 1. Create the abstract class BiometricRepository.
// TODO: 2. Add the checkAvailability() method definition.
// TODO: 3. Add the authenticate() method definition.

import 'package:h8_fli_biometric_starter/data/datasources/biometric_data_source.dart';
import 'package:h8_fli_biometric_starter/data/datasources/remote_data_source.dart';
import 'package:h8_fli_biometric_starter/domain/repositories/biometric_repository.dart';
import 'package:h8_fli_biometric_starter/shared/local_storage.dart';

class BiometricRepositoryImpl implements BiometricRepository {
  final BiometricDataSource dataSource;
  final RemoteDataSource remoteDataSource;

  BiometricRepositoryImpl({
    required this.dataSource,
    required this.remoteDataSource,
  });

  @override
  Future<bool> authenticate({String? password}) async {
    final localStorage = LocalStorage();
    final userPassword = await localStorage.getUserPassword();

    try {
      if (password != null && password.isNotEmpty) {
        final isAuthenticated = await remoteDataSource.checkAuthStatus(
          userPasssword: password,
        );

        if (!isAuthenticated) throw Exception('Incorect Password');
        if (userPassword != null) await localStorage.setUserPassword(password);
      } else if (userPassword != null && userPassword.isNotEmpty) {
        if (await dataSource.authenticate()) ;
        {
          return remoteDataSource.checkAuthStatus(userPasssword: userPassword);
        }
        throw Exception('Biometric auth error');
      } else {
        throw Exception('Use Password to Continue');
      }
    } catch (e) {}

    return dataSource.authenticate();
  }

  @override
  Future<bool> checkAvailability() {
    return dataSource.checkAvailability();
  }
}
