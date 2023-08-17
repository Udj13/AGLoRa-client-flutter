import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../aglora/data.dart';
import '../aglora/memory.dart';
import '../utils/saved_parameters.dart';
import 'widgets/widget_lora_tracker_tile.dart';
import 'widgets/widget_use_compass.dart';

// 'AGLoRa-point&id=30&CRC_OK&&name=Rick&lat=54.094371&lon=45.454349&sat=9&timestamp=2023-06-23T12:47:48|'
// 'AGLoRa-point&id=31&CRC_OK&&name=Morty&lat=54.094379&lon=45.454353&sat=10&timestamp=2023-06-23T12:48:08|'

AGLORATrackerPoint newFirst = AGLORATrackerPoint(
  identifier: 'Rick',
  latitude: 54.184759,
  longitude: 45.180609,
  time: DateTime.parse('2023-08-11T10:47:48'),
  sensors: [
    AGLoRaSensor(name: 'Satellites', value: '10'),
    AGLoRaSensor(name: 'Battery', value: '78'),
  ],
);

AGLORATrackerPoint newSecond = AGLORATrackerPoint(
  identifier: 'Morty',
  latitude: 54.181119,
  longitude: 45.200609,
  time: DateTime.parse('2023-08-11T09:17:08'),
);

List<AGLORATrackerPoint> trackersDemoDataList = [newFirst, newSecond];

class DeviceDemoScreen extends StatefulWidget {
  const DeviceDemoScreen({Key? key}) : super(key: key);

  @override
  State<DeviceDemoScreen> createState() => _DeviceDemoScreenState();
}

class _DeviceDemoScreenState extends State<DeviceDemoScreen> {
  @override
  void initState() {
    super.initState();
    agloraAppMemory.trackers = trackersDemoDataList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("AGLoRa"),
          actions: [
            Row(
              children: [
                OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white, width: 1),
                    ),
                    child: Text(
                      "Disconnect",
                      style: Theme.of(context)
                          .primaryTextTheme
                          .labelLarge
                          ?.copyWith(color: Colors.white),
                    )),
                SizedBox(width: 10),
                Icon(CupertinoIcons.bluetooth,
                    color: Colors.lightGreenAccent.shade100),
                SizedBox(width: 10),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: trackersDemoDataList
                    .map((e) => LORAtrackerTile(
                        time: e.time,
                        lat: e.latitude,
                        lon: e.longitude,
                        identifier: e.identifier,
                        sensors: e.sensors,
                        useCompass: useCompass))
                    .toList(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: WidgetUseCompass(),
        ));
  }
}
