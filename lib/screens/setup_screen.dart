import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gym_timer/widgets/workout_card.dart';
import 'package:gym_timer/screens/tabata_setup_screen.dart';
import 'package:gym_timer/screens/emom_setup_screen.dart';
import 'package:gym_timer/screens/amrap_setup_screen.dart';
import 'package:gym_timer/screens/circuit_setup_screen.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_timer/services/cast_service.dart';
import 'package:gym_timer/screens/settings_screen.dart'; // Import the settings screen

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late String _timeString;

  Timer? _idleTimer;

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now());
    _idleTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    if (mounted) {
      setState(() {
        _timeString = formattedDateTime;
      });
    }
    
    // Proactively send the current time to Chromecast if connected
    if (GoogleCastSessionManager.instance.connectionState == GoogleCastConnectState.connected) {
      CastService.instance.updateIdle(time: formattedDateTime);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('hh:mm:ss').format(dateTime);
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://www.21-boom.com/');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showDevicePicker() {
    GoogleCastDiscoveryManager.instance.startDiscovery();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Connect to Chromecast'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: StreamBuilder<List<GoogleCastDevice>>(
              stream: GoogleCastDiscoveryManager.instance.devicesStream,
              builder: (context, snapshot) {
                final devices = snapshot.data ?? [];
                if (devices.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return ListTile(
                      title: Text(device.friendlyName),
                      subtitle: Text(device.modelName ?? ''),
                      leading: const Icon(Icons.cast),
                      onTap: () async {
                        try {
                          await GoogleCastSessionManager.instance.startSessionWithDevice(device);
                          // Save device ID for automatic reconnection
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('last_cast_device_id', device.deviceID);
                          await prefs.setString('last_cast_device_name', device.friendlyName);
                          
                          Navigator.pop(context);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(content: Text('Connected to ${device.friendlyName}')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(content: Text('Error connecting: $e')),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                GoogleCastDiscoveryManager.instance.stopDiscovery();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    ).then((_) => GoogleCastDiscoveryManager.instance.stopDiscovery());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('21BOOM', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF40324B),
        elevation: 0,
        actions: [
          StreamBuilder(
            stream: GoogleCastSessionManager.instance.currentSessionStream,
            builder: (context, snapshot) {
              final isConnected = GoogleCastSessionManager.instance.connectionState == GoogleCastConnectState.connected;
              return IconButton(
                onPressed: isConnected 
                  ? () => GoogleCastSessionManager.instance.endSessionAndStopCasting()
                  : _showDevicePicker,
                icon: Icon(isConnected ? Icons.cast_connected : Icons.cast),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 30), // Hamburger menu icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                WorkoutCard(
                  title: 'TABATA',
                  subtitle: '20s Work / 10s Rest',
                  icon: Icons.flash_on,
                  glowColor: Colors.blue.shade400,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TabataSetupScreen()),
                    );
                  },
                ),
                WorkoutCard(
                  title: 'EMOM',
                  subtitle: 'Every Minute on the Minute',
                  icon: Icons.fitness_center,
                  glowColor: Colors.yellow.shade400,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EmomSetupScreen()),
                    );
                  },
                ),
                WorkoutCard(
                  title: 'AMRAP',
                  subtitle: 'As Many Reps As Possible',
                  icon: Icons.timer,
                  glowColor: Colors.green.shade400,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AmrapSetupScreen()),
                    );
                  },
                ),
                WorkoutCard(
                  title: 'CIRCUIT',
                  subtitle: 'Variable Intervals',
                  icon: Icons.sync,
                  glowColor: Colors.orange.shade400,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CircuitSetupScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 10,
                          offset: const Offset(4, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.05),
                          blurRadius: 1,
                          offset: const Offset(-1, -1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          _timeString,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
