import 'package:flutter/material.dart';
import 'package:pfaiassistant/core/services/security_service.dart';
import '../../../../core/di/service_locator.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // 1. Wait for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    final bool registered = await serviceLocator<SecurityService>().isRegistered();

    if (mounted) {
      if (registered) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(context, '/register');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1E3C72),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance, size: 80, color: Theme.of(context).colorScheme.surface),
            SizedBox(height: 20),
            Text("PFAIAssistent", 
               style: TextStyle(color: Theme.of(context).colorScheme.surface, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
      ),
     ),
    );
  }
}