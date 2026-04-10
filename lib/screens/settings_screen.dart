import 'package:flutter/material.dart';
import 'package:gym_timer/settings.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentGetReadyDuration = AppSettings.getReadyDuration;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentGetReadyDuration = prefs.getInt('getReadyDuration') ?? AppSettings.getReadyDuration;
      AppSettings.getReadyDuration = _currentGetReadyDuration;
    });
  }

  _saveSettings(int newDuration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('getReadyDuration', newDuration);
    setState(() {
      AppSettings.getReadyDuration = newDuration;
      _currentGetReadyDuration = newDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Get Ready Time (seconds)'),
            trailing: Text('$_currentGetReadyDuration'),
            onTap: () => _showGetReadyDurationPicker(context),
          ),
        ],
      ),
    );
  }

  _showGetReadyDurationPicker(BuildContext context) {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Get Ready Duration'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return NumberPicker(
                value: _currentGetReadyDuration,
                minValue: 0,
                maxValue: 60, // Arbitrary upper limit, can be adjusted
                onChanged: (value) => setState(() => _currentGetReadyDuration = value),
              );
            },
          ),
          actions: [ 
            TextButton(
              onPressed: () { Navigator.of(context).pop(); },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveSettings(_currentGetReadyDuration);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) {
      // After dialog closes, ensure UI is updated if settings changed
      setState(() {});
    });
  }
}
