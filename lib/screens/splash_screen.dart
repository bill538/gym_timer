import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gym_timer/screens/setup_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Move initialization to microtask to avoid blocking startup
    Future.delayed(Duration.zero, () => _initCast());
    
    // Use a flag to prevent navigation if we are launching a URL
    _startTimer();
  }

  bool _isLaunching = false;

  void _startTimer() {
    Timer(
      const Duration(seconds: 4), // Increased to 4s to give more time to tap
      () {
        if (mounted && !_isLaunching) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => const SetupScreen()),
          );
        }
      },
    );
  }

  Future<void> _initCast() async {
    try {
      const appId = GoogleCastDiscoveryCriteria.kDefaultApplicationId;
      GoogleCastOptions? options;

      if (Platform.isIOS) {
        options = IOSGoogleCastOptions(
          GoogleCastDiscoveryCriteriaInitialize.initWithApplicationID(appId),
          stopCastingOnAppTerminated: false,
        );
      } else {
        options = GoogleCastOptionsAndroid(
          appId: appId,
          stopCastingOnAppTerminated: false,
        );
      }

      await GoogleCastContext.instance.setSharedInstanceWithOptions(options);
      
      // Look for remembered device
      final prefs = await SharedPreferences.getInstance();
      final lastDeviceId = prefs.getString('last_cast_device_id');
      final lastDeviceName = prefs.getString('last_cast_device_name');
      
      if (lastDeviceId != null && lastDeviceName != null) {
      debugPrint('Remembered Cast device: $lastDeviceName ($lastDeviceId)');
        // The Google Cast SDK usually handles reconnection automatically
        // if the device is found during initial discovery.
      }
    } catch (e) {
      // Ignore
    }
  }

  void _launchURL() async {
    if (_isLaunching) return;
    
    final Uri url = Uri.parse('https://www.21-boom.com/');
    debugPrint('Splash: Attempting to launch $url');
    
    setState(() {
      _isLaunching = true;
    });

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint('Splash: Could not launch $url');
      }
    } catch (e) {
      debugPrint('Splash: Error launching URL: $e');
    } finally {
      // Allow navigation to proceed after a delay if launch fails or app returns
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isLaunching = false;
          });
          // If we are still on this screen, proceed to setup
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => const SetupScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // This captures taps on the background
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _launchURL,
              child: Container(color: Colors.transparent),
            ),
          ),
          // This captures taps on the image specifically
          Center(
            child: GestureDetector(
              onTap: _launchURL,
              child: Image.asset('assets/images/thankyou.png'),
            ),
          ),
        ],
      ),
    );
  }
}
