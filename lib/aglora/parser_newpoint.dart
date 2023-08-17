import 'package:flutter/foundation.dart';

import 'data.dart';

const String idPrefix = 'id=';
const String namePrefix = 'name=';
const String latPrefix = 'lat=';
const String lonPrefix = 'lon=';
const String timestampPrefix = 'timestamp=';

AGLORATrackerPoint? newPointParsing(List<String> fields) {
  String? name;
  double? latitude;
  double? longitude;
  DateTime? time;

  print(fields);
  //First, find the latitude, longitude, name and time
  for (int index = 0; index < fields.length; index++) {
    try {
      // id
      if (fields[index].trim().startsWith(idPrefix)) {
        fields.removeAt(index);
      }
      // name
      if (fields[index].trim().startsWith(namePrefix)) {
        name = fields[index].substring(namePrefix.length, fields[index].length);
        fields.removeAt(index);
      }
      // latitude
      if (fields[index].trim().startsWith(latPrefix)) {
        final stringLatitude =
            fields[index].substring(latPrefix.length, fields[index].length);
        latitude = double.tryParse(stringLatitude);
        fields.removeAt(index);
      }
      // longitude
      if (fields[index].trim().startsWith(lonPrefix)) {
        final stringLongitude =
            fields[index].substring(lonPrefix.length, fields[index].length);
        longitude = double.tryParse(stringLongitude);
        fields.removeAt(index);
      }
      // data and time

      if (fields[index].trim().startsWith(timestampPrefix)) {
        final stringTime = fields[index]
            .substring(timestampPrefix.length, fields[index].length);
        time = DateTime.tryParse(stringTime);
        if (kDebugMode && time == null) {
          print('NEW POINT PARSER: Error parsing data - $stringTime');
        }
        fields.removeAt(index);
      }
    } catch (e) {
      if (kDebugMode) print('PARSER NEW POINT: something went wrong');
    }
  }

  //Second, find the sensors
  List<AGLoRaSensor> sensors = [];
  for (int index = 0; index < fields.length; index++) {
    final sensor = fields[index].split('=');
    if (sensor.length == 2) {
      final String sensorName = sensor[0];
      String sensorValue = sensor[1];
      if (sensorValue.contains(packagePostfix)) {
        sensorValue = sensorValue.split(packagePostfix)[0];
      }
      sensors.add(AGLoRaSensor(name: sensorName, value: sensorValue));
    }
  }

  if ((name != null) &&
      (latitude != null) &&
      (longitude != null) &&
      (time != null)) {
    if (kDebugMode) {
      print('NEW POINT PARSER: New point found');
      sensors.forEach((sensor) {
        print('Sensor: ${sensor.name} = ${sensor.value}');
      });
    }
    if (latitude == 0 && longitude == 00) return null;
    return AGLORATrackerPoint(
        identifier: name,
        latitude: latitude,
        longitude: longitude,
        time: time,
        sensors: sensors);
  } else {
    return null;
  }
}
