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

  /// StreamSubscription to save the position stream and manipulate it
  late StreamSubscription<geo.Position> _positionStream;
  /// Location settings to define the accuracy of the location
  late geo.LocationSettings _settings;
  /// last position to calculate the distance between two points
  late geo.Position _oldPos;
  /// distance traveled by the user
  int _distance = 0;
  /// Number of measures to wait before starting to calculate the distance
  int _mesureToWait = 0;
  /// Start time of the measure
  DateTime _startTime = DateTime.now();
  /// Counter to check if the user is outside the zone
  int _outsideCounter = 0;
  /// StreamController to listen to the distance traveled updates
  StreamController<int> _streamController = StreamController<int>();
  /// Boolean to check if the measure stream is started
  bool _positionStreamStarted = false;

  Geolocation(){
    _settings = _getSettings();
  }

  Stream<int> get stream => _streamController.stream;

  /// Handle the permission to access the location
  static Future<bool> handlePermission() async {
    final geo.GeolocatorPlatform _geolocatorPlatform = geo.GeolocatorPlatform.instance;
    bool serviceEnabled;
    geo.LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Request permission if not granted
    permission = await _geolocatorPlatform.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        return false;
      }
    }

    // Check if the permission is denied forever
    if (permission == geo.LocationPermission.deniedForever) {
      return false;
    }

    // All is good
    return true;
  }

  /// Get the settings for the location stream depending on the platform
  geo.LocationSettings _getSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return geo.AndroidSettings(
        accuracy: geo.LocationAccuracy.high,
        intervalDuration: const Duration(seconds: 5),
        foregroundNotificationConfig: const geo.ForegroundNotificationConfig(
          notificationText:
          "Pas de panique, c'est la RQM qui vous suit!",
          notificationTitle: "Running in Background",
          enableWakeLock: true,
          notificationIcon: geo.AndroidResource(name: 'launcher_icon', defType: 'mipmap'),
        )
      );
    }
    else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      return geo.AppleSettings(
        accuracy: geo.LocationAccuracy.high,
        activityType: geo.ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      return const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 5,
      );
    }
  }

  /// Determine the current position of the user and return it
  /// Returns the current position of the user
  Future<geo.Position> determinePosition() async {
    return await geo.Geolocator.getCurrentPosition();
  }

  /// Start measuring the distance traveled by the user and send the data to the server
  /// If the measure is already started or the location rights are not granted,
  /// the function will return while notifying the stream with -1.
  /// If the current location is not in the zone for 5 consecutive measures,
  /// the function will return while notifying the stream with -1.
  ///
  Future<void> startListening() async {
    log("Can start listening? ${!_positionStreamStarted}");
    if(!_positionStreamStarted && await handlePermission()) {
      log("Starting");

      _positionStreamStarted = true;

      _mesureToWait = 3;
      _positionStream =
          geo.Geolocator.getPositionStream(locationSettings: _settings)
              .listen((geo.Position position) async {
            // Wait for the first measures to avoid strange values
            if(_mesureToWait > 0){
              log("Position: $position");
              _oldPos = position;
              _distance = 0;
              _startTime = DateTime.now();
              _mesureToWait--;
            }else {
              log("Position: $position");
              log("Entered position stream");
              var distSinceLast = geo.Geolocator.distanceBetween(
                  _oldPos.latitude, _oldPos.longitude, position.latitude,
                  position.longitude).truncate();

              log("Distance: $distSinceLast");

              // Update the old position
              _oldPos = position;

              // Update the distance
              _distance += distSinceLast;

              // Calculate the time diff between now and the start time
              Duration diff = DateTime.now().difference(_startTime);

              // Check if the current location is in the zone
              if(!isLocationInZone(position)) {
                log("Out zone");
                if(_outsideCounter < 5){
                  _outsideCounter++;
                }else{
                  _distance = -1;
                  _streamController.sink.add(_distance);
                }
              }else {
                log("In zone");
                await TimeData.saveTime(diff.inSeconds);
                await DistToSendData.saveDistToSend(_distance);
                _outsideCounter = 0;
                MeasureController.sendMesure().then((value) {
                  if (value.error != null) {
                    log("Error: ${value.error}");
                  } else {
                    log("Value: ${value.value}");
                  }
                  _streamController.sink.add(_distance);
                });
              }
            }
          });
      log("Entered current position");
    }else{
      log("Position stream already started or no rights");
      _streamController.sink.add(-1);
    }
  }

  /// Stop measuring the distance traveled by the user
  /// If the measure is not started, the function will return without doing anything.
  void stopListening() {
    if(_positionStreamStarted){
      _positionStream.cancel().then((value) {
        _streamController.close();
        _positionStreamStarted = false;
      });
    }
  }

  /// Check if [point] is in the zone defin in the [config.dart] file.
  /// Returns true if the point is in the zone
  /// Returns false if the point is not in the zone
  bool isLocationInZone(geo.Position point) {
    var tmp = mp.LatLng(point.latitude, point.longitude);
    var test = mp.PolygonUtil.containsLocation(tmp, Config.TEST, false);
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