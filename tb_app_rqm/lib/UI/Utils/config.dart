class Config {

  static const String APP_SERVER_ORDI = 'http://192.168.61.106:3000/app/';
  static const String SERVER_API = '192.168.61.106:3000';//'rqm.iict-heig-vd.ch';
  static const String API_URL = SERVER_API;//'http://192.168.61.106:3000/app/';//'https://www.larouequimarche.ch/wp-admin/admin-ajax.php';
  static const String API_COMMON_ADDRESS = '/app/measures/';
  // -------------- Début et fin ---------------
  static const String END_TIME = '2024-07-25 17:00:00';
  static const String START_TIME = '2024-01-25 17:00:00';
  // ----------------- QR code -----------------
  static const String QR_CODE_S_VALUE = 'Ready';
  static const String QR_CODE_F_VALUE = 'Not Ready';
  // ------------- Zone Evènement --------------
  static const String LAT1 = '46.778';
  static const String LON1 = '6.641';
  static const String LAT2 = '46.778';
  static const String LON2 = '6.641';

}

// Méthode de configuration
// scan de QR
// Firebase pour des shared preferences en lignes