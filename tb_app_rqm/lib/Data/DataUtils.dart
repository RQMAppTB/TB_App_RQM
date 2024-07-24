import 'DistPersoData.dart';
import 'DistToSendData.dart';
import 'DistTotaleData.dart';
import 'DossardData.dart';
import 'NameData.dart';
import 'NbPersonData.dart';
import 'TimeData.dart';
import 'UuidData.dart';

/// Class containing utility methods to interact with the data.
class DataUtils{

  /// Delete all data stored in the shared preferences.
  /// Return a [Future] object resolving to a boolean value indicating if the data was deleted.
  static Future<bool> deleteAllData() async {
    return DistPersoData.removeDistPerso()
        .then((value) => DistToSendData.removeDistToSend())
        .then((value) => DistTotaleData.removeDistTotale())
        .then((value) => DossardData.removeDossard())
        .then((value) => NameData.removeName())
        .then((value) => NbPersonData.removeNbPerson())
        .then((value) => TimeData.removeTime())
        .then((value) => UuidData.removeUuid())
        .then((value) => true)
        .onError((error, stackTrace) => false);
  }
}