import 'package:flutter/material.dart';
import 'package:pfaiassistant/core/di/service_locator.dart';
import 'package:pfaiassistant/core/services/auth_service.dart';
import 'package:pfaiassistant/core/services/security_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _loginWithBiometrics() async {
    final success = await serviceLocator<AuthService>().authenticate();
    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication failed')),
      );
    }
  }

  Future<void> _loginWithPin() async {
    final result = await serviceLocator<SecurityService>().verifyPin(
      _pinController.text,
    );
    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message ?? 'Incorrect PIN')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            IconButton(
              icon: const Icon(Icons.fingerprint, size: 80, color: Colors.blue),
              onPressed: _loginWithBiometrics,
            ),
            const Text('Tap to use Fingerprint'),
            const SizedBox(height: 40),
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(hintText: 'Or enter PIN'),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _loginWithPin,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
