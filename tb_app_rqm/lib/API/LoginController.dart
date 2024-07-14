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

import '../Data/DataManagement.dart';

class LoginApi{

  final String _actionType = 'get_username';
  static final _dataManagement = DataManagement();

  static Future<Result<bool>> login(String name, int dosNum) async {

    log("Login: name :$name, dosnum: $dosNum");

    final uri =
    Uri.http(Config.API_URL, '${Config.API_COMMON_ADDRESS}login');

    log('URI: $uri');

    return http.post(
        uri,
        body: {
          'dosNumber': dosNum.toString(),
          'username': name
        }
    ).then((response) async {
      if (response.statusCode == 200 || response.statusCode == 201) {
        log("Response body: ${response.body}");

        var jsonResult = jsonDecode(response.body);

        var isSaved = await DossardData().saveDossard(int.parse(jsonResult["dosNumber"]));
        log("Test 2");
        isSaved = isSaved && await NameData().saveName(jsonResult["username"]);
        log("Test 3");
        isSaved = isSaved && await DistPersoData.saveDistPerso(jsonResult["distTraveled"] ?? 0);

        if(isSaved) {
          return Result(value: true);
        } else {
          throw Exception('Failed to save dossard or username');
        }

      } else {
        throw Exception('Failed to login');
      }
    }).onError((error, stackTrace) {
      log("Error: $error");
      if (error is http.ClientException) {
        return Result(error: "No connection to the server");
      }
      return Result(error: "error: ${error.toString()}");
    });
  }

  static Future<Result<bool>> logout() async {

    var uuid = UuidData();

    bool isMeasureRunning = await uuid.doesUuidExist();

    log("Is measure running: $isMeasureRunning");

    if(isMeasureRunning){
      Result result = await MeasureController.stopMeasure();
      isMeasureRunning = result.hasError;
    }

    log("Is measure running: $isMeasureRunning");

    if(!isMeasureRunning){
      bool deletionDone = await DataUtils.deleteAllData();

      return Result(value: deletionDone);
    } else {
      return Result(error: "Failed to logout");
    }
  }

  static Future<Result<String>> getDossardName(int dosNumber) async {

    final uri =
    Uri.http(Config.API_URL, '${Config.API_COMMON_ADDRESS}ident', {"dosNumber": dosNumber.toString().padLeft(4, '0')});

    log('URI: $uri');

    return http.get(uri)
        .then((response) async {
          log("Status code: ${response.statusCode}");
          if (response.statusCode == 200) {
            log("Response body: ${response.body}");

            var name = jsonDecode(response.body)["name"];

            return Result<String>(value: name);

          } else if (response.statusCode == 404) {
            return Result<String>(error: "Ce dossard n'existe pas dans cet univers, essayez de demander à Dr.Strange!");
          } else {
            throw Exception('Failed to get username');
          }
        })
        .onError((error, stackTrace) {
          log("Error: $error");
          if (error is http.ClientException) {
            return Result<String>(error: "No connection to the server");
          }
          return Result<String>(error: 'Failed to get username');
        });
  }

}