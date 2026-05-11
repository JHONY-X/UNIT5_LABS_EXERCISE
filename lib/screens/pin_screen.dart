import 'package:flutter/material.dart';
import '../services/pin_vault.dart';
import '../services/expenses_db.dart';
import 'expenses_screen.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final PinVault _pinVault = PinVault();
  final ExpensesDb _expensesDb = ExpensesDb();
  final TextEditingController _pinController = TextEditingController();
  
  bool _isLoading = true;
  bool _hasPin = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final hasPin = await _pinVault.hasPin();
    setState(() {
      _hasPin = hasPin;
      _isLoading = false;
    });
  }

  void _submitPin() async {
    final pin = _pinController.text;
    if (pin.length != 4) {
      setState(() => _errorMessage = 'PIN must be 4 digits.');
      return;
    }

    if (_hasPin) {
      final isValid = await _pinVault.verifyPin(pin);
      if (isValid) {
        _navigateToExpenses();
      } else {
        setState(() => _errorMessage = 'Incorrect PIN.');
        _pinController.clear();
      }
    } else {
      await _pinVault.setPin(pin);
      _navigateToExpenses();
    }
  }

  void _resetApp() async {
    await _pinVault.deletePin();
    await _expensesDb.wipeAll();
    _pinController.clear();
    setState(() {
      _errorMessage = 'App reset successful.';
      _hasPin = false;
    });
  }

  void _navigateToExpenses() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ExpensesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('MyMoney')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _hasPin ? 'Enter your 4-digit PIN' : 'Set a 4-digit PIN',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '****',
              ),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitPin,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: Text(_hasPin ? 'Unlock' : 'Save PIN'),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _resetApp,
              child: const Text('Reset PIN & Erase Data', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
