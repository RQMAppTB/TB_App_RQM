import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../Data/DistPersoData.dart';
import '../Data/DistTotaleData.dart';
import '../Data/DossardData.dart';
import '../Utils/config.dart';
import '../Utils/Result.dart';

/// Class containing methods to interact with the API
/// to get data about the event.
/// Allow to get the total distance traveled by all participants
/// and the distance traveled by the current participant.
class EventController {

  /// Retrieve the total distance traveled by all participants from the API.
  /// Return a Result object containing the distance if the request was successful
  /// or an error message if the request failed.
  static Future<Result<int>> getTotalDistance() async {

    log("Getting total distance");

    final uri =
    Uri.http(Config.API_URL, '${Config.API_COMMON_ADDRESS}getAllDist');

    log("URI: $uri");

    /// Send a GET request to the API to get the total distance traveled by all participants.
    return http.get(uri)
        .then((response) {
          if (response.statusCode == 200) {

            log("Response body: ${response.body}");

            int dist = jsonDecode(response.body)["distTraveled"];

            /// Save the total distance in the local database.
            DistTotaleData.saveDistTotale(dist);
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

    int? dosNumber = await DossardData.getDossard();

    if(dosNumber == null){
      return Result<int>(error: "Dossard number is null");
    }

    final uri =
    Uri.http(Config.API_URL, '${Config.API_COMMON_ADDRESS}getUserDist', {"dosNumber": dosNumber.toString()});

    return http.get(uri)
        .then((response) async {
          if (response.statusCode == 200) {
            log("Status code: ${response.statusCode}");
            log("Response body: ${response.body}");

            var dist = jsonDecode(response.body)["distTraveled"];

            bool isSaved = await DistPersoData.saveDistPerso(int.parse(dist.toString()));

            if(isSaved){
              return Result<int>(value: dist);
            }else{
              throw Exception('Failed to save personal distance');
            }
          }else if(response.statusCode == 404){
            bool isSaved = await DistPersoData.saveDistPerso(0);

            if(isSaved){
              return Result<int>(value: 0);
            }else{
              throw Exception('Failed to save personal distance');
            }
          }else {
            throw Exception('Status code ${response.statusCode}: ${jsonDecode(response.body)["message"]}');
          }
        })
        .onError((error, stackTrace) {
          log("Error: $error");
          return Result<int>(error: error.toString());
        });

    return Result<int>(error: "Error");
  }
}