import 'dart:core';
import 'dart:math';

import 'package:aglora_client/aglora/data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../utils/compass.dart';
import '../screen_map.dart';

class LORAtrackerTile extends StatelessWidget {
  const LORAtrackerTile({
    Key? key,
    required this.time,
    required this.lat,
    required this.lon,
    required this.identifier,
    required this.sensors,
    required this.useCompass,
  }) : super(key: key);

  final DateTime time;
  final double lat;
  final double lon;
  final String identifier;
  final List<AGLoRaSensor>? sensors;
  final bool useCompass;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Position>(
        stream: Geolocator.getPositionStream(),
        builder: (context, snapshot) {
          bool is_gps_connected = false;
          double self_lat = 0;
          double self_lon = 0;

          if (snapshot.hasData) {
            is_gps_connected = true;
            self_lat = snapshot.data!.latitude;
            self_lon = snapshot.data!.longitude;
          }

          final distance =
              Geolocator.distanceBetween(self_lat, self_lon, lat, lon).toInt();
          String unit = 'm';
          String distanceText = distance.toString();
          if (distance >= 1000) {
            distanceText = (distance ~/ 100 / 10).toString();
            unit = 'km';
          }

          final heading =
              Geolocator.bearingBetween(self_lat, self_lon, lat, lon).toInt();

          //heading < 0 ? heading += 360 : heading;

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
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    StreamBuilder<double>(
                                        stream: compassDataStream,
                                        builder: (context, snapshot) {
                                          final compassHeading =
                                              snapshot.data ?? 0;
                                          return Transform.rotate(
                                            angle: -2 *
                                                pi *
                                                (heading +
                                                    compassHeading +
                                                    180) /
                                                360,
                                            child: Icon(
                                              CupertinoIcons.arrow_up_circle,
                                              size: 70,
                                              color: Colors.yellow.shade200,
                                            ),
                                          );
                                        }),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'heading',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    Text(
                                      '${heading}°',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        'distance',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      Text(
                                        '${distanceText}${unit}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
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
                                            .bodyMedium,
                                      ),
                                      Text(
                                        '${identifier}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                            .bodyLarge,
                                      ),
                                      Text(
                                        '${lon.toStringAsFixed(6)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
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
                                            .headlineSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return MapScreen(
                                centerLatitude: lat,
                                centerLongitude: lon,
                              );
                            })),
                            icon: Icon(
                              CupertinoIcons.map_pin_ellipse,
                              color: Colors.lightGreenAccent.shade100,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white, width: 1),
                            ),
                            label: Text(
                              'Map',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSensors(sensors, context),
                              ],
                            ),
                          ),
                          StreamBuilder(
                            stream:
                                Stream.periodic(Duration(milliseconds: 300)),
                            builder: (context, snapshot) {
                              return Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _calculateTimeDifference(time),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildSensors(List<AGLoRaSensor>? sensors, BuildContext context) {
    if (sensors != null) {
      String sensorsText = 'Sensors';
      sensors.forEach((sensor) {
        sensorsText += '\n${sensor.name}: ${sensor.value}';
      });
      return Text(
        sensorsText,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return SizedBox.shrink();
  }

  String _calculateTimeDifference(DateTime time) {
    final DateTime timeNowUTC = DateTime.now().toUtc();
    final int difference = timeNowUTC.difference(time).inMinutes;

    String calculatedTime = '';

    calculatedTime = '${timeNowUTC.difference(time).inMinutes} minutes ago';

    if (difference < 1) {
      calculatedTime = '${timeNowUTC.difference(time).inSeconds} seconds ago';
    }

    if (difference >= 60) {
      calculatedTime = '${timeNowUTC.difference(time).inHours} hours ago';
    }
    return calculatedTime;
  }
}
