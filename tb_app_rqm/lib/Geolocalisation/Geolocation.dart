import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'package:tb_app_rqm/API/MeasureController.dart';
import 'package:tb_app_rqm/Data/DistToSendData.dart';
import 'package:tb_app_rqm/Data/TimeData.dart';
import 'package:tb_app_rqm/Utils/config.dart';
class Geolocation{

  late StreamSubscription<geo.Position> _positionStream;
  late geo.LocationSettings _settings;
  late geo.Position _oldPos;
  int _distance = 0;
  int _mesureToWait = 0;
  DateTime _startTime = DateTime.now();

  bool _positionStreamStarted = false;

  Geolocation(){
    _settings = _getSettings();
  }

  /// Get the location settings
  geo.LocationSettings _getSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return geo.AndroidSettings(
        accuracy: geo.LocationAccuracy.high,
        intervalDuration: const Duration(seconds: 5),
        //forceLocationManager: true,
        foregroundNotificationConfig: const geo.ForegroundNotificationConfig(
          notificationText:
          "Example app will continue to receive your location even when you aren't using it",
          notificationTitle: "Running in Background",
          enableWakeLock: true,
        )
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      return geo.AppleSettings(
        accuracy: geo.LocationAccuracy.high,
        activityType: geo.ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: true,
      );
    } else {
      return const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 5,
      );
    }
  }

  Future<geo.Position> determinePosition() async {

    return await geo.Geolocator.getCurrentPosition();
  }

  Future<void> startListening(StreamSink<int> streamSink) async {
    log("Can start listening? ${!_positionStreamStarted}");
    if(!_positionStreamStarted) {
      log("Starting");
      _positionStreamStarted = true;
      geo.Geolocator.getCurrentPosition(/*).then((position1) =>
        geo.Geolocator.getCurrentPosition()
      ).then((position2) =>
        geo.Geolocator.getCurrentPosition()
      ).then((position3) =>
        geo.Geolocator.getCurrentPosition()
      ).then((position4) =>
        geo.Geolocator.getCurrentPosition()*/
      ).then((position) {



        log("Position: $position");

        _oldPos = position;
        _mesureToWait = 0;
        _distance = 0;
        _startTime = DateTime.now();

        _positionStream =
            geo.Geolocator.getPositionStream(locationSettings: _settings)
                .listen((geo.Position position) {

              log("Entered position stream");
              var distSinceLast = geo.Geolocator.distanceBetween(
                  _oldPos.latitude, _oldPos.longitude, position.latitude,
                  position.longitude).truncate();

              // Attente pour éviter les première mesures un peu étranges
              if(_mesureToWait > 0){
                _mesureToWait--;
              }else {

                log("Distance: $distSinceLast");

                _oldPos = position;

                _distance += distSinceLast;

                // Calculate the time diff between now and the start time
                Duration diff = DateTime.now().difference(_startTime);

                TimeData.saveTime(diff.inSeconds);
                DistToSendData.saveDistToSend(_distance);
                streamSink.add(_distance);
                MeasureController.sendMesure().then((value) {
                  if (value.error != null) {
                    log("Error: ${value.error}");
                  } else {
                    log("Value: ${value.value}");
                    streamSink.add(_distance);
                  }
                });
              }
            });
      });
          /*.then((geo.Position position) {


      }).onError((error, stackTrace) {
        log("Error: $error");
        _positionStreamStarted = false;
      });*/

      //log("Entered current position: $position");

      log("Entered current position");
      /*_oldPos = position;
      _positionStream =
          geo.Geolocator.getPositionStream(locationSettings: _settings)
              .listen((geo.Position position) {
            //_counter++;
            //streamSink.add(_counter);

            log("Entered position stream");
            var distSinceLast = geo.Geolocator.distanceBetween(
                _oldPos.latitude, _oldPos.longitude, position.latitude,
                position.longitude).truncate();
            log("Distance: $distSinceLast");
            _oldPos = position;

            streamSink.add(distSinceLast);

            //Ecrire sur un stream
            //stream.;
          });*/
    }else{
      log("Position stream already started");
    }
  }

  void stopListening() {
    if(_positionStreamStarted){
      _positionStream.cancel().then((value) {
        _positionStreamStarted = false;
      });
    }
  }

  /// Check if [point] is in the zone defin in the [config.dart] file.
  /// Returns true if the point is in the zone
  /// Returns false if the point is not in the zone
  bool isLocationInZone(geo.Position point) {
    var tmp = mp.LatLng(point.latitude, point.longitude);
    var test = mp.PolygonUtil.containsLocation(tmp, Config.POLYGON, false);
    return test;
  }

  /// Check if the current location is in the zone
  /// Returns true if the current location is in the zone
  /// Returns false if the current location is not in the zone
  Future<bool> isInZone() async {
    final tmp = await determinePosition();
    var test = isLocationInZone(tmp);
    return test;
  }


}