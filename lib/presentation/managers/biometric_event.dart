part of 'biometric_bloc.dart';

@immutable
abstract class BiometricEvent {}

// TODO: Add missing event classes.
class BiometricCheckAvailability extends BiometricEvent {}

// class BiometricAuthenticate extends BiometricEvent {}

class BiometricAuthenticate extends BiometricEvent {
  BiometricAuthenticate({this.passsword});
  final String? passsword;
}
