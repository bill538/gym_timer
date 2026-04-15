class AppSettings {
  static int getReadyDuration = 5; // Default to 5 seconds
  static int? getReadyBeepStart; // null means beep for full duration
  static String lastCastDeviceName = ''; // Default to blank
  static String lastCastDeviceId = ''; // Default to blank
  static bool autoConnectChromecast = false; // Default to unchecked
}