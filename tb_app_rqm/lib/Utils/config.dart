import 'package:maps_toolkit/maps_toolkit.dart' as mp;

/// Class to manage the configuration of the application.
class Config {
  // ------------------- Version----------------
  static const String APP_VERSION = '1.0.0-beta.4';
  // ------------------- API -------------------
  static const String API_URL = 'api.rqm.duckdns.org';
  static const String API_COMMON_ADDRESS = '/app/measures/';
  // -------------- Début et fin ---------------
  static const String START_TIME = '2024-01-25 17:00:00';
  static const String END_TIME = '2025-06-22 17:00:00';
  // ----------------- QR code -----------------
  static const String QR_CODE_S_VALUE = 'Ready';
  static const String QR_CODE_F_VALUE = 'Stop';
  // ------------- Zone Evènement --------------
  static const double LAT1 = 46.62094732231268;
  static const double LON1 = 6.71095185969227;
  static const double LAT2 = 46.60796048493062;
  static const double LON2 = 6.7304699219465105;

  static List<mp.LatLng> ZONE_EVENT = [
    mp.LatLng(LAT1, LON1),
    mp.LatLng(LAT2, LON1),
    mp.LatLng(LAT2, LON2),
    mp.LatLng(LAT1, LON2),
  ];
  // ------------- Zone Défense ----------------
  static const double LON11 = 6.657316176588863;
  static const double LAT11 = 46.77812438877805;
  static const double LON22 = 6.657231266655643;
  static const double LAT22 = 46.782611095302414;
  static const double LON33 = 6.666675613572716;
  static const double LAT33 = 46.78271611345879;
  static const double LON44 = 6.666769701835051;
  static const double LAT44 = 46.778222689217166;
  static const double LON55 = 6.653030810529115;
  static const double LAT55 = 46.78007498916433;

  static List<mp.LatLng> ZONE_DEFENSE = [
    mp.LatLng(LAT11, LON11),
    mp.LatLng(LAT22, LON22),
    mp.LatLng(LAT33, LON33),
    mp.LatLng(LAT44, LON44),
  ];

  // ----------------- Couleurs -----------------
  static const int COLOR_APP_BAR = 0xFF403c74;
  static const int COLOR_BUTTON = 0xFFFF9900;
  static const int COLOR_TITRE = 0xFFFFFFFF;

  static String getAppVersion() {
    return APP_VERSION;
  }
}
