import 'package:flutter/material.dart';
import 'package:pfaiassistant/core/di/service_locator.dart';
import 'package:pfaiassistant/core/services/security_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _pin = "";
  String _confirmPin = "";
  bool _isConfirming = false;

  void _onKeyTap(String val) {
    if (_pin.length < 4) {
      setState(() {
        _pin += val;
      });
    }

    if (_pin.length == 4) {
      if (!_isConfirming) {
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            _confirmPin = _pin;
            _pin = "";
            _isConfirming = true;
          });
        });
      } else {
        if (_pin == _confirmPin) {
          _saveAndFinish();
        } else {
          _showError();
        }
      }
    }
  }

  void _saveAndFinish() async {
    await serviceLocator<SecurityService>().savePin(_pin);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("PINS do not match. Try again")),
    );
    setState(() {
      _pin = "";
      _isConfirming = false;
    });
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Icon(Icons.lock_outline, size: 64, color: colorScheme.primary),
            const SizedBox(height: 20),
            Text(
              _isConfirming ? 'Confirm your PIN' : 'Create Secure PIN',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Enter a 4-digit PIN to secure your account"),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => _buildPinDot(index)),
            ),

            const Spacer(),

            _buildKeypad(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDot(int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFilled = _pin.length > index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? colorScheme.primary : Colors.grey[300],
        border: Border.all(color: colorScheme.primary, width: 2),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((val) => _buildKey(val)).toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80), // Empty space for layout
            _buildKey('0'),
            _buildKey('backspace', isIcon: true),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String val, {bool isIcon = false}) {
    return InkWell(
      onTap: () => isIcon ? _onDelete() : _onKeyTap(val),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 80,
        width: 80,
        alignment: Alignment.center,
        child: isIcon
            ? const Icon(Icons.backspace_outlined, size: 28)
            : Text(
                val,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
