// import 'dart:typed_data';
//
// import 'data.dart';
//
// const trackerDataPackageLength = 21; //bytes, defined in AGLoRa protocol
//
// List<AGLORATrackerPoint> parseAGLORaDATA(List<List<int>> data) {
//   List<AGLORATrackerPoint> result = [];
//   int count = 0;
//
//   print(data);
//
//   data.forEach((element) {
//     if (element.isNotEmpty) {
//       if (element[0] != 0x1D) return; //check group separator, 1 byte
//       print('GS - checked');
//
//       if (element[2] != 0x02) return; // check start of text, 1 byte
//       print('SoT - checked');
//
//       String trackerName = '';
//       int endOfTrackerName =
//           element.indexOf(0x03); // end of heading, 0x03, 1 byte
//       if (endOfTrackerName == -1) return;
//
//       for (final c in element.getRange(3, endOfTrackerName))
//         if (c != 0) trackerName += String.fromCharCode(c);
//
//       print('Tracker: ${trackerName}');
//
//       List<int> navData = element.sublist(endOfTrackerName + 1);
//       print('NAVIGATION DATA ${navData}');
//
//       if (navData[0] != 0x1E) return; //check record separator
//       print('RS - check');
//
//       if (navData[16] != 0x4) return; //check check end of transmission
//       print('EoT - check');
//
//       Uint8List coords = Uint8List.fromList(navData.sublist(1, 9));
//       List<double> floatList = coords.buffer.asFloat32List();
//       final double latitude = floatList[0];
//       final double longitude = floatList[1];
//       final int satellites = navData[9];
//       print('LAT: ${latitude}, LON: ${longitude}, SAT: ${satellites}');
//
//       final int year = navData[10] + 1792;
//       final int month = navData[11];
//       final int day = navData[12];
//       final int hour = navData[13];
//       final int minute = navData[14];
//       final int second = navData[15];
//       print('${day}/${month}/${year}, ${hour}:${minute}:${second}');
//
//       final dateTime = DateTime(year, month, day, hour, minute, second);
//
//       final AGLORATrackerPoint newTracker =
//           AGLORATrackerPoint(trackerName, latitude, longitude, dateTime);
//
//       result.add(newTracker);
//       count++;
//     }
//   });
//
//   // print('Parsing ${count} trackers');
//
//   return result;
// }
