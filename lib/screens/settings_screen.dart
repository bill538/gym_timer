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
  int? _currentGetReadyBeepStart = AppSettings.getReadyBeepStart;
  String _lastCastDeviceName = AppSettings.lastCastDeviceName;
  bool _autoConnectChromecast = AppSettings.autoConnectChromecast;

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
      
      int? beepStart = prefs.getInt('getReadyBeepStart');
      if (beepStart == -1) beepStart = null;
      _currentGetReadyBeepStart = beepStart;
      AppSettings.getReadyBeepStart = _currentGetReadyBeepStart;

      _lastCastDeviceName = prefs.getString('lastCastDeviceName') ?? AppSettings.lastCastDeviceName;
      AppSettings.lastCastDeviceName = _lastCastDeviceName;
      _autoConnectChromecast = prefs.getBool('autoConnectChromecast') ?? AppSettings.autoConnectChromecast;
      AppSettings.autoConnectChromecast = _autoConnectChromecast;
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

  _saveBeepSettings(int? newBeepStart) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('getReadyBeepStart', newBeepStart ?? -1);
    setState(() {
      AppSettings.getReadyBeepStart = newBeepStart;
      _currentGetReadyBeepStart = newBeepStart;
    });
  }

  _saveCastDeviceName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastCastDeviceName', newName);
    setState(() {
      AppSettings.lastCastDeviceName = newName;
      _lastCastDeviceName = newName;
    });
  }

  _saveAutoConnectChromecast(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoConnectChromecast', newValue);
    setState(() {
      AppSettings.autoConnectChromecast = newValue;
      _autoConnectChromecast = newValue;
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
            title: const Text('Get Ready\nTime (secs)', style: TextStyle(height: 1.2)),
            trailing: Text('$_currentGetReadyDuration', style: const TextStyle(fontSize: 18)),
            onTap: () => _showGetReadyDurationPicker(context),
          ),
          const Divider(),
          ListTile(
            title: const Text('Get Ready\nBeeps (sec)', style: TextStyle(height: 1.2)),
            trailing: Text(
              _currentGetReadyBeepStart == null ? ' ' : '$_currentGetReadyBeepStart',
              style: const TextStyle(fontSize: 18),
            ),
            onTap: () => _showGetReadyBeepPicker(context),
          ),
          const Divider(),
          ListTile(
            title: const Text('Last\nConnected\nChromecast', style: TextStyle(height: 1.2)),
            trailing: SizedBox(
              width: 150,
              child: Text(
                _lastCastDeviceName.isEmpty ? 'None' : _lastCastDeviceName,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Auto Connect\nChromecast', style: TextStyle(height: 1.2)),
            value: _autoConnectChromecast,
            onChanged: (bool value) {
              _saveAutoConnectChromecast(value);
            },
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
                maxValue: 60,
                onChanged: (value) => setState(() => _currentGetReadyDuration = value),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey),
                ),
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
      setState(() {});
    });
  }

  _showGetReadyBeepPicker(BuildContext context) {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int tempValue = _currentGetReadyBeepStart ?? 0;
        return AlertDialog(
          title: const Text('Select Beep Start Time'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('0 = Blank (Full Duration)'),
                  const SizedBox(height: 10),
                  NumberPicker(
                    value: tempValue,
                    minValue: 0,
                    maxValue: 60,
                    onChanged: (value) => setState(() => tempValue = value),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveBeepSettings(tempValue == 0 ? null : tempValue);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) {
      setState(() {});
    });
  }
}
