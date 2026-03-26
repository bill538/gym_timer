import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gym_timer/screens/setup_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';

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
    
    Timer(
      const Duration(seconds: 2),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => const SetupScreen()),
      ),
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
    } catch (e) {
      debugPrint('Error initializing Cast: $e');
    }
  }

  void _launchURL() async {
    final Uri url = Uri.parse('https://www.21-boom.com/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchURL,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Image.asset('assets/images/21boom.png'),
        ),
      ),
    );
  }
}
