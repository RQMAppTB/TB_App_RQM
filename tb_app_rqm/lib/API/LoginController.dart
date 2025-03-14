import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../API/MeasureController.dart';
import '../Utils/Result.dart';
import '../Data/DataUtils.dart';
import '../Data/DistPersoData.dart';
import '../Data/DossardData.dart';
import '../Data/NameData.dart';
import '../Data/UuidData.dart';
import '../Utils/config.dart';

/// Class containing methods to interact with the API to manage all
/// data about login and logout.
class LoginController {
  /// Register the user [name] and [dosNum] in the API.
  /// Return a [Future] object resolving to a [Result] object
  /// containing a boolean value if the request was successful or an error message
  /// if the request failed.
  static Future<Result<bool>> login(String name, int dosNum) async {
    log("Login: name :$name, dosnum: $dosNum");

    /// URI to send the POST request to the API to register the user.
    final uri = Uri.https(Config.API_URL, '${Config.API_COMMON_ADDRESS}login');

    log('URI: $uri');

    return http.post(uri, body: {'dosNumber': dosNum.toString(), 'username': name}).then((response) async {
      if (response.statusCode == 200 || response.statusCode == 201) {
        log("Status code: ${response.statusCode}");
        log("Response body: ${response.body}");

        var jsonResult = jsonDecode(response.body);

        log("Json result: dosNumber: ${jsonResult["dosNumber"]}, username: ${jsonResult["username"]}, distTraveled: ${jsonResult["distTraveled"]}");

        // Save the dossard number, the name and the distance traveled by the user in the shared preferences
        // Convert the dosNumber and distTraveled to a string before converting
        // them to an integer to be able to take both integer and integer as string from the json.
        var isSaved = await DossardData.saveDossard(int.parse(jsonResult["dosNumber"].toString()));
        log("Is saved after dosNumber: $isSaved");
        isSaved = isSaved && await NameData.saveName(jsonResult["username"]);
        log("Is saved after username: $isSaved");
        isSaved = isSaved && await DistPersoData.saveDistPerso(int.parse((jsonResult["distTraveled"]).toString()));
        log("Is saved after distTraveled: $isSaved");

        if (isSaved) {
          return Result(value: true);
        } else {
          DataUtils.deleteAllData();
          throw Exception('Failed to save dossard or username');
        }
      } else {
        throw Exception('Échec de la connexion : ${response.statusCode}');
      }
    }).onError((error, stackTrace) {
      log("Error: $error");
      if (error is http.ClientException) {
        return Result(error: "Pas de connexion au serveur");
      }
      return Result(error: "Erreur : ${error.toString()}");
    });
  }

  /// Logout the user by deleting all data stored in the device.
  /// Return a [Future] object resolving to a [Result] object
  /// containing a boolean value if the request was successful or an error message
  /// if the request failed.
  static Future<Result<bool>> logout() async {
    /// Boolean value indicating if a measure is running
    bool isMeasureRunning = await UuidData.doesUuidExist();

    log("Is measure running: $isMeasureRunning");

    // Stop the measure if it is running
    if (isMeasureRunning) {
      Result result = await MeasureController.stopMeasure();
      isMeasureRunning = result.hasError;
    }

    log("Is measure running: $isMeasureRunning");

    if (!isMeasureRunning) {
      bool deletionDone = await DataUtils.deleteAllData();

      return Result(value: deletionDone);
    } else {
      return Result(error: "Échec de la déconnexion");
    }
  }

  /// Retrieve the name of the user with the dossard number [dosNumber] from the API.
  /// Return a [Future] object resolving to a [Result] object
  /// containing the name corresponding to the [dosNumber]
  /// if the request was successful or an error message if the request failed.
  static Future<Result<String>> getDossardName(int dosNumber) async {
    final uri = Uri.https(
        Config.API_URL, '${Config.API_COMMON_ADDRESS}ident', {"dosNumber": dosNumber.toString().padLeft(4, '0')});

    log('URI: $uri');

    return http.get(uri).then((response) async {
      log("Status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        log("Response body: ${response.body}");

        var name = jsonDecode(response.body)["name"];

        return Result<String>(value: name);
      } else if (response.statusCode == 404) {
        return Result<String>(error: "Ce dossard n'existe pas. Veuillez vérifier le numéro et réessayer.");
      } else {
        throw Result<String>(error: 'Échec de la récupération du nom d\'utilisateur');
      }
    }).onError((error, stackTrace) {
      log("Error: $error");
      if (error is http.ClientException) {
        return Result<String>(error: "Pas de connexion au serveur");
      }
      return Result<String>(error: 'Échec de la récupération du nom d\'utilisateur');
    });
  }
}
