// TODO: Add AuthPage implementation.
/*
  The AuthPage should have:
  - A Text widget to display biometric auth status.
  - A Button widget to start authenticate.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:h8_fli_biometric_starter/presentation/managers/biometric_bloc.dart';

import 'nfc_reader_screen.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    context.read<BiometricBloc>().add(BiometricCheckAvailability());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocConsumer<BiometricBloc, BiometricState>(
          listener: (context, state) {
            if (state is BiometricAuthSuccess) {
              final username = usernameController.text.trim().toLowerCase();
              if (username == 'arlan') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const NfcReaderScreen()),
                );
              } else {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            }

            if (state is BiometricAuthFail) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message ?? 'Authentication failed'),
                ),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(switch (state) {
                    BiometricAuthInProgress() =>
                      'Authentication in progress...',
                    BiometricAuthSuccess() => 'Authentication success!',
                    BiometricAuthFail() => 'Authentication failed!',
                    _ => 'Please login',
                  }),
                  const SizedBox(height: 16),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.fingerprint),
                        onPressed: () {
                          context.read<BiometricBloc>().add(
                            BiometricAuthenticate(
                              passsword: passwordController.text,
                            ),
                          );
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      context.read<BiometricBloc>().add(
                        BiometricAuthenticate(passsword: value),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      context.read<BiometricBloc>().add(
                        BiometricAuthenticate(),
                      );
                    },
                    child: const Text('Login with Biometric'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
