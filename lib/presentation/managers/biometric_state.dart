part of 'biometric_bloc.dart';

@immutable
sealed class BiometricState {}

class BiometricInitial extends BiometricState {}

// TODO: Add missing state classes.
/*
  The needed state are:
  - State to indicate authentication is in progress.
  - State to indicate authentication is success.
  - State to indicate authentication is fail.
*/

class BiometricAuthInProgress extends BiometricState {}

class BiometricAuthSuccess extends BiometricState {}

class BiometricAuthFail extends BiometricState {
  BiometricAuthFail({this.message});
  final String? message;
}

// class BiometricAuthError extends BiometricState {}
