import 'DistToSendData.dart';
import 'DistTotaleData.dart';
import 'DossardData.dart';
import 'NameData.dart';
import 'ContributorsData.dart';
import 'TimeData.dart';
import 'UuidData.dart';
import 'UserData.dart';

/// Class containing utility methods to interact with the data.
class DataUtils {
  /// Delete all data stored in the shared preferences.
  /// Return a [Future] object resolving to a boolean value indicating if the data was deleted.
  static Future<bool> deleteAllData() async {
    return DistToSendData.removeDistToSend()
        .then((value) => DistTotaleData.removeDistTotale())
        .then((value) => DossardData.removeDossard())
        .then((value) => NameData.removeName())
        .then((value) => ContributorsData.removeContributors())
        .then((value) => TimeData.removeTime())
        .then((value) => UuidData.removeUuid())
        .then((value) => UserData.clearUserData())
        .then((value) => true)
        .onError((error, stackTrace) => false);
  }
}
