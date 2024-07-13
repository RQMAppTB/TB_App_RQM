import 'DistPersoData.dart';
import 'DistToSendData.dart';
import 'DistTotaleData.dart';
import 'DossardData.dart';
import 'NameData.dart';
import 'NbPersonData.dart';
import 'TimeData.dart';
import 'UuidData.dart';

class DataUtils{
  static Future<bool> deleteAllData() async {

    return DistPersoData().removeDistPerso()
        .then((value) => DistToSendData().removeDistToSend())
        .then((value) => DistTotaleData().removeDistTotale())
        .then((value) => DossardData().removeDossard())
        .then((value) => NameData().removeName())
        .then((value) => NbPersonData().removeNbPerson())
        .then((value) => TimeData().removeTime())
        .then((value) => UuidData().removeUuid())
        .then((value) => true)
        .onError((error, stackTrace) => false);
  }
}