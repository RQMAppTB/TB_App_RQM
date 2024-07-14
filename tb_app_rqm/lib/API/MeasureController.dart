
import 'dart:convert';
import 'dart:developer';

import 'package:tb_app_rqm/Data/DistToSendData.dart';

import '../Utils/Result.dart';
import '../Data/NbPersonData.dart';

import '../Data/DistPersoData.dart';
import '../Data/DossardData.dart';
import '../Data/NameData.dart';
import '../Data/TimeData.dart';
import '../Data/UuidData.dart';
import '../Utils/config.dart';
import 'package:http/http.dart' as http;

class MeasureController {
  // ----------------- Variables -----------------
  // ------------------ Methods ------------------

  static Future<Result<bool>> startMeasure(int nbPersonnes) async {

    int? dosNumber = await DossardData.getDossard();
    String name = await NameData.getName();

    log("Starting measure with dosNumber: $dosNumber, name: $name, nbPersonnes: $nbPersonnes");

    if(name.isEmpty || dosNumber == null){
      log("Name is empty");
      return Result<bool>(error: "Missing name or dossard number");
    }

    final uri = Uri.http(Config.API_URL, '${Config.API_COMMON_ADDRESS}start');

    if (await isThereAMeasure()) {
      return Result<bool>(error: "There is already a measure in progress");
    }

    return http.post(
        uri,
        body: {
          'dosNumber': dosNumber.toString(),
          'name': name,
          'number': nbPersonnes.toString()
        })
        .then((response) async {

          log("Response: ${response.statusCode}");
          var jsonResult = jsonDecode(response.body);
          if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202) {

            log("Uuid: ${jsonResult["myUuid"]}");

            bool testIsSaved = await DistPersoData.saveDistPerso(0);
            testIsSaved = testIsSaved && await TimeData.saveTime(0);
            testIsSaved = testIsSaved && await UuidData.saveUuid(jsonResult["myUuid"]);

            return await UuidData.saveUuid(jsonResult["myUuid"]);
          } else {
            throw Exception(jsonResult["message"]);
            //return (false, response.body);
          }
        })
        .then((value) {
          return Result<bool>(value: value);
        })
        .onError((error, stackTrace) {
          return Result<bool>(error: "Error ${error.toString()}");
        });
  }

  static Future<Result<bool>> sendMesure() async {
    /*DossardData _dossardData = DossardData();
    DistPersoData _distPersoData = DistPersoData();
    TimeData _timeData = TimeData();
    UuidData _uuidData = UuidData();*/

    int dist = await DistToSendData.getDistToSend() ?? 0;
    int time = await TimeData.getTime() ?? 0;
    int number = await NbPersonData.getNbPerson() ?? 1;
    int? dossard = await DossardData.getDossard();
    String uuid = await UuidData.getUuid();

    if (dossard == null || uuid.isEmpty) {
      return Result<bool>(error: "Dossard or uuid is null");
    }

    final uri = Uri.http(Config.API_URL, '${Config.API_COMMON_ADDRESS}update-dist');

    return http.post(
        uri,
        body: {
          'uuid': uuid,
          'dist': (dist * number).toString(),
          'time': (time * number).toString()
        })
        .then((response) {
          if (response.statusCode == 200) {
            return Result<bool>(value: true);
          } else {
            throw Exception(jsonDecode(response.body)["message"]);
          }
        })
        .onError((error, stackTrace) {
          return Result<bool>(error: error.toString());
        });
  }

  static Future<Result<bool>> stopMeasure() async {
    int? dist = await DistToSendData.getDistToSend();
    int? time = await TimeData.getTime();
    String uuid = await UuidData.getUuid();

    log("Stopping measure with dist: $dist, time: $time, uuid: $uuid");

    if (uuid.isEmpty || dist == null || time == null) {
      log("Uuid, dist or time is null");
      return Result<bool>(error: "Uuid, dist or time is null");
    }

    final uri = Uri.http(Config.API_URL, '${Config.API_COMMON_ADDRESS}stop');

    log("Uri : $uri");

    return http.post(
        uri,
        body: {
          "uuid":uuid,
          "dist":dist.toString(),
          "time":time.toString()
        }
    ).then((response) async{
      log("Response: ${response.statusCode}");
      if (response.statusCode == 201 || response.statusCode == 202) {
        // Remove the uuid from the shared preferences
        await DistToSendData.removeDistToSend();
        await TimeData.removeTime();
        await UuidData.removeUuid();
        return Result<bool>(value: true);
      }else{
        log("Error: ${jsonDecode(response.body)["message"]}");
        throw Exception(jsonDecode(response.body)["message"]);
      }
    }).onError((error, stackTrace){
      log("Error: $error");
      if (error is http.ClientException) {
        return Result<bool>(error: "No connection to the server");
      }
      return Result<bool>(error: error.toString());
    });
/*
    log("Response: ${response.statusCode}");

    if (response.statusCode == 200) {
      // Remove the uuid from the shared preferences
      await UuidData().removeUuid();
      return Result<bool>(value: true);
    }else{
      return Result<bool>(error: jsonDecode(response.body)["message"]);
    }*/
  }

  static Future<bool> isThereAMeasure() async {
    return UuidData.doesUuidExist();
  }
}