import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

class LORAtrackerTile extends StatelessWidget {
  const LORAtrackerTile(
      {Key? key,
      required this.time,
      required this.lat,
      required this.lon,
      required this.identifier,
      required this.use_compass})
      : super(key: key);

  final DateTime time;
  final double lat;
  final double lon;
  final String identifier;
  final bool use_compass;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Position>(
        stream: Geolocator.getPositionStream(),
        builder: (context, snapshot) {
          bool is_gps_connected = false;
          double self_lat = 0;
          double self_lon = 0;
          int self_heading = 0;

          if (snapshot.hasData) {
            is_gps_connected = true;
            self_lat = snapshot.data!.latitude;
            self_lon = snapshot.data!.longitude;
            self_heading = snapshot.data!.heading.toInt();
          }

          int distance =
              Geolocator.distanceBetween(self_lat, self_lon, lat, lon).toInt();
          String unit = 'm';
          String distanceText = distance.toString();
          if (distance >= 1000) {
            distanceText = (distance ~/ 100 / 10).toString();
            unit = 'km';
          }

          int heading =
              Geolocator.bearingBetween(self_lat, self_lon, lat, lon).toInt();

          heading < 0 ? heading += 360 : heading;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      )),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      is_gps_connected
                          ? Row(
                              children: [
                                Column(
                                  children: [
                                    Transform.rotate(
                                      angle: 2 *
                                          pi *
                                          (use_compass
                                              ? heading + self_heading
                                              : heading) /
                                          360,
                                      child: Icon(
                                        Icons.compass_calibration,
                                        size: 70,
                                        color: Colors.black26,
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        'heading',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      ),
                                      Text(
                                        '${heading}°',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        'distance',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      ),
                                      Text(
                                        '${distanceText}${unit}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        'identifier',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      ),
                                      Text(
                                        '${identifier}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        'coordinates',
                                      ),
                                      Text(
                                        '${lat.toStringAsFixed(6)},',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                      Text(
                                        '${lon.toStringAsFixed(6)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        'identifier',
                                      ),
                                      Text(
                                        '${identifier}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                      StreamBuilder(
                        stream: Stream.periodic(Duration(milliseconds: 300)),
                        builder: (context, snapshot) {
                          return Text(
                            DateTime.now().difference(time).inMinutes < 1
                                ? '${DateTime.now().difference(time).inSeconds} seconds ago'
                                : '${DateTime.now().difference(time).inMinutes} minutes ago',
                            style: Theme.of(context).textTheme.bodyText2,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
