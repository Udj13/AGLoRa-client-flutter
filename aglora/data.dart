import 'dart:async';

class AGLoRaSensor {
  AGLoRaSensor({required this.name, required this.value});

  String name;
  String value;
}

class AGLORATrackerPoint {
  AGLORATrackerPoint(
      {required this.identifier,
      required this.latitude,
      required this.longitude,
      required this.time,
      this.sensors});

  String identifier;
  double latitude;
  double longitude;
  DateTime time;

  List<AGLoRaSensor>? sensors;
}

var dataStreamController =
    StreamController<List<AGLORATrackerPoint>>.broadcast();

Stream<List<AGLORATrackerPoint>> get trackersListStream =>
    dataStreamController.stream;

const String packagePrefix = 'AGLoRa-';
const String packagePostfix = '|';

const requestAllTrackers = 'all';
