import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;
class Geolocation{

  late StreamSubscription<geo.Position> _positionStream;
  late geo.LocationSettings _settings;
  int _counter = 0;
  late geo.Position _oldPos;

  bool _positionStreamStarted = false;

  Geolocation(){
    //_oldPos = geo.Position(latitude: 0, longitude: 0, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0);
    _settings = _getSettings();
  }

  /// Get the location settings
  geo.LocationSettings _getSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return geo.AndroidSettings(
        accuracy: geo.LocationAccuracy.high,
        intervalDuration: const Duration(seconds: 5),
        distanceFilter: 1,
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

  Future<void> startListening(StreamSink<int> streamSink) async {
    log("Can start listening? ${!_positionStreamStarted}");
    if(!_positionStreamStarted) {
      log("Starting");
      _positionStreamStarted = true;
      geo.Geolocator.getCurrentPosition().then((position) {
        log("Position: $position");
        _oldPos = position;
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

  /// Get the current location of the user
  /// Returns the current location of the user

  /// Check if the location is in the zone
  /// Returns true if the location is in the zone
  /// Returns false if the location is not in the zone
  /// TODO: Implement this function
  static Future<bool> isLocationInZone() async {
    return true;
  }


}