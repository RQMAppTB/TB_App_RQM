import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../Data/DistPersoData.dart';
import '../Data/DistTotaleData.dart';
import '../Data/DossardData.dart';
import '../Utils/config.dart';
import 'Result.dart';

class EventController {

  static final _distTotaleHandler = DistTotaleData();

  static Future<Result<int>> getTotalDistance() {

    log("Getting total distance");

    final uri =
    Uri.http(Config.API_URL, '${Config.API_COMMON_ADDRESS}getAllDist');


    log("URI: $uri");

    return http.get(uri)
        .then((response) {
          if (response.statusCode == 200) {

            log("Response body: ${response.body}");

            int dist = jsonDecode(response.body)["distTraveled"];

            _distTotaleHandler.saveDistTotale(dist);
            return Result<int>(value: dist);
            //return dist;
          } else {
            //log("Failed to get total distance");
            throw Exception('Status code ${response.statusCode}: ${jsonDecode(response.body)["message"]}');
          }
        })
        .onError((error, stackTrace) {
          log("Error: $error");
          return Result<int>(error: error.toString());
        });
  }

  static Future<Result<int>> getPersonalDistance() async {

    int? dosNumber = await DossardData().getDossard();

    //dosNumber = 9;

    if(dosNumber == null){
      return Result<int>(error: "Dossard number is null");
    }

    final uri =
    Uri.http(Config.API_URL, '${Config.API_COMMON_ADDRESS}getUserDist', {"dosNumber": dosNumber.toString()});

    return http.get(uri)
        .then((response) async {
          if (response.statusCode == 200) {
            log("Response body: ${response.body}");

            var dist = jsonDecode(response.body)["distTraveled"];

            bool isSaeved = await DistPersoData().saveDistPerso(dist);

            if(isSaeved){
              return Result<int>(value: dist);
            }else{
              throw Exception('Failed to save personal distance');
            }
          } else {
            throw Exception('Failed to get personal distance');
          }
        })
        .onError((error, stackTrace) {
          log("Error: $error");
          return Result<int>(error: error.toString());
        });

    return Result<int>(error: "Error");
  }
}