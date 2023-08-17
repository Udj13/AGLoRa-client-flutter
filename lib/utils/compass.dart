import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:aglora_client/utils/saved_parameters.dart';

var compassStreamController = StreamController<double>.broadcast();

Stream<double> get compassDataStream => compassStreamController.stream;

void newHeading(double newHeading) {
  if (compassStreamController.hasListener && useCompass) {
    compassStreamController.add(newHeading);
  }
}

void startCompassListener() {
  try {
    FlutterCompass.events?.listen((event) {
      newHeading(event.heading ?? 0);
    });
  } catch (e) {
    if (kDebugMode) print('Error in startCompassListener: $e');
  }
  ;
}

void enableCompass() {}

void disableCompass() {
  compassStreamController.add(0);
}
