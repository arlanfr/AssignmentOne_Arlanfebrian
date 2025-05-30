import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricDataSource {
  final LocalAuthentication localAuth;
  BiometricDataSource({required this.localAuth});

  // TODO: 1. Complete the checkAvailability() method implementation.
  Future<bool> checkAvailability() async {
    try {
      final isAvailable = await localAuth.canCheckBiometrics;
      final isSupported = await localAuth.isDeviceSupported();
      return isAvailable && isSupported;
    } catch (e) {
      log('Biometric error : $e', name: 'checkAvailability');
      return false;
    }
  }

  // TODO: 2. Complete the authenticate() method implementation.
  Future<bool> authenticate() async {
    try {
      return localAuth.authenticate(
        localizedReason: 'Authenticate to open',
        options: AuthenticationOptions(
          stickyAuth: true,
          useErrorDialogs: false,
          sensitiveTransaction: false,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      log('Biometric error : $e', name: 'authenticate');
      return false;
    }
  }
}
