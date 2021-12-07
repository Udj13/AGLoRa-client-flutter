import 'dart:core'; //https://api.flutter.dev/flutter/dart-core/DateTime-class.html
import 'dart:typed_data';

import 'package:flutter/material.dart';

class AGLORATrackerData {
  AGLORATrackerData(this.identificator, this.latitude, this.longitude,
      this.satellites, this.time);

  String identificator;
  double latitude;
  double longitude;
  int satellites;
  DateTime time;
}

const maxPackageLength = 520; // cash, bytes, all size
const trackerDataPackageLength = 21; //bytes, defined in AGLoRa protocol
String myName = '';
int countOfTrackers = 0;
int headerEndIndex = 0;
List<AGLORATrackerData> trackersDataList = [];
List<int> BLEDataStream = [];
List<int> BLEPreviousData = [];
List<List<int>> ValidatedData = [[]];

void newDataReceived(List<int> value) {
  print('NEW BLE DATA RECEIVED: ${value}');

  if (BLEDataStream.length > maxPackageLength) BLEDataStream = [];
  if (BLEPreviousData != value) BLEDataStream += value;
  BLEPreviousData = value;

  final ValidatedData = _validateNewData();
  if (ValidatedData.length > 0) {
    bool has_data = false;

    _parseAGLORaDATA(ValidatedData).forEach((new_entry) {
      for (var i = 0; i < trackersDataList.length; i++) {
        if (trackersDataList[i].identificator == new_entry.identificator) {
          has_data = true;
          if ((trackersDataList[i].latitude != new_entry.latitude) ||
              (trackersDataList[i].longitude != new_entry.longitude)) {
            trackersDataList[i].time = DateTime.now();
            trackersDataList[i].latitude = new_entry.latitude;
            trackersDataList[i].longitude = new_entry.longitude;
          }
        }
      }

      if (!has_data) trackersDataList.add(new_entry);
      trackersDataList.sort((a, b) => b.time.compareTo(a.time));
    });
  }
}

void eraseAllData() {
  trackersDataList.clear();
}

List<List<int>> _validateNewData() {
  //print('BLE DATA STREAM: ${BLEDataStream}');
  const nameAGLoRa = 'AGLoRa';
  bool isAGLoRaFind = false;
  int myNameLength = 0;
  int findA = -1;
  countOfTrackers = 0;
  headerEndIndex = 0;
  List<List<int>> result = [[]];

  try {
    findA = BLEDataStream.indexOf(nameAGLoRa[0].codeUnitAt(0)); //find "A"
    if (findA != -1) {
      String trackerName = ''; // read all word
      for (final c in BLEDataStream.getRange(findA, findA + nameAGLoRa.length))
        trackerName += String.fromCharCode(c);

      if (trackerName == nameAGLoRa) isAGLoRaFind = true; // check word "AGLoRa"
    } else
      return result;

    if (isAGLoRaFind) {
      //validate protocol
      if (BLEDataStream[findA + nameAGLoRa.length] != 0xAA) //dec 170
        isAGLoRaFind = false; //check BLE protocol version, 1 byte

      myNameLength = BLEDataStream[findA + nameAGLoRa.length + 1];

      if (BLEDataStream[findA + nameAGLoRa.length + 2] != 0x01)
        isAGLoRaFind = false; //check start of heading, 0x01, 1 byte

      //Find my tracker name
      final myNameStartIndex = findA + nameAGLoRa.length + 3;
      final myNameEndIndex = BLEDataStream.indexOf(
          0x03, myNameStartIndex); // end of heading, 0x03, 1 byte
      if (myNameEndIndex == -1) {
        isAGLoRaFind = false;
        return result;
      }

      myName = '';
      for (final c in BLEDataStream.getRange(myNameStartIndex, myNameEndIndex))
        if (c != 0) myName += String.fromCharCode(c);

      headerEndIndex = myNameEndIndex + 1;
      countOfTrackers =
          BLEDataStream[headerEndIndex]; // other trackers in package
    }
  } catch (e) {
    print("Error validating: ${e}");
    isAGLoRaFind = false;
  }

  if (isAGLoRaFind) {
    print(
        "NEW AGLORA BLE PACKET, MY NAME IS ${myName}, ${countOfTrackers} trackers in view");
  }

  // Congratulations! Half done! Then navigation data check

  if (isAGLoRaFind && (countOfTrackers != 0)) {
    // Length check
    final trackerDataLength = trackerDataPackageLength + myNameLength;
    final allDataLength = countOfTrackers * trackerDataLength;

    if (BLEDataStream.length - headerEndIndex > allDataLength) {
      for (int i = 0; i < countOfTrackers; i++) {
        final shift = trackerDataLength * i + 1;
        final List<int> trackerData = BLEDataStream.sublist(
            headerEndIndex + shift, headerEndIndex + trackerDataLength + shift);
        result.add(trackerData);
        //print("Tracker: ${trackerData}");
      }
    } else {
      isAGLoRaFind = false;
    }
  }

  if (isAGLoRaFind) {
    //print("Cut off header");
    BLEDataStream = BLEDataStream.sublist(headerEndIndex + 1); //Cut off header
  }

  //print('BLE DATA STREAM after _validateNewData: ${BLEDataStream}');

  return result;
}

List<AGLORATrackerData> _parseAGLORaDATA(List<List<int>> data) {
  List<AGLORATrackerData> result = [];
  int count = 0;

  print(data);

  data.forEach((element) {
    if (element.isNotEmpty) {
      if (element[0] != 0x1D) return; //check group separator, 1 byte
      print('GS - checked');

      if (element[2] != 0x02) return; // check start of text, 1 byte
      print('SoT - checked');

      String trackerName = '';
      int endOfTrackerName =
          element.indexOf(0x03); // end of heading, 0x03, 1 byte
      if (endOfTrackerName == -1) return;

      for (final c in element.getRange(3, endOfTrackerName))
        if (c != 0) trackerName += String.fromCharCode(c);

      print('Tracker: ${trackerName}');

      List<int> navData = element.sublist(endOfTrackerName + 1);
      print('NAVIGATION DATA ${navData}');

      if (navData[0] != 0x1E) return; //check record separator
      print('RS - check');

      if (navData[16] != 0x4) return; //check check end of transmission
      print('EoT - check');

      Uint8List coords = Uint8List.fromList(navData.sublist(1, 9));
      List<double> floatList = coords.buffer.asFloat32List();
      final double latitude = floatList[0];
      final double longitude = floatList[1];
      final int satellites = navData[9];
      print('LAT: ${latitude}, LON: ${longitude}, SAT: ${satellites}');

      final int year = navData[10] + 1792;
      final int month = navData[11];
      final int day = navData[12];
      final int hour = navData[13];
      final int minute = navData[14];
      final int second = navData[15];
      print('${day}/${month}/${year}, ${hour}:${minute}:${second}');

      final dateTime = DateTime(year, month, day, hour, minute, second);

      final AGLORATrackerData new_tracker = AGLORATrackerData(
          trackerName, latitude, longitude, satellites, dateTime);

      result.add(new_tracker);
      count++;
    }
  });

  // print('Parsing ${count} trackers');

  return result;
}
