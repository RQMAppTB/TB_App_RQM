import 'package:maps_toolkit/maps_toolkit.dart' as mp;

class Config {
  // ------------------- API -------------------
  static const String SERVER_API ='rqm.iict-heig-vd.ch';//'192.168.61.106:3000';//
  static const String API_URL = SERVER_API;//'http://192.168.61.106:3000/app/';//'https://www.larouequimarche.ch/wp-admin/admin-ajax.php';
  static const String API_COMMON_ADDRESS = '/app/measures/';
  // -------------- Début et fin ---------------
  static const String END_TIME = '2024-07-10 17:00:00';
  static const String START_TIME = '2024-01-25 17:00:00';
  // ----------------- QR code -----------------
  static const String QR_CODE_S_VALUE = 'Ready';
  static const String QR_CODE_F_VALUE = 'Stop';
  // ------------- Zone Evènement --------------
  static const double LAT1 = 46.62094732231268;
  static const double LON1 = 6.71095185969227;
  static const double LAT2 = 46.60796048493062;
  static const double LON2 = 6.7304699219465105;

  static List<mp.LatLng> POLYGON = [
    mp.LatLng(LAT1, LON1),
    mp.LatLng(LAT2, LON1),
    mp.LatLng(LAT2, LON2),
    mp.LatLng(LAT1, LON2),
  ];

  static List<mp.LatLng> MY_HOME = [
    mp.LatLng(46.81506769390172, 6.935914064535421),
    mp.LatLng(46.81376575165063, 6.935914064535421),
    mp.LatLng(46.81376575165063, 6.937924842680419),
    mp.LatLng(46.81506769390172, 6.937924842680419)
  ];

  static List<mp.LatLng> POLYGON2 = [
    mp.LatLng(46.74308195291572, 6.6776287039768),
    mp.LatLng(46.732896423225036, 6.6776287039768),
    mp.LatLng(46.732896423225036, 6.701948509720427),
    mp.LatLng(46.74308195291572, 6.701948509720427)
  ];

  // ----------------- Couleurs -----------------
  static const int COLOR_APP_BAR = 0xFF403c74;
  static const int COLOR_BUTTON = 0xFFFF9900;
  static const int COLOR_TITRE = 0xFFFFFFFF;

}

// Méthode de configuration
// scan de QR
// Firebase pour des shared preferences en lignes