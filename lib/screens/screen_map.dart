import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../aglora/data.dart';
import '../aglora/memory.dart';

class MapScreen extends StatelessWidget {
  const MapScreen(
      {Key? key, required this.centerLatitude, required this.centerLongitude})
      : super(key: key);

  final double centerLatitude;
  final double centerLongitude;

  @override
  Widget build(BuildContext context) {
    LatLng selfPosition = LatLng(0, 0);

    return Stack(children: [
      StreamBuilder<Position>(
          stream: Geolocator.getPositionStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final selfLat = snapshot.data!.latitude;
              final selfLon = snapshot.data!.longitude;

              selfPosition = LatLng(selfLat, selfLon);
            }

            return FlutterMap(
              options: MapOptions(
                enableMultiFingerGestureRace: false,
                center: LatLng(
                  centerLatitude,
                  centerLongitude,
                ),
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'enter your user agent package name',
                ),
                MarkerLayer(rotate: true, markers: [
                  _buildAvatar(context, selfPosition),
                ]),
                MarkerLayer(
                  rotate: true,
                  markers: _buildMarkers(context, agloraAppMemory.trackers),
                ),
              ],
            );
          }),
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.turn_left_outlined,
                      color: Colors.black,
                    ),
                    label: Text(
                      'Back',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .labelLarge
                          ?.copyWith(color: Colors.black),
                    )),
                Row(
                  children: [
                    Text(
                      "© OpenStreetMap contributors    ",
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleSmall
                          ?.copyWith(color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}

Marker _buildAvatar(dynamic context, LatLng position) {
  return Marker(
    width: 80.0,
    height: 80.0,
    point: position,
    builder: (ctx) => Container(
      child: Column(
        children: [
          Icon(
            CupertinoIcons.location_solid,
            color: Colors.blueAccent,
          ),
        ],
      ),
    ),
  );
}

List<Marker> _buildMarkers(
    dynamic context, List<AGLORATrackerPoint> _trackersDataList) {
  return _trackersDataList
      .map(
        (e) => (Marker(
          width: 150.0,
          height: 100.0,
          point: LatLng(e.latitude, e.longitude),
          builder: (ctx) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.map_pin_ellipse,
                color: Colors.blueAccent,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        e.identifier,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleMedium
                            ?.copyWith(color: Colors.black),
                      ),
                      StreamBuilder(
                        stream: Stream.periodic(Duration(milliseconds: 300)),
                        builder: (context, snapshot) {
                          return Text(
                            DateTime.now().difference(e.time).inMinutes < 1
                                ? '${DateTime.now().difference(e.time).inSeconds} sec'
                                : '${DateTime.now().difference(e.time).inMinutes} min',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleSmall
                                ?.copyWith(color: Colors.grey.shade500),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )),
      )
      .toList();

}
