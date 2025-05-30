// TODO: Add HomePage implementation.
/*
  The HomePage should have Text widget that state "Authentication Successful!",
  the user will navigate to this page when biometric authentication success.
*/
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Biomatric auth')),
      body: Center(child: Text('authentication successful!')),
    );
  }
}
