import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PrefsService _prefs = PrefsService();
  
  String _currency = 'ETB';
  String _theme = 'light';

  @override
  void initState() {
    super.initState();
    _currency = _prefs.getCurrency();
    _theme = _prefs.getTheme();
  }

  void _updateCurrency(String? newValue) async {
    if (newValue != null) {
      await _prefs.setCurrency(newValue);
      setState(() => _currency = newValue);
    }
  }

  void _updateTheme(String? newValue) async {
    if (newValue != null) {
      await _prefs.setTheme(newValue);
      setState(() => _theme = newValue);
      // The requirement says "apply the chosen theme to the whole app on next launch."
      // So we don't necessarily need a complex state management solution for real-time theme changing,
      // but showing a snackbar to inform the user is good practice.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Theme change will be applied on next launch.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Currency'),
            subtitle: const Text('Choose your preferred currency symbol'),
            trailing: DropdownButton<String>(
              value: _currency,
              items: const [
                DropdownMenuItem(value: 'ETB', child: Text('ETB')),
                DropdownMenuItem(value: 'USD', child: Text('USD')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR')),
              ],
              onChanged: _updateCurrency,
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Theme'),
            subtitle: const Text('Choose app theme (applied on next launch)'),
            trailing: DropdownButton<String>(
              value: _theme,
              items: const [
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
              ],
              onChanged: _updateTheme,
            ),
          ),
        ],
      ),
    );
  }
}
